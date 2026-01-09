package steps

import (
	"fmt"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

// ExecuteRun handles the run step type.
func ExecuteRun(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, projectName string) {
	if step.RunParams == nil || step.RunParams.File == "" {
		t.Fatalf("Missing run parameters, not defined script file.")
	}

	fmt.Printf("Executing script: %s\n", step.RunParams.File)
	scriptPath := fmt.Sprintf("%s/%s", testdataPath, step.RunParams.File)

	// Build environment variables to pass to script
	envVars := buildScriptEnvironment(t, step, tmplData, projectName)

	stdout, stderr, err := utils.RunCommand(scriptPath, []string{}, envVars)
	fmt.Printf("%s", stdout)
	if err != nil {
		t.Fatalf(
			"Execution of script:%s failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			scriptPath,
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf("Executed script: %s\n", scriptPath)
	}
}

// buildScriptEnvironment creates environment variables for shell scripts
// This allows scripts to access resolved service URLs and other test context
func buildScriptEnvironment(t *testing.T, step TestStep, tmplData TemplateData, projectName string) []string {
	envVars := []string{
		fmt.Sprintf("COMPONENT_ID=%s", step.ComponentID),
		fmt.Sprintf("PROJECT_ID=%s", projectName),
		fmt.Sprintf("NAMESPACE=%s-dev", projectName),
	}

	// If there's a service URL pattern we can detect, resolve it and pass it
	// This constructs the standard service URL and resolves it
	if step.ComponentID != "" {
		serviceURL := ConstructServiceURL(step.ComponentID, projectName+"-dev", "8080", "")
		resolvedURL := ResolveServiceURL(t, serviceURL, tmplData)
		envVars = append(envVars, fmt.Sprintf("SERVICE_URL=%s", resolvedURL))

		fmt.Printf("   Setting SERVICE_URL=%s for script\n", resolvedURL)
	}

	// Pass through template data as environment variables
	if val, ok := tmplData["OdsNamespace"].(string); ok && val != "" {
		envVars = append(envVars, fmt.Sprintf("ODS_NAMESPACE=%s", val))
	}
	if val, ok := tmplData["OdsGitRef"].(string); ok && val != "" {
		envVars = append(envVars, fmt.Sprintf("ODS_GIT_REF=%s", val))
	}
	if val, ok := tmplData["OdsImageTag"].(string); ok && val != "" {
		envVars = append(envVars, fmt.Sprintf("ODS_IMAGE_TAG=%s", val))
	}

	return envVars
}
