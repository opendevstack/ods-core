package ods_verify

import (
	"testing"
	"github.com/opendevstack/ods-core/tests/utils"
	"io/ioutil"
	"fmt"
	"strings"
	"encoding/json"	
)

func TestVerifyOdsProjectProvisionThruProvisionApi(t *testing.T) {
	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatal(err)
	}

	// cleanup
	projectName := "ODS3PASSO6"

	// use the api sample script to cleanup
	stdout, stderr, err := utils.RunScriptFromBaseDir(
		"tests/scripts/create-project-api.sh",
		[]string{
			"DELETE",
			projectName,
		}, []string{})

	if err != nil {
		fmt.Printf((
			"Execution of `create-project-api.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
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
	
	responseExecutionJobs := responseI["lastExecutionJobs"].(map[string]interface{})
	responseBuildName := responseExecutionJobs["name"].(string)
	responseJenkinsBuildUrl := responseExecutionJobs["url"].(string)
	responseBuildRun := strings.SplitAfter(responseJenkinsBuildUrl, responseBuildName + "/")[1]
	
	fmt.Printf("build run#: %s\n", responseBuildRun)
	
	responseBuildClean := strings.Replace(responseBuildName,
		values["ODS_NAMESPACE"] + "-", "", 1)
	
	// get (executed) jenkins stages from run - the caller can compare against the golden record 
	stdout, _, err = utils.RunScriptFromBaseDir(
		"tests/scripts/print-jenkins-json-status.sh",
		[]string{
			fmt.Sprintf("%s-%s", responseBuildClean, responseBuildRun),
			values["ODS_NAMESPACE"],
		}, []string{})

	if err != nil {
		t.Fatalf("Error getting jenkins stages for build: %s\rError: %s\n",
			responseBuildClean, err)
	} else {
		fmt.Printf("Jenkins stages: \n'%s'\n", stdout)
	}
	
	// verify provision jenkins stages - against golden record
	expected, err := ioutil.ReadFile("golden/create-project-response.json")
	if err != nil {
		t.Fatal(err)
	}
	
	if stdout != string(expected) {
		t.Fatalf("prov run - records don't match -golden:\n'%s'\n-jenkins response:\n'%s'",
			string(expected), stdout)
	}

}
