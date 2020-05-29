package create_projects

import (
	"fmt"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

func TestCreateJenkinsWithMissingEnvVars(t *testing.T) {

	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatal(
			"Could not read ods-core.env")
	}

	user := values["CD_USER_ID_B64"]
	secret := values["PIPELINE_TRIGGER_SECRET_B64"]

	var testCases = map[string]struct {
		args       []string
		missingArg string
	}{
		"Create Jenkins without project id": {
			args: []string{
				fmt.Sprintf("--cd-user-type=%s", "general"),
				fmt.Sprintf("--cd-user-id-b64=%s", user),
				fmt.Sprintf("--pipeline-trigger-secret-b64=%s", secret),
			},
			missingArg: "--project",
		},
		"Create Jenkins without CD user type": {
			args: []string{
				fmt.Sprintf("--project=%s", utils.PROJECT_NAME),
				fmt.Sprintf("--cd-user-id-b64=%s", user),
				fmt.Sprintf("--pipeline-trigger-secret-b64=%s", secret),
			},
			missingArg: "--cd-user-type",
		},
		"Create Jenkins without pipeline trigger secret": {
			args: []string{
				fmt.Sprintf("--project=%s", utils.PROJECT_NAME),
				fmt.Sprintf("--cd-user-type=%s", "general"),
				fmt.Sprintf("--cd-user-id-b64=%s", user),
			},
			missingArg: "--pipeline-trigger-secret-b64",
		},
	}

	for name, testCase := range testCases {
		t.Run(name, func(t *testing.T) {
			args := append(testCase.args, "--verbose")
			stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", args, []string{})
			if err == nil {
				t.Fatalf(
					"Execution of `create-cd-jenkins.sh` must fail if no %s is set: \nStdOut: %s\nStdErr: %s",
					testCase.missingArg,
					stdout,
					stderr,
				)
			}
		})
	}
}

func TestCreateJenkinsSuccessfully(t *testing.T) {
	err := utils.RemoveAllTestOCProjects()
	if err != nil {
		t.Fatal("Unable to remove test projects")
	}
	odsNamespace := "cd"
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{fmt.Sprintf("--project=%s", utils.PROJECT_NAME)}, []string{})
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}

	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatalf(
			"Could not read ods-core.env")
	}

	user := values["CD_USER_ID_B64"]
	secret := values["PIPELINE_TRIGGER_SECRET_B64"]

	stdout, stderr, err = utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{
		"--verbose",
		fmt.Sprintf("--ods-namespace=%s", odsNamespace),
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
