package create_projects

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"path"
	"runtime"
	"testing"
	"time"

	"github.com/opendevstack/ods-core/tests/utils"
	v1 "github.com/openshift/api/build/v1"
	buildClientV1 "github.com/openshift/client-go/build/clientset/versioned/typed/build/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestJenkinsFile(t *testing.T) {
	projectName := utils.PROJECT_NAME
	projectNameCd := utils.PROJECT_NAME_CD

	err := utils.RemoveAllTestOCProjects()
	if err != nil {
		t.Fatal("Unable to remove test projects")
	}

	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatalf("Error reading ods-core.env: %s", err)
	}

	request := utils.RequestBuild{
		Repository: "ods-core",
		Branch:     "cicdtests",
		Project:    "opendevstack",
		Env: []utils.EnvPair{
			{
				Name:  "PROJECT_ID",
				Value: projectName,
			},
			{
				Name:  "CD_USER_TYPE",
				Value: "general",
			},
			{
				Name:  "CD_USER_ID_B64",
				Value: values["CD_USER_ID_B64"],
			},
			{
				Name:  "PIPELINE_TRIGGER_SECRET",
				Value: values["PIPELINE_TRIGGER_SECRET_B64"],
			},
			{
				Name:  "ODS_GIT_REF",
				Value: "cicdtests",
			},
			{
				Name:  "ODS_IMAGE_TAG",
				Value: values["ODS_IMAGE_TAG"],
			},
		},
	}

	body, err := json.Marshal(request)
	if err != nil {
		t.Fatalf("Could not marchal json: %s", err)
	}

	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	reponse, err := http.Post(
		fmt.Sprintf("https://webhook-proxy-prov-cd.172.17.0.1.nip.io/build?trigger_secret=%s&jenkinsfile_path=create-projects/Jenkinsfile&component=ods-corejob-create-project-%s",
			values["PIPELINE_TRIGGER_SECRET"],
			projectName),
		"application/json",
		bytes.NewBuffer(body))

	if err != nil {
		t.Fatalf("Could not post request: %s", err)
	}

	if reponse.StatusCode >= http.StatusAccepted {
		bodyBytes, err := ioutil.ReadAll(reponse.Body)
		if err != nil {
			t.Fatal(err)
		}
		t.Fatalf("Could not post request: %s", string(bodyBytes))
	}

	if reponse.StatusCode >= http.StatusAccepted {
		bodyBytes, err := ioutil.ReadAll(reponse.Body)
		if err != nil {
			t.Fatal(err)
		}
		t.Fatalf("Could not post request: %s", string(bodyBytes))
	}

	config, err := utils.GetOCClient()
	if err != nil {
		t.Fatalf("Error creating OC config: %s", err)
	}

	buildClient, err := buildClientV1.NewForConfig(config)
	if err != nil {
		t.Fatalf("Error creating Build client: %s", err)
	}

	time.Sleep(10 * time.Second)
	build, err := buildClient.Builds("prov-cd").Get(fmt.Sprintf("ods-corejob-create-project-%s-cicdtests-1", projectName), metav1.GetOptions{})
	count := 0
	max := 240
	for (err != nil || build.Status.Phase == v1.BuildPhaseNew || build.Status.Phase == v1.BuildPhasePending || build.Status.Phase == v1.BuildPhaseRunning) && count < max {
		build, err = buildClient.Builds("prov-cd").Get(fmt.Sprintf("ods-corejob-create-project-%s-cicdtests-1", projectName), metav1.GetOptions{})
		time.Sleep(2 * time.Second)
		if err != nil {
			fmt.Printf("Build is still not available")
		} else {
			fmt.Printf("Waiting for build. Current status: %s", build.Status.Phase)
		}
		count++
	}

	stdout, stderr, _ := utils.RunScriptFromBaseDir(
		"tests/scripts/utils/print-jenkins-log.sh",
		[]string{
			fmt.Sprintf("ods-corejob-create-project-%s-cicdtests-1", projectName),
		}, []string{})

	if count >= max || build.Status.Phase != v1.BuildPhaseComplete {

		if count >= max {
			t.Fatalf(
				"Timeout during build: \nStdOut: %s\nStdErr: %s",
				stdout,
				stderr)
		} else {
			t.Fatalf(
				"Error during build: \nStdOut: %s\nStdErr: %s",
				stdout,
				stderr)
		}

	}
	CheckProjectSetup(t)
	CheckJenkinsWithTailor(values, projectNameCd, projectName, t)

}

func CheckJenkinsWithTailor(values map[string]string, projectNameCd string, projectName string, t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "deploy")

	user := values["CD_USER_ID_B64"]
	secret := values["PIPELINE_TRIGGER_SECRET_B64"]

	stdout, stderr, err := utils.RunCommandWithWorkDir("tailor", []string{
		"diff",
		"--reveal-secrets",
		"-n", projectNameCd,
		fmt.Sprintf("--param=PROJECT=%s", projectName),
		fmt.Sprintf("--param=CD_USER_ID_B64=%s", user),
		"--selector", "template=ods-jenkins-template",
		fmt.Sprintf("--param=%s", fmt.Sprintf("PROXY_TRIGGER_SECRET_B64=%s", secret))}, dir, []string{})
	if err != nil {

		t.Fatalf(
			"Execution of tailor failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}
