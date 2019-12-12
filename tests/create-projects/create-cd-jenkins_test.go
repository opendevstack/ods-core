package create_projects

import (
	"github.com/opendevstack/ods-core/tests/utils"
	"testing"
)

func TestCreateJenkinsWithOutProjectId(t *testing.T) {
	stdout, stderr, err := utils.RunCommandFromBaseDir("create-projects/create-cd-jenkins.sh")
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkins(t *testing.T) {
	stdout, stderr, err := utils.RunCommandFromBaseDir("create-projects/create-projects.sh", utils.PROJECT_ENV_VAR)
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}

	stdout, stderr, err = utils.RunCommandFromBaseDir("create-projects/create-cd-jenkins.sh", utils.PROJECT_ENV_VAR)
	if err != nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}
