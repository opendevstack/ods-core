package create_projects

import (
	"fmt"
	"github.com/opendevstack/ods-core/tests/utils"
	"testing"
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
		envVars       []string
		missingEnvVar string
	}{
		"Create Jenkins without project id": {
			envVars: []string{
				//    utils.PROJECT_ENV_VAR,
				"CD_USER_TYPE=general",
				fmt.Sprintf("CD_USER_ID_B64=%s", user),
				fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret),
			},
			missingEnvVar: "PROJECT_ID",
		},
		"Create Jenkins without CD user type": {
			envVars: []string{
				utils.PROJECT_ENV_VAR,
				//"CD_USER_TYPE=general",
				fmt.Sprintf("CD_USER_ID_B64=%s", user),
				fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret),
			},
			missingEnvVar: "CD_USER_TYPE",
		},
		"Create Jenkins without pipeline trigger secret": {
			envVars: []string{
				utils.PROJECT_ENV_VAR,
				"CD_USER_TYPE=general",
				fmt.Sprintf("CD_USER_ID_B64=%s", user),
				// fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret),
			},
			missingEnvVar: "PIPELINE_TRIGGER_SECRET",
		},
	}

	for name, testCase := range testCases {
		t.Run(name, func(t *testing.T) {
			stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--verbose"}, testCase.envVars)
			if err == nil {
				t.Fatalf(
					"Execution of `create-cd-jenkins.sh` must fail if no %s is set: \nStdOut: %s\nStdErr: %s",
					testCase.missingEnvVar,
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
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{}, []string{utils.PROJECT_ENV_VAR})
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

	stdout, stderr, err = utils.RunScriptFromBaseDir("create-projects/create-cd-jenkins.sh", []string{"--force", "--verbose", "--ods-namespace", odsNamespace},
		[]string{
			utils.PROJECT_ENV_VAR,
			"CD_USER_TYPE=general",
			fmt.Sprintf("CD_USER_ID_B64=%s", user),
			fmt.Sprintf("PIPELINE_TRIGGER_SECRET=%s", secret),
		},
	)
	if err != nil {
		t.Fatalf(
			"Execution of `create-cd-jenkins.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
	CheckJenkinsWithTailor(values, utils.PROJECT_NAME_CD, utils.PROJECT_NAME, t)
}
