package ods_verify

import (
	"fmt"
	"path"
	"runtime"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

func TestVerifyOdsNamespaceNexusFunctions(t *testing.T) {
	verifyWithTestScript("nexus", t)
}

func TestVerifyOdsNamespaceSonarqubeFunctions(t *testing.T) {
	verifyWithTestScript("sonarqube", t)
}

func verifyWithTestScript(what string, t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", what)
	test := fmt.Sprint(dir, "/", "test.sh")

	stdout, stderr, err := utils.RunCommandWithWorkDir(test, []string{
		"--verify",
		"--no-prompts",
		"--insecure",
	}, dir, []string{})
	if err != nil {
		t.Fatalf(
			"Execution of %s test.sh failed at %s:\nStdOut: %s\nStdErr: %s",
			what,
			test,
			stdout,
			stderr)
	}
}
