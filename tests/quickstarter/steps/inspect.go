package steps

import (
	"bytes"
	"fmt"
	"os/exec"
	"regexp"
	"strings"
	"testing"
)

// ExecuteInspect handles the inspect step type for inspecting container runtime behavior.
func ExecuteInspect(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, projectName string) {
	if step.InspectParams == nil {
		t.Fatal("Missing inspect parameters")
	}

	params := step.InspectParams

	// Default namespace to {project}-dev
	namespace := params.Namespace
	if namespace == "" {
		namespace = fmt.Sprintf("%s-dev", projectName)
	}
	namespace = renderTemplate(t, namespace, tmplData)

	// Render resource with template data
	resource := renderTemplate(t, params.Resource, tmplData)

	fmt.Printf("Inspecting resource: %s in namespace %s\n", resource, namespace)

	if params.Checks == nil {
		fmt.Printf("No checks specified, skipping inspection\n")
		return
	}

	// Run log checks if specified
	if params.Checks.Logs != nil {
		if err := checkLogs(t, resource, namespace, params.Checks.Logs); err != nil {
			t.Fatalf("Log check failed: %v", err)
		}
	}

	// Run environment variable checks if specified
	if params.Checks.Env != nil && len(params.Checks.Env) > 0 {
		if err := checkEnvironmentVariables(t, resource, namespace, params.Checks.Env, tmplData); err != nil {
			t.Fatalf("Environment variable check failed: %v", err)
		}
	}

	// Run resource checks if specified
	if params.Checks.Resources != nil {
		if err := checkResources(t, resource, namespace, params.Checks.Resources); err != nil {
			t.Fatalf("Resource check failed: %v", err)
		}
	}

	fmt.Printf("All inspection checks passed for %s\n", resource)
}

// checkLogs verifies log content
func checkLogs(t *testing.T, resource string, namespace string, logChecks *LogChecks) error {
	fmt.Printf("Checking logs for %s...\n", resource)

	// Get logs from the resource
	cmd := exec.Command("oc", "logs", resource, "-n", namespace, "--tail=500")
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("failed to get logs: %w\nstderr: %s", err, stderr.String())
	}

	logs := stdout.String()

	// Check for required strings
	for _, required := range logChecks.Contains {
		if !strings.Contains(logs, required) {
			return fmt.Errorf("logs do not contain required string: %q", required)
		}
		fmt.Printf("  ✓ Found required string: %q\n", required)
	}

	// Check for forbidden strings
	for _, forbidden := range logChecks.NotContains {
		if strings.Contains(logs, forbidden) {
			return fmt.Errorf("logs contain forbidden string: %q", forbidden)
		}
		fmt.Printf("  ✓ Does not contain forbidden string: %q\n", forbidden)
	}

	// Check regex patterns
	for _, pattern := range logChecks.Matches {
		matched, err := regexp.MatchString(pattern, logs)
		if err != nil {
			return fmt.Errorf("invalid regex pattern %q: %w", pattern, err)
		}
		if !matched {
			return fmt.Errorf("logs do not match required pattern: %q", pattern)
		}
		fmt.Printf("  ✓ Matches required pattern: %q\n", pattern)
	}

	fmt.Printf("Log checks passed\n")
	return nil
}

// checkEnvironmentVariables verifies environment variables in the container
func checkEnvironmentVariables(t *testing.T, resource string, namespace string, expectedEnv map[string]string, tmplData TemplateData) error {
	fmt.Printf("Checking environment variables for %s...\n", resource)

	// Extract resource type and name
	parts := strings.Split(resource, "/")
	if len(parts) != 2 {
		return fmt.Errorf("invalid resource format, expected type/name, got: %s", resource)
	}
	resourceType := parts[0]
	_ = parts[1] // resourceName not used currently but kept for future use

	// Get environment variables from the resource
	var jsonPath string
	switch resourceType {
	case "deployment", "deploy":
		jsonPath = "{.spec.template.spec.containers[0].env}"
	case "deploymentconfig", "dc":
		jsonPath = "{.spec.template.spec.containers[0].env}"
	case "pod", "po":
		jsonPath = "{.spec.containers[0].env}"
	default:
		return fmt.Errorf("unsupported resource type for env check: %s", resourceType)
	}

	cmd := exec.Command("oc", "get", resource, "-n", namespace, "-o", "jsonpath="+jsonPath)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("failed to get environment variables: %w\nstderr: %s", err, stderr.String())
	}

	envOutput := stdout.String()

	// Check each expected environment variable
	for key, expectedValue := range expectedEnv {
		// Render expected value with template data
		renderedValue := renderTemplate(t, expectedValue, tmplData)

		// Look for the env var in the output (format: name:key value:val)
		searchPattern := fmt.Sprintf(`name:%s.*?value:%s`, key, regexp.QuoteMeta(renderedValue))
		matched, err := regexp.MatchString(searchPattern, envOutput)
		if err != nil {
			return fmt.Errorf("regex error checking env var %s: %w", key, err)
		}
		if !matched {
			// Try alternative format (just checking if key exists with any value)
			keyPattern := fmt.Sprintf(`name:%s`, key)
			keyMatched, _ := regexp.MatchString(keyPattern, envOutput)
			if !keyMatched {
				return fmt.Errorf("environment variable %s not found", key)
			}
			// Key exists but value might be different - let's try to extract and compare
			return fmt.Errorf("environment variable %s exists but value does not match %q", key, renderedValue)
		}
		fmt.Printf("  ✓ Environment variable %s = %q\n", key, renderedValue)
	}

	fmt.Printf("Environment variable checks passed\n")
	return nil
}

// checkResources verifies resource limits and requests
func checkResources(t *testing.T, resource string, namespace string, resourceChecks *ResourceChecks) error {
	fmt.Printf("Checking resource limits/requests for %s...\n", resource)

	// Extract resource type and name
	parts := strings.Split(resource, "/")
	if len(parts) != 2 {
		return fmt.Errorf("invalid resource format, expected type/name, got: %s", resource)
	}
	resourceType := parts[0]

	// Get resource limits and requests from the resource
	var jsonPath string
	switch resourceType {
	case "deployment", "deploy":
		jsonPath = "{.spec.template.spec.containers[0].resources}"
	case "deploymentconfig", "dc":
		jsonPath = "{.spec.template.spec.containers[0].resources}"
	case "pod", "po":
		jsonPath = "{.spec.containers[0].resources}"
	default:
		return fmt.Errorf("unsupported resource type for resource check: %s", resourceType)
	}

	cmd := exec.Command("oc", "get", resource, "-n", namespace, "-o", "jsonpath="+jsonPath)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("failed to get resource limits/requests: %w\nstderr: %s", err, stderr.String())
	}

	resourceOutput := stdout.String()

	// Check limits
	if resourceChecks.Limits != nil {
		if resourceChecks.Limits.CPU != "" {
			searchPattern := fmt.Sprintf(`limits:.*?cpu:%s`, regexp.QuoteMeta(resourceChecks.Limits.CPU))
			matched, _ := regexp.MatchString(searchPattern, resourceOutput)
			if !matched {
				return fmt.Errorf("CPU limit does not match expected value: %s", resourceChecks.Limits.CPU)
			}
			fmt.Printf("  ✓ CPU limit: %s\n", resourceChecks.Limits.CPU)
		}
		if resourceChecks.Limits.Memory != "" {
			searchPattern := fmt.Sprintf(`limits:.*?memory:%s`, regexp.QuoteMeta(resourceChecks.Limits.Memory))
			matched, _ := regexp.MatchString(searchPattern, resourceOutput)
			if !matched {
				return fmt.Errorf("Memory limit does not match expected value: %s", resourceChecks.Limits.Memory)
			}
			fmt.Printf("  ✓ Memory limit: %s\n", resourceChecks.Limits.Memory)
		}
	}

	// Check requests
	if resourceChecks.Requests != nil {
		if resourceChecks.Requests.CPU != "" {
			searchPattern := fmt.Sprintf(`requests:.*?cpu:%s`, regexp.QuoteMeta(resourceChecks.Requests.CPU))
			matched, _ := regexp.MatchString(searchPattern, resourceOutput)
			if !matched {
				return fmt.Errorf("CPU request does not match expected value: %s", resourceChecks.Requests.CPU)
			}
			fmt.Printf("  ✓ CPU request: %s\n", resourceChecks.Requests.CPU)
		}
		if resourceChecks.Requests.Memory != "" {
			searchPattern := fmt.Sprintf(`requests:.*?memory:%s`, regexp.QuoteMeta(resourceChecks.Requests.Memory))
			matched, _ := regexp.MatchString(searchPattern, resourceOutput)
			if !matched {
				return fmt.Errorf("Memory request does not match expected value: %s", resourceChecks.Requests.Memory)
			}
			fmt.Printf("  ✓ Memory request: %s\n", resourceChecks.Requests.Memory)
		}
	}

	fmt.Printf("Resource checks passed\n")
	return nil
}
