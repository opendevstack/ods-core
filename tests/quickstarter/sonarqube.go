package quickstarter

import (
	"bytes"
	b64 "encoding/base64"
	"fmt"
	"html/template"

	"github.com/google/go-cmp/cmp"
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

func verifySonarScan(componentID string, wantScanFile string, gotScan string, tmplData TemplateData) error {
	var wantScan bytes.Buffer
	tmpl, err := template.ParseFiles(wantScanFile)
	if err != nil {
		return fmt.Errorf("Failed to load golden file to verify Sonar scan: %w", err)
	}
	err = tmpl.Execute(&wantScan, tmplData)
	if err != nil {
		return fmt.Errorf("Failed to render file to verify Sonar scan: %w", err)
	}

	if diff := cmp.Diff(wantScan.String(), gotScan); diff != "" {
		return fmt.Errorf("Sonar scan mismatch for %s (-want +got):\n%s", componentID, diff)
	}

	return nil
}
