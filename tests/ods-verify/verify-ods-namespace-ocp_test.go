package ods_verify

import (
	"path"
	"runtime"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

func TestVerifyOdsNamespaceJenkinsOcpConfig(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "build")
	tailorOcpConfigNoDiffs(dir, t)
}

func TestVerifyOdsNamespaceSonarqubeOcpConfig(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "sonarqube", "ocp-config")
	tailorOcpConfigNoDiffs(dir, t)
}

func TestVerifyOdsNamespaceNexusOcpConfig(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "nexus", "ocp-config")
	tailorOcpConfigNoDiffs(dir, t)
}

func TestVerifyOdsNamespaceDocGenSvcOcpConfig(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "ods-document-generation-svc", "ocp-config")
	tailorOcpConfigNoDiffs(dir, t)
}

func TestVerifyOdsNamespaceProvAppOcpConfig(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "ods-provisioning-app", "ocp-config")
	tailorOcpConfigNoDiffs(dir, t)
}

func tailorOcpConfigNoDiffs(dir string, t *testing.T) {
	stdout, stderr, err := utils.RunCommandWithWorkDir("tailor", []string{
		"diff",
		"--reveal-secrets",
	}, dir, []string{})
	if err != nil {
		t.Fatalf(
			"Execution of tailor failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}
