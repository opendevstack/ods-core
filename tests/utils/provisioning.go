package utils

import (
	"fmt"
	"os"
	"strings"
	"time"
)

// ProvisionAPI represents the provisioning app.
type ProvisionAPI struct {
	ProjectName string
	Config      map[string]string
}

// DeleteProject deletes a project via the provisioning app.
func (api *ProvisionAPI) DeleteProject() error {
	ocpProjectName := strings.ToLower(api.Config["ODS_NAMESPACE"])
	stdout, stderr, err := RunScriptFromBaseDir(
		"tests/scripts/provisioning-app-api.sh",
		[]string{"DELETE", api.ProjectName},
		[]string{fmt.Sprintf("ODS_NAMESPACE=%s", ocpProjectName)},
	)

	if err != nil {
		return fmt.Errorf(
			"Execution of `provisioning-app-api.sh` for '%s/%s' failed: \nStdOut: %s\nStdErr: %s\nErr: %w",
			"DELETE",
			api.ProjectName,
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf(
			"Execution of `provisioning-app-api.sh` for '%s/%s' worked: \nStdOut: %s\n",
			"DELETE",
			api.ProjectName,
			stdout)
		time.Sleep(20 * time.Second)
	}
	return nil
}

// CreateProject creates a project via the provisioning app.
func (api *ProvisionAPI) CreateProject() ([]byte, error) {
	ocpProjectName := strings.ToLower(api.Config["ODS_NAMESPACE"])
	stdout, stderr, err := RunScriptFromBaseDir(
		"tests/scripts/provisioning-app-api.sh",
		[]string{"POST"},
		[]string{
			"PROVISION_FILE=fixtures/create-project-request.json",
			fmt.Sprintf("ODS_NAMESPACE=%s", ocpProjectName),
		},
	)

	if err != nil {
		return nil, fmt.Errorf(
			"Execution of `provisioning-app-api.sh` for '%s/%s' failed: \nStdOut: %s\nStdErr: %s\nErr: %w",
			"POST",
			api.ProjectName,
			stdout,
			stderr,
			err)
	}
	fmt.Printf("Provision app raw logs: %s\n", stdout)

	// get the (json) response from the script created file
	log, err := os.ReadFile("response.txt")
	if err != nil {
		return nil, fmt.Errorf("Could not read response file?!, %s", err)
	}
	fmt.Printf("Provision results: %s\n", string(log))
	fmt.Printf("-----\n")
	return log, nil
}

// DeleteComponent deletes a component via the provisioning app.
func (api *ProvisionAPI) DeleteComponent() error {
	ocpProjectName := strings.ToLower(api.Config["ODS_NAMESPACE"])
	stages, stderr, err := RunScriptFromBaseDir(
		"tests/scripts/provisioning-app-api.sh",
		[]string{"DELETE_COMPONENT"},
		[]string{
			"PROVISION_FILE=fixtures/create-component-request.json",
			fmt.Sprintf("ODS_NAMESPACE=%s", ocpProjectName),
		},
	)

	if err != nil {
		return fmt.Errorf(
			"Execution of `provisioning-app-api.sh/delete component` for '%s/%s' failed: \nStdOut: %s\nStdErr: %s\nErr: %w",
			"DELETE_COMPONENT",
			api.ProjectName,
			stages,
			stderr,
			err)
	}
	fmt.Printf(
		"Execution of `provisioning-app-api.sh/delete component` for '%s' worked: \nStdOut: %s\n",
		"DELETE_COMPONENT",
		stages)
	time.Sleep(20 * time.Second)
	return nil
}

// CreateComponent creates a component via the provisioning app.
func (api *ProvisionAPI) CreateComponent() ([]byte, error) {
	ocpProjectName := strings.ToLower(api.Config["ODS_NAMESPACE"])
	stages, stderr, err := RunScriptFromBaseDir(
		"tests/scripts/provisioning-app-api.sh",
		[]string{"PUT"},
		[]string{
			"PROVISION_FILE=fixtures/create-component-request.json",
			fmt.Sprintf("ODS_NAMESPACE=%s", ocpProjectName),
		},
	)

	if err != nil {
		return nil, fmt.Errorf(
			"Execution of `provisioning-app-api.sh` for '%s' failed: \nStdOut: %s\nStdErr: %s\nErr: %w",
			"PUT/component",
			stages,
			stderr,
			err)
	}
	fmt.Printf("Provision app raw logs:%s\n", stages)

	// get the (json) response from the script created file
	log, err := os.ReadFile("response.txt")
	if err != nil {
		return nil, fmt.Errorf("Could not read response file?!, %w", err)
	}
	fmt.Printf("Provision results: %s\n", string(log))
	fmt.Printf("-----\n")
	return log, nil
}
