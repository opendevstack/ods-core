package steps

import (
	"fmt"
	"strings"
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
// This allows scripts to access test context and configuration
func buildScriptEnvironment(t *testing.T, step TestStep, tmplData TemplateData, projectName string) []string {
	envVars := []string{
		fmt.Sprintf("COMPONENT_ID=%s", step.ComponentID),
		fmt.Sprintf("PROJECT_ID=%s", projectName),
		fmt.Sprintf("NAMESPACE=%s-dev", projectName),
	}

	// If services are defined in runParams, export each as a named environment variable
	// Example: {"api": "api-service", "backend": "backend-service"} becomes
	//          API_SERVICE_URL and BACKEND_SERVICE_URL
	if step.RunParams != nil && len(step.RunParams.Services) > 0 {
		for serviceName, actualServiceName := range step.RunParams.Services {
			// Render service name template if needed
			renderedServiceName := renderTemplate(t, actualServiceName, tmplData)
			serviceKey := fmt.Sprintf("ExposedService_%s", renderedServiceName)
			if exposedURL, ok := tmplData[serviceKey].(string); ok && exposedURL != "" {
				envVarName := fmt.Sprintf("%s_SERVICE_URL", strings.ToUpper(serviceName))
				envVars = append(envVars, fmt.Sprintf("%s=%s", envVarName, exposedURL))
				fmt.Printf("   Setting %s=%s for script (from exposed service)\n", envVarName, exposedURL)
			}
		}
	} else if step.ComponentID != "" {
		// Fallback: If no services map defined, export the ComponentID service as SERVICE_URL
		// This maintains backward compatibility
		renderedComponentID := renderTemplate(t, step.ComponentID, tmplData)
		serviceKey := fmt.Sprintf("ExposedService_%s", renderedComponentID)
		if exposedURL, ok := tmplData[serviceKey].(string); ok && exposedURL != "" {
			envVars = append(envVars, fmt.Sprintf("SERVICE_URL=%s", exposedURL))
			fmt.Printf("   Setting SERVICE_URL=%s for script (from exposed service)\n", exposedURL)
		}
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
