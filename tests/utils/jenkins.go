package utils

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"time"

	"github.com/google/go-cmp/cmp"
	v1 "github.com/openshift/api/build/v1"
	buildClientV1 "github.com/openshift/client-go/build/clientset/versioned/typed/build/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func RunJenkinsPipeline(jenkinsFile string, req RequestBuild, pipelineComponentPart string) (string, error) {
	fmt.Printf("-- starting build for: %s in project: %s\n", jenkinsFile, req.Project)

	config, err := ReadConfiguration()
	if err != nil {
		return "", err
	}

	body, err := json.Marshal(req)
	if err != nil {
		return "", fmt.Errorf("Could not marshal json: %s", err)
	}

	if len(pipelineComponentPart) == 0 {
		jenkinsFilePath := strings.Split(jenkinsFile, "/")
		pipelineNamePrefix := strings.ToLower(jenkinsFilePath[0])
		pipelineJobName := "prov"
		if len(jenkinsFilePath) == 1 {
			pipelineNamePrefix = req.Repository
			pipelineJobName = "run"
		}

		pipelineComponentPart = fmt.Sprintf("%s-%s-%s", pipelineJobName, pipelineNamePrefix, req.Project)
	}

	fmt.Printf("Starting pipeline %s\n", pipelineComponentPart)

	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	url := fmt.Sprintf("https://webhook-proxy-%s%s/build?trigger_secret=%s&jenkinsfile_path=%s&component=%s",
		PROJECT_NAME_CD,
		config["OPENSHIFT_APPS_BASEDOMAIN"],
		config["PIPELINE_TRIGGER_SECRET"],
		jenkinsFile,
		pipelineComponentPart)
	response, err := http.Post(
		url,
		"application/json",
		bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	bodyBytes, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	fmt.Printf("Pipeline: %s, response: %s\n", pipelineComponentPart, string(bodyBytes))

	if response.StatusCode >= http.StatusAccepted {
		bodyBytes, err := ioutil.ReadAll(response.Body)
		if err != nil {
			return "", err
		}
		return "", fmt.Errorf("Could not post to pipeline: %s (%s) - response: %d, body: %s",
			pipelineComponentPart, url, response.StatusCode, string(bodyBytes))
	}

	var responseI map[string]interface{}
	err = json.Unmarshal(bytes.Split(bodyBytes, []byte("\n"))[0], &responseI)
	if err != nil {
		return "", fmt.Errorf("Could not parse json response: %s, err: %s",
			string(bodyBytes), err)
	}

	metadataAsMap := responseI["metadata"].(map[string]interface{})
	buildName := metadataAsMap["name"].(string)
	fmt.Printf("Pipeline: %s, build name from response: %s\n",
		pipelineComponentPart, buildName)
	return buildName, err
}

func RetrieveJenkinsBuildStagesForBuild(jenkinsNamespace string, buildName string) (string, error) {

	fmt.Printf("Getting stages for build: %s in project: %s\n",
		buildName, jenkinsNamespace)
	fmt.Printf("To get more info, use print-jenkins-log.sh %s %s \n", jenkinsNamespace, buildName)

	config, err := GetOCClient()
	if err != nil {
		return "", fmt.Errorf("Error creating OC config: %s", err)
	}

	buildClient, err := buildClientV1.NewForConfig(config)
	if err != nil {
		return "", fmt.Errorf("Error creating Build client: %s", err)
	}

	time.Sleep(10 * time.Second)
	build, err := buildClient.Builds(jenkinsNamespace).Get(buildName, metav1.GetOptions{})
	count := 0
	// especially provision builds with CLIs take longer ...
	max := 400
	for (err != nil || build.Status.Phase == v1.BuildPhaseNew || build.Status.Phase == v1.BuildPhasePending || build.Status.Phase == v1.BuildPhaseRunning) && count < max {
		build, err = buildClient.Builds(jenkinsNamespace).Get(buildName, metav1.GetOptions{})
		time.Sleep(20 * time.Second)
		if err != nil {
			fmt.Printf("Err Build: %s is still not available, %s\n", buildName, err)
			// try to refresh the client - sometimes the token does expire...
			config, err = GetOCClient()
			if err != nil {
				fmt.Printf("Error creating OC config: %s", err)
			} else {
				buildClient, err = buildClientV1.NewForConfig(config)
				if err != nil {
					fmt.Printf("Error creating Build client: %s", err)
				}
			}
		} else {
			fmt.Printf("Waiting for build of %s to complete (%d/%d). Current status: %s\n", buildName, count, max, build.Status.Phase)
		}
		count++
	}

	buildSeemsToBeComplete := "true"
	// in case the the build was sort of never really started - get the jenkins pod log, maybe there
	// is a plugin / sync problem?
	if build.Status.Phase == v1.BuildPhaseNew || build.Status.Phase == v1.BuildPhasePending || build.Status.Phase == v1.BuildPhaseRunning {
		buildSeemsToBeComplete = "false"
		// get the jenkins pod log
		stdoutJPod, stderrJPod, errJPod := RunScriptFromBaseDir(
			"tests/scripts/print-jenkins-pod-log.sh",
			[]string{
				jenkinsNamespace,
			}, []string{})
		if errJPod != nil {
			fmt.Printf("Error getting jenkins pod logs: %s\nerr:%s", errJPod, stderrJPod)
		} else {
			fmt.Printf("Jenkins pod logs: \n%s \nerr:%s", stdoutJPod, stderrJPod)
		}
	}

	fmt.Printf("Build seems to be complete ? : %s \n", buildSeemsToBeComplete)

	// get the jenkins run build log
	stdout, stderr, err := RunScriptFromBaseDir(
		"tests/scripts/print-jenkins-log.sh",
		[]string{
			jenkinsNamespace,
			buildName,
			buildSeemsToBeComplete,
		}, []string{})

	if err != nil {
		return "", fmt.Errorf(
			"Could not execute tests/scripts/print-jenkins-log.sh\n - err:%s\n - stderr:%s",
			err,
			stderr,
		)
	}

	// print in any case, otherwise when err != nil no logs are shown
	fmt.Printf("buildlog: %s\n%s", buildName, stdout)

	// still running, or we could not find it ...
	if count >= max {
		return "", fmt.Errorf(
			"Timeout during build: %s\nStdOut: %s\nStdErr: %s",
			buildName,
			stdout,
			stderr)
	}

	// get (executed) jenkins stages from run - the caller can compare against the golden record
	stdout, stderr, err = RunScriptFromBaseDir(
		"tests/scripts/print-jenkins-json-status.sh",
		[]string{
			buildName,
			jenkinsNamespace,
		}, []string{})

	if err != nil {
		return "", fmt.Errorf("Error getting jenkins stages for: %s\rError: %s, %s, %s",
			buildName, err, stdout, stderr)
	}

	return stdout, nil
}

func VerifyJenkinsRunAttachments(projectName string, buildName string, artifactsToVerify []string) error {
	if len(artifactsToVerify) == 0 {
		return nil
	}

	// verify that we can retrieve artifacts from the RM jenkins run
	for _, document := range artifactsToVerify {

		fmt.Printf("Getting artifact: %s from project: %s for build %s\n",
			document, projectName, buildName)
		stdout, stderr, err := RunScriptFromBaseDir(
			"tests/scripts/get-artifact-from-jenkins-run.sh",
			[]string{
				buildName,
				projectName,
				document,
			}, []string{})

		if err != nil {
			return fmt.Errorf("Could not execute tests/scripts/get-artifact-from-jenkins-run.sh\n - err:%s\nout:%s\nstderr:%s",
				err, stdout, stderr)
		}
		fmt.Printf("found artifact: %s from project: %s for build %s\n",
			document, projectName, buildName)
	}
	return nil
}

func VerifyJenkinsStages(goldenFile string, gotStages string) error {
	wantStages, err := ioutil.ReadFile(goldenFile)
	if err != nil {
		return fmt.Errorf("Failed to load golden file to verify Jenkins stages: %w", err)
	}

	if diff := cmp.Diff(string(wantStages), gotStages); diff != "" {
		return fmt.Errorf("Jenkins stages mismatch (-want +got):\n%s", diff)
	}

	return nil
}
