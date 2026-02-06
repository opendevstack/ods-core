package diagnostics

import (
	"context"
	"fmt"
	"time"
)

// FailureContext captures diagnostic information about a test failure.
type FailureContext struct {
	StepIndex   int
	StepType    string
	Message     string
	Timestamp   time.Time
	Pod         *PodInfo
	Events      []EventInfo
	Logs        []string
	Environment map[string]string
	Suggestion  string
}

// PodInfo contains information about a Kubernetes pod.
type PodInfo struct {
	Name            string
	Namespace       string
	Phase           string
	ContainerStates []ContainerState
	Conditions      []PodCondition
}

// ContainerState represents the state of a container
type ContainerState struct {
	Name    string
	State   string
	Message string
}

// PodCondition represents a pod condition
type PodCondition struct {
	Type    string
	Status  string
	Reason  string
	Message string
}

// EventInfo represents a Kubernetes event
type EventInfo struct {
	Name      string
	Namespace string
	Type      string
	Reason    string
	Message   string
	Timestamp time.Time
	Count     int32
}

// DiagnosticsCollector collects diagnostic information on test failures.
type DiagnosticsCollector struct {
	ctx context.Context
}

// NewDiagnosticsCollector creates a new diagnostics collector.
func NewDiagnosticsCollector(ctx context.Context) *DiagnosticsCollector {
	return &DiagnosticsCollector{ctx: ctx}
}

// CaptureFailureContext captures all available diagnostic information about a failure.
// This is a placeholder implementation - actual integration would require kubectl/oc calls.
func (dc *DiagnosticsCollector) CaptureFailureContext(
	stepIndex int,
	stepType string,
	namespace string,
	resourceName string,
	err error,
) *FailureContext {
	ctx := &FailureContext{
		StepIndex:   stepIndex,
		StepType:    stepType,
		Message:     err.Error(),
		Timestamp:   time.Now(),
		Environment: make(map[string]string),
	}

	// In a real implementation, this would:
	// 1. Query pod status and conditions
	// 2. Retrieve recent events
	// 3. Capture container logs
	// 4. Analyze failure patterns and suggest fixes

	ctx.Suggestion = dc.suggestFix(stepType, err)

	return ctx
}

// suggestFix provides actionable suggestions based on failure type and step type.
func (dc *DiagnosticsCollector) suggestFix(stepType string, err error) string {
	_ = err.Error() // Reserved for future error pattern matching

	suggestions := map[string][]string{
		"provision": {
			"Check Jenkins logs: oc logs -f <jenkins-pod>",
			"Verify Bitbucket credentials and repository access",
			"Ensure the quickstarter is properly configured",
		},
		"build": {
			"Check Jenkins build logs for details",
			"Verify build resources are available",
			"Check container image availability and pull secrets",
		},
		"http": {
			"Verify the service is running: kubectl get pods -l app=<name>",
			"Check service endpoints: kubectl get endpoints <service>",
			"Verify network policies are not blocking access",
			"Check firewall rules if accessing from external network",
		},
		"wait": {
			"Check pod status: kubectl describe pod <name>",
			"Review pod events: kubectl get events --sort-by='.lastTimestamp'",
			"Check resource requests/limits match available resources",
			"Increase timeout if deployment takes longer",
		},
		"inspect": {
			"Verify the resource exists: kubectl get <resource>",
			"Check container logs: kubectl logs <pod>",
			"Inspect resource configuration: kubectl describe <resource>",
		},
	}

	if suggestions, ok := suggestions[stepType]; ok {
		return fmt.Sprintf("Troubleshooting steps:\n  - %s", fmt.Sprintf("%v", suggestions))
	}

	return "Check step configuration and related resource status"
}

// IsTransientError determines if an error is likely transient (can be retried).
func IsTransientError(err error) bool {
	if err == nil {
		return false
	}

	errMsg := err.Error()

	// Common transient error patterns
	transientPatterns := []string{
		"timeout",
		"temporarily unavailable",
		"connection refused",
		"connection reset",
		"EOF",
		"broken pipe",
		"i/o timeout",
	}

	for _, pattern := range transientPatterns {
		if contains(errMsg, pattern) {
			return true
		}
	}

	return false
}

// contains checks if a string contains a substring (case-insensitive).
func contains(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
