package ods_verify

import (
	"fmt"
	"path"
	"runtime"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

func TestVerifyOdsNamespaceNexusFunctions(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "nexus")
	test := fmt.Sprint(dir, "/test.sh")

	stdout, stderr, err := utils.RunCommandWithWorkDir(test, []string{
		"--verify",
		"--no-prompts",
	}, dir, []string{})
	if err != nil {
		t.Fatalf(
			"Execution of nexus test.sh failed at %s:\nStdOut: %s\nStdErr: %s",
			test,
			stdout,
			stderr)
	}
}
