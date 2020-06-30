package ods_verify

import (
	"fmt"
	"path"
	"runtime"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

func TestVerifyOdsNamespaceJenkinsOcpConfig(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "build")

	kinds := []string{"is", "bc"}
	components := []string{"jenkins-webhook-proxy", "jenkins-master", "jenkins-agent-base"}
	for _, k := range kinds {
		for _, s := range components {
			stdout, stderr, err := utils.RunCommandWithWorkDir("tailor", []string{
				"diff",
				"--reveal-secrets",
				fmt.Sprint(k, "/", s),
			}, dir, []string{})
			if err != nil {
				t.Fatalf(
					"Execution of tailor failed: \nStdOut: %s\nStdErr: %s",
					stdout,
					stderr)
			}
		}
	}
}
