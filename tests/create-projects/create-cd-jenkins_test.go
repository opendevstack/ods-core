package create_projects

import (
	"encoding/base64"
	"fmt"
	"github.com/opendevstack/ods-core/tests/utils"
	"path"
	"runtime"
	"testing"
)

func TestCreateJenkinsWithOutProjectId(t *testing.T) {
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--debug"})
	if err == nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkinsWithOutCDUserType(t *testing.T) {
	user := base64.StdEncoding.EncodeToString([]byte("myuser"))
	secret := base64.StdEncoding.EncodeToString([]byte("mysecret"))
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--debug"},
		utils.PROJECT_ENV_VAR,
		// "CD_USER_TYPE=general",
		fmt.Sprintf("CD_USER_ID_B64=%s", user),
		fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret))
	if err == nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkinsWithOutCDUserId(t *testing.T) {
	// user := base64.StdEncoding.EncodeToString([]byte("myuser"))
	secret := base64.StdEncoding.EncodeToString([]byte("mysecret"))
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--debug"},
		utils.PROJECT_ENV_VAR,
		"CD_USER_TYPE=general",
		//fmt.Sprintf("CD_USER_ID_B64=%s",user),
		fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret))
	if err == nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkinsWithOutSecret(t *testing.T) {
	user := base64.StdEncoding.EncodeToString([]byte("myuser"))
	//secret := base64.StdEncoding.EncodeToString([]byte("mysecret"))
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--debug"},
		utils.PROJECT_ENV_VAR,
		"CD_USER_TYPE=general",
		fmt.Sprintf("CD_USER_ID_B64=%s", user))
	// fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s",secret)	)
	if err == nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateJenkins(t *testing.T) {
	RemoveAllOCProjects(t)
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{}, utils.PROJECT_ENV_VAR)
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
	user := base64.StdEncoding.EncodeToString([]byte("myuser"))
	secret := base64.StdEncoding.EncodeToString([]byte("mysecret"))
	stdout, stderr, err = utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--debug"},
		utils.PROJECT_ENV_VAR,
		"CD_USER_TYPE=general",
		fmt.Sprintf("CD_USER_ID_B64=%s", user),
		fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret))
	if err != nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "create-projects", "ocp-config", "cd-jenkins")
	stdout, stderr, err = utils.RunCommandWithWorkDir("tailor", []string{"status", "--force"}, dir, utils.PROJECT_ENV_VAR)

	if err != nil {
		t.Fatalf(
			"Execution of tailor failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}
