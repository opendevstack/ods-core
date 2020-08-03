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
	"strings"
	"testing"
	"time"

	"github.com/opendevstack/ods-core/tests/utils"
	v1 "github.com/openshift/api/build/v1"
	buildClientV1 "github.com/openshift/client-go/build/clientset/versioned/typed/build/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestCreateProjectThruWebhookProxyJenkinsFile(t *testing.T) {
	projectName := utils.PROJECT_NAME
	projectNameCd := utils.PROJECT_NAME_CD

	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatalf("Error reading ods-core.env: %s", err)
	}

	err = utils.RemoveAllTestOCProjects()
	if err != nil {
		t.Fatal("Unable to remove test projects")
	}

	buildConfigName := fmt.Sprintf("ods-corejob-create-project-%s-%s", projectName, strings.ReplaceAll(values["ODS_GIT_REF"], "/", "-"))

	err = utils.RemoveBuildConfigs(values["ODS_NAMESPACE"], buildConfigName)

	request := utils.RequestBuild{
		Repository: "ods-core",
		Branch:     values["ODS_GIT_REF"],
		Project:    values["ODS_BITBUCKET_PROJECT"],
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
				Value: values["ODS_GIT_REF"],
			},
			{
				Name:  "ODS_IMAGE_TAG",
				Value: values["ODS_IMAGE_TAG"],
			},
			{
				Name:  "ODS_NAMESPACE",
				Value: values["ODS_NAMESPACE"],
			},
			{
				Name:  "ODS_BITBUCKET_PROJECT",
				Value: values["ODS_BITBUCKET_PROJECT"],
			},
		},
	}

	body, err := json.Marshal(request)
	if err != nil {
		t.Fatalf("Could not marshal request json for creation: %s", err)
	}

	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	reponse, err := http.Post(
		fmt.Sprintf("https://%s%s/build?trigger_secret=%s&jenkinsfile_path=create-projects/Jenkinsfile&component=ods-corejob-create-project-%s",
			values["PROV_APP_WEBHOOKPROXY_HOST"],
			values["OPENSHIFT_APPS_BASEDOMAIN"],
			values["PIPELINE_TRIGGER_SECRET"],
			projectName),
		"application/json",
		bytes.NewBuffer(body))

	if err != nil {
		t.Fatalf("Could not post request: %s", err)
	}

	defer reponse.Body.Close()

	bodyBytes, _ := ioutil.ReadAll(reponse.Body)

	if reponse.StatusCode >= http.StatusAccepted {
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

	var responseI map[string]interface{}
	err = json.Unmarshal(bytes.Split(bodyBytes, []byte("\n"))[0], &responseI)
	if err != nil {
		t.Fatalf("Could not parse json response: %s, err: %s",
			string(bodyBytes), err)
	}

	metadataAsMap := responseI["metadata"].(map[string]interface{})
	buildName := metadataAsMap["name"].(string)
	fmt.Printf("Buildname from response: %s\n", buildName)

	time.Sleep(10 * time.Second)
	build, err := buildClient.Builds(values["ODS_NAMESPACE"]).Get(buildName, metav1.GetOptions{})
	count := 0
	max := 240
	for (err != nil || build.Status.Phase == v1.BuildPhaseNew || build.Status.Phase == v1.BuildPhasePending || build.Status.Phase == v1.BuildPhaseRunning) && count < max {
		build, err = buildClient.Builds(values["ODS_NAMESPACE"]).Get(buildName, metav1.GetOptions{})
		time.Sleep(20 * time.Second)
		if err != nil {
			fmt.Printf("Build is still not available: %s\n", err)
		} else {
			fmt.Printf("Waiting for build. Current status: %s\n", build.Status.Phase)
		}
		count++
	}

	stdout, stderr, err := utils.RunScriptFromBaseDir(
		"tests/scripts/utils/print-jenkins-json-status.sh",
		[]string{
			buildName,
			values["ODS_NAMESPACE"],
		}, []string{})

	if err != nil {
		t.Fatal(err)
	}

	expected, err := ioutil.ReadFile("golden/jenkins-create-project-stages.json")
	if err != nil {
		t.Fatal(err)
	}

	expectedAsString := string(expected)
	if stdout != expectedAsString {
		t.Fatalf("Actual jenkins stages from run: %s don't match -golden:\n'%s'\n-jenkins response:\n'%s'",
			buildName, expectedAsString, stdout)
	}

	if count >= max || build.Status.Phase != v1.BuildPhaseComplete {
		if count >= max {
			t.Fatalf(
				"Timeout during build: \nStdOut: %s\nStdErr: %s",
				stdout,
				stderr)
		} else {
			t.Fatalf(
				"Error during build - pleaes check jenkins - project: %s - build: %s: \nStdOut: %s\nStdErr: %s",
				values["ODS_NAMESPACE"],
				buildName,
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
		"--exclude=rolebinding",
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
