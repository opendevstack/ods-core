package create_projects

import (
	"fmt"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

func TestCreateODSJenkinsThruShellScripts(t *testing.T) {
	err := utils.RemoveAllTestOCProjects()
	if err != nil {
		t.Fatal("Unable to remove test projects")
	}

	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatalf("Error reading ods-core.env: %s", err)
	}

	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{fmt.Sprintf("--project=%s", utils.PROJECT_NAME)}, []string{})
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}

	user := values["CD_USER_ID_B64"]
	secret := values["PIPELINE_TRIGGER_SECRET_B64"]

	stdout, stderr, err = utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{
		"--verbose",
		"--non-interactive",
		fmt.Sprintf("--ods-namespace=%s", values["ODS_NAMESPACE"]),
		fmt.Sprintf("--ods-image-tag=%s", values["ODS_IMAGE_TAG"]),
		fmt.Sprintf("--ods-bitbucket-project=%s", values["ODS_BITBUCKET_PROJECT"]),
		fmt.Sprintf("--project=%s", utils.PROJECT_NAME),
		fmt.Sprintf("--cd-user-type=%s", "general"),
		fmt.Sprintf("--cd-user-id-b64=%s", user),
		fmt.Sprintf("--pipeline-trigger-secret-b64=%s", secret),
	},
		[]string{},
	)
	if err != nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
	CheckJenkinsWithTailor(values, utils.PROJECT_NAME_CD, utils.PROJECT_NAME, t)
}
