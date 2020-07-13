package ods_verify

import (
	"testing"
	"github.com/opendevstack/ods-core/tests/utils"
	"io/ioutil"
	"fmt"
	"strings"
	"encoding/json"
	"runtime"
	"path"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

)

func TestVerifyOdsProjectProvisionThruProvisionApi(t *testing.T) {
	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatal(err)
	}

	// cleanup
	projectName := "ODSVERIFY"

	// use the api sample script to cleanup
	stdout, stderr, err := utils.RunScriptFromBaseDir(
		"tests/scripts/create-project-api.sh",
		[]string{
			"DELETE",
			projectName,
		}, []string{})

	if err != nil {
		fmt.Printf(
			"Execution of `create-project-api.sh/delete` for '%s' failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			projectName,
			stdout,
			stderr,
			err)
	} 
	
	// api sample script - create project
	stdout, stderr, err = utils.RunScriptFromBaseDir(
		"tests/scripts/create-project-api.sh",
		[]string{}, []string{})

	if err != nil {
		t.Fatalf(
			"Execution of `create-project-api.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf("Provision app raw logs:%s\n", stdout)
	}

	// get the (json) response from the script created file
	log, err := ioutil.ReadFile("response.txt")
	if err != nil {
		t.Fatalf("Could not read response file?!, %s\n", err)
	} else {
		fmt.Printf("Provision results: %s\n", string(log))
	}
	
	var responseI map[string]interface{}
	err = json.Unmarshal(log, &responseI)
	if err != nil {
		t.Fatalf("Could not parse json response: %s, err: %s",
			string(log), err)
	}
	
	responseProjectName := responseI["projectName"].(string)
	if projectName != responseProjectName {
		t.Fatalf("Project names don't match - expected: %s real: %s",
			projectName, responseProjectName) 
	}
	
	responseExecutionJobsArray := responseI["lastExecutionJobs"].([]interface{})
	responseExecutionJobs := responseExecutionJobsArray[len(responseExecutionJobsArray) - 1].
		(map[string]interface{})
	responseBuildName := responseExecutionJobs["name"].(string)
	
	fmt.Printf("build name from jenkins: %s\n", responseBuildName)
	responseJenkinsBuildUrl := responseExecutionJobs["url"].(string)
	responseBuildRun := strings.SplitAfter(responseJenkinsBuildUrl, responseBuildName + "/")[1]
	
	fmt.Printf("build run#: %s\n", responseBuildRun)
	
	responseBuildClean := strings.Replace(responseBuildName,
		values["ODS_NAMESPACE"] + "-", "", 1)

	fullBuildName := fmt.Sprintf("%s-%s", responseBuildClean, responseBuildRun)
	fmt.Printf("full buildName: %s\n", fullBuildName)
	
	// get (executed) jenkins stages from run - the caller can compare against the golden record 
	stdout, stderr, err = utils.RunScriptFromBaseDir(
		"tests/scripts/utils/print-jenkins-json-status.sh",
		[]string{
			fullBuildName,
			values["ODS_NAMESPACE"],
		}, []string{})

	if err != nil {
		t.Fatalf("Error getting jenkins stages for build: %s\rStdout: %s\n, Stderr: %s\n, Error: %s\n",
			fullBuildName,
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf("Jenkins stages: \n'%s'\n", stdout)
	}
	
	// verify provision jenkins stages - against golden record
	/*
	expected, err := ioutil.ReadFile("golden/create-project-response.json")
	if err != nil {
		t.Fatal(err)
	}
	
	if stdout != string(expected) {
		t.Fatalf("prov run - records don't match -golden:\n'%s'\n-jenkins response:\n'%s'",
			string(expected), stdout)
	}*/
	CheckProjectsAreCreated(projectName, t)
	CheckJenkinsWithTailor(values, projectName, t)
}

func CheckProjectsAreCreated (projectName string, t *testing.T) {
	// check that all three projects were created
	expectedProjects := []string{
		fmt.Sprintf("%s-cd", projectName), 
		fmt.Sprintf("%s-dev", projectName),
		fmt.Sprintf("%s-test", projectName),
	}
	config, err := utils.GetOCClient()
	if err != nil {
		t.Fatalf("Error creating OC config: %s", err)
	}
	client, err := projectClientV1.NewForConfig(config)
	if err != nil {
		t.Fatalf("Error creating Project client: %s", err)
	}
	projects, err := client.Projects().List(metav1.ListOptions{})
	if err != nil {
		t.Fatalf("Cannot list projects: %s", err)
	}	
	for _, expectedProject := range expectedProjects {
		if err = utils.FindProject(projects, expectedProject); err != nil {
			t.Fatal(err)
		}
	}	
}

func CheckJenkinsWithTailor(values map[string]string, projectName string, t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "deploy")

	user := values["CD_USER_ID_B64"]
	secret := values["PIPELINE_TRIGGER_SECRET_B64"]

	stdout, stderr, err := utils.RunCommandWithWorkDir("tailor", []string{
		"diff",
		"--reveal-secrets",
		"--exclude=rolebinding",
		"-n", 
		fmt.Sprintf("%s-cd", projectName),
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