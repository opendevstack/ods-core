package create_projects

import (
	"github.com/opendevstack/ods-core/tests/utils"
	"path"
	"runtime"
	"testing"
)

func TestCreateJenkinsWithOutProjectId(t *testing.T) {
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh")
	if err == nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkinsWithOutCDUserType(t *testing.T) {
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", utils.PROJECT_ENV_VAR)
	if err == nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkins(t *testing.T) {
	RemoveAllOCProjects(t)
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", utils.PROJECT_ENV_VAR, "CD_USER_TYPE=general")
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}

	stdout, stderr, err = utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", utils.PROJECT_ENV_VAR)
	if err != nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "create-projects", "ocp-config", "cd-jenkins")
	stdout, stderr, err = utils.RunCommandWithWorkDir("tailor", []string{"status"}, dir)
	if err != nil {
		t.Fatalf(
			"Execution of tailor failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}
