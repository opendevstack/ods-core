package steps

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"
	"testing"
	"time"
)

// Wait condition constants
const (
	WaitConditionPodReady           = "pod-ready"
	WaitConditionDeploymentComplete = "deployment-complete"
	WaitConditionJobComplete        = "job-complete"
	WaitConditionRouteAccessible    = "route-accessible"
	WaitConditionHTTPAccessible     = "http-accessible"
	WaitConditionLogContains        = "log-contains"
)

// ExecuteWait handles the wait step type for waiting on asynchronous operations.
func ExecuteWait(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, projectName string) {
	if step.WaitParams == nil {
		t.Fatal("Missing wait parameters")
	}

	params := step.WaitParams

	// Default namespace to {project}-dev
	namespace := params.Namespace
	if namespace == "" {
		namespace = fmt.Sprintf("%s-dev", projectName)
	}
	namespace = renderTemplate(t, namespace, tmplData)

	// Default timeout to 300s
	timeout := params.Timeout
	if timeout == "" {
		timeout = "300s"
	}
	timeoutDuration, err := time.ParseDuration(timeout)
	if err != nil {
		t.Fatalf("Invalid timeout duration: %s", timeout)
	}

	// Default interval to 5s
	interval := params.Interval
	if interval == "" {
		interval = "5s"
	}
	intervalDuration, err := time.ParseDuration(interval)
	if err != nil {
		t.Fatalf("Invalid interval duration: %s", interval)
	}

	fmt.Printf("Waiting for condition: %s (timeout: %s, interval: %s)\n", params.Condition, timeout, interval)

	// Execute the wait based on condition type
	switch params.Condition {
	case WaitConditionPodReady:
		if err := waitForPodReady(t, params, namespace, tmplData, timeoutDuration, intervalDuration); err != nil {
			t.Fatal(err)
		}
	case WaitConditionDeploymentComplete:
		if err := waitForDeploymentComplete(t, params, namespace, tmplData, timeoutDuration, intervalDuration); err != nil {
			t.Fatal(err)
		}
	case WaitConditionJobComplete:
		if err := waitForJobComplete(t, params, namespace, tmplData, timeoutDuration, intervalDuration); err != nil {
			t.Fatal(err)
		}
	case WaitConditionRouteAccessible:
		if err := waitForRouteAccessible(t, params, namespace, tmplData, timeoutDuration, intervalDuration); err != nil {
			t.Fatal(err)
		}
	case WaitConditionHTTPAccessible:
		if err := waitForHTTPAccessible(t, params, tmplData, timeoutDuration, intervalDuration); err != nil {
			t.Fatal(err)
		}
	case WaitConditionLogContains:
		if err := waitForLogContains(t, params, namespace, tmplData, timeoutDuration, intervalDuration); err != nil {
			t.Fatal(err)
		}
	default:
		t.Fatalf("Unknown wait condition: %s", params.Condition)
	}

	fmt.Printf("Condition met: %s\n", params.Condition)
}

// waitForPodReady waits for pods to be ready
func waitForPodReady(t *testing.T, params *TestStepWaitParams, namespace string, tmplData TemplateData, timeout, interval time.Duration) error {
	resource := renderTemplate(t, params.Resource, tmplData)

	fmt.Printf("Waiting for pod to be ready: %s in namespace %s\n", resource, namespace)

	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		// Use oc wait command
		fmt.Printf("Executing command: oc wait --for=condition=Ready %s -n %s --timeout=%s\n", resource, namespace, interval.String())
		cmd := exec.Command("oc", "wait", "--for=condition=Ready", "pod", resource,
			"-n", namespace,
			"--timeout="+interval.String())

		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr

		err := cmd.Run()
		if err == nil {
			return nil
		}

		// Check if it's a timeout (continue waiting) or a real error
		if !strings.Contains(stderr.String(), "timed out") {
			fmt.Printf("Warning: %s (retrying...)\n", stderr.String())
		}

		time.Sleep(interval)
	}

	return fmt.Errorf("timeout waiting for pod to be ready: %s", resource)
}

// waitForDeploymentComplete waits for a deployment to complete
func waitForDeploymentComplete(t *testing.T, params *TestStepWaitParams, namespace string, tmplData TemplateData, timeout, interval time.Duration) error {
	resource := renderTemplate(t, params.Resource, tmplData)

	fmt.Printf("Waiting for deployment to complete: %s in namespace %s\n", resource, namespace)

	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		// Check deployment status
		cmd := exec.Command("oc", "rollout", "status", resource,
			"-n", namespace,
			"--timeout="+interval.String())

		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr

		err := cmd.Run()
		if err == nil {
			return nil
		}

		time.Sleep(interval)
	}

	return fmt.Errorf("timeout waiting for deployment to complete: %s", resource)
}

// waitForJobComplete waits for a job to complete
func waitForJobComplete(t *testing.T, params *TestStepWaitParams, namespace string, tmplData TemplateData, timeout, interval time.Duration) error {
	resource := renderTemplate(t, params.Resource, tmplData)

	fmt.Printf("Waiting for job to complete: %s in namespace %s\n", resource, namespace)

	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		cmd := exec.Command("oc", "wait", "--for=condition=complete", resource,
			"-n", namespace,
			"--timeout="+interval.String())

		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr

		err := cmd.Run()
		if err == nil {
			return nil
		}

		time.Sleep(interval)
	}

	return fmt.Errorf("timeout waiting for job to complete: %s", resource)
}

// waitForRouteAccessible waits for a route to be accessible
func waitForRouteAccessible(t *testing.T, params *TestStepWaitParams, namespace string, tmplData TemplateData, timeout, interval time.Duration) error {
	resource := renderTemplate(t, params.Resource, tmplData)

	// Extract route name from resource (e.g., "route/myapp" -> "myapp")
	routeName := resource
	if strings.Contains(resource, "/") {
		parts := strings.Split(resource, "/")
		routeName = parts[len(parts)-1]
	}

	fmt.Printf("Waiting for route to be accessible: %s in namespace %s\n", routeName, namespace)

	// First, wait for the route to exist
	deadline := time.Now().Add(timeout)
	var routeURL string

	for time.Now().Before(deadline) {
		cmd := exec.Command("oc", "get", "route", routeName,
			"-n", namespace,
			"-o", "jsonpath={.spec.host}")

		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr

		err := cmd.Run()
		if err == nil && stdout.String() != "" {
			routeURL = "http://" + stdout.String()
			break
		}

		time.Sleep(interval)
	}

	if routeURL == "" {
		return fmt.Errorf("timeout waiting for route to exist: %s", routeName)
	}

	// Now wait for the route to be HTTP accessible
	return waitForHTTPURL(routeURL, timeout, interval)
}

// waitForHTTPAccessible waits for an HTTP endpoint to be accessible
func waitForHTTPAccessible(t *testing.T, params *TestStepWaitParams, tmplData TemplateData, timeout, interval time.Duration) error {
	url := renderTemplate(t, params.URL, tmplData)

	fmt.Printf("Waiting for HTTP endpoint to be accessible: %s\n", url)

	return waitForHTTPURL(url, timeout, interval)
}

// waitForHTTPURL is a helper that polls an HTTP URL until it responds
func waitForHTTPURL(url string, timeout, interval time.Duration) error {
	deadline := time.Now().Add(timeout)

	for time.Now().Before(deadline) {
		// Use curl to test the endpoint
		cmd := exec.Command("curl", "-f", "-s", "-o", "/dev/null", "-w", "%{http_code}", url)

		var stdout bytes.Buffer
		cmd.Stdout = &stdout

		err := cmd.Run()
		if err == nil {
			statusCode := stdout.String()
			// Accept any 2xx or 3xx status code
			if strings.HasPrefix(statusCode, "2") || strings.HasPrefix(statusCode, "3") {
				fmt.Printf("HTTP endpoint is accessible: %s (status: %s)\n", url, statusCode)
				return nil
			}
		}

		time.Sleep(interval)
	}

	return fmt.Errorf("timeout waiting for HTTP endpoint to be accessible: %s", url)
}

// waitForLogContains waits for a specific log message to appear
func waitForLogContains(t *testing.T, params *TestStepWaitParams, namespace string, tmplData TemplateData, timeout, interval time.Duration) error {
	resource := renderTemplate(t, params.Resource, tmplData)
	message := renderTemplate(t, params.Message, tmplData)

	fmt.Printf("Waiting for log message in %s: %q\n", resource, message)

	deadline := time.Now().Add(timeout)

	for time.Now().Before(deadline) {
		cmd := exec.Command("oc", "logs", resource, "-n", namespace, "--tail=100")

		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr

		err := cmd.Run()
		if err == nil && strings.Contains(stdout.String(), message) {
			fmt.Printf("Log message found: %q\n", message)
			return nil
		}

		time.Sleep(interval)
	}

	return fmt.Errorf("timeout waiting for log message: %q in %s", message, resource)
}
