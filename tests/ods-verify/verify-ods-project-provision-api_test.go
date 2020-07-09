package ods_verify

import (
	"testing"
	"github.com/opendevstack/ods-core/tests/utils"
	"io/ioutil"
	"fmt"
)

func TestVerifyOdsProjectProvisionThruProvisionApi(t *testing.T) {
	// get (executed) jenkins stages from run - the caller can compare against the golden record 
	stdout, _, err := RunScriptFromBaseDir(
		"tests/scripts/create-project-api.sh",
		[]string{}, []string{})

	if err != nil {
		t.Fatalf(
			"Execution of `create-project-api.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	} else {
		fmt.Printf("Provision app raw logs:%s\n", stdout)
	}

	// verify provision jenkins stages - against golden record
	log, err := ioutil.ReadFile("../../scripts/response.txt")
	if err != nil {
		t.Fatal(err)
	} else {
		fmt.Printf("Provision results: %s\n", log)
	}
	
	// verify provision jenkins stages - against golden record
	expected, err := ioutil.ReadFile("golden/create-project-response.json")
	if err != nil {
		t.Fatal(err)
	}
	
	if log != string(expected) {
		t.Fatalf("Actual jenkins stages from prov run: %s don't match -golden:\n'%s'\n-jenkins response:\n'%s'",
			componentId, expectedAsString, stages)
	}

}
