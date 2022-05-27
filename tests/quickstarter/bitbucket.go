package quickstarter

import (
	"encoding/base64"
	"fmt"

	"github.com/opendevstack/ods-core/tests/utils"
)

func recreateBitbucketRepo(config map[string]string, project string, repo string) error {

	password, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		return fmt.Errorf("Error decoding cd_user password: %w", err)
	}

	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/recreate-bitbucket-repo.sh", []string{
		fmt.Sprintf("--bitbucket=%s", config["BITBUCKET_URL"]),
		fmt.Sprintf("--user=%s", config["CD_USER_ID"]),
		fmt.Sprintf("--password=%s", password),
		fmt.Sprintf("--project=%s", project),
		fmt.Sprintf("--repository=%s", repo),
	}, []string{})

	if err != nil {
		return fmt.Errorf(
			"Execution of `recreate-bitbucket-repo.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %w",
			stdout,
			stderr,
			err)
	}
	return nil
}
