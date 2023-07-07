package quickstarter

import (
	b64 "encoding/base64"
	"fmt"

	"github.com/opendevstack/ods-core/tests/utils"
)

func retrieveSonarScan(projectKey string, config map[string]string) (string, error) {

	fmt.Printf("Getting sonar scan for: %s\n", projectKey)

	sonartoken, _ := b64.StdEncoding.DecodeString(config["SONAR_AUTH_TOKEN_B64"])

	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/print-sonar-scan-run.sh", []string{
		string(sonartoken),
		config["SONARQUBE_URL"],
		projectKey,
	}, []string{})

	if err != nil {
		fmt.Printf(
			"Execution of `tests/scripts/print-sonar-scan-run.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			stdout,
			stderr,
			err)
		return "", err
	}
	fmt.Printf("Sonar scan result: \n%s\n", stdout)

	return stdout, nil
}
