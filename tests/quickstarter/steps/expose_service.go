package steps

import (
	"fmt"
	"testing"
	"time"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
)

// ExecuteExposeService handles the expose-service step type.
// This step explicitly exposes services by setting up routes or port-forwards
// based on the execution environment.
func ExecuteExposeService(t *testing.T, step TestStep, tmplData TemplateData, projectName string) {
	if step.ExposeServiceParams == nil || len(step.ExposeServiceParams.Services) == 0 {
		t.Fatalf("Missing expose-service parameters: no services defined")
	}

	logger.SubSection(fmt.Sprintf("Exposing %d service(s)", len(step.ExposeServiceParams.Services)))

	for i, svcConfig := range step.ExposeServiceParams.Services {
		logger.Step(i+1, len(step.ExposeServiceParams.Services), "expose-service", fmt.Sprintf("Expose service: %s", svcConfig.ServiceName))

		// Render namespace template (defaults to projectName-dev)
		namespace := svcConfig.Namespace
		if namespace == "" {
			namespace = fmt.Sprintf("%s-dev", projectName)
		} else {
			namespace = renderTemplate(t, namespace, tmplData)
		}

		// Default port
		port := svcConfig.Port
		if port == "" {
			port = "8080"
		}

		// Render service name template
		serviceName := renderTemplate(t, svcConfig.ServiceName, tmplData)

		// Wait for service to exist before attempting to expose
		logger.Waiting(fmt.Sprintf("Service %s/%s to be ready", namespace, serviceName))
		err := WaitForServiceReady(serviceName, namespace, 120*time.Second)
		if err != nil {
			logger.Failure(fmt.Sprintf("Service ready check: %s/%s", namespace, serviceName), err)
			t.Fatalf("Service not ready: %v", err)
		}

		// Construct and resolve the service URL
		serviceURL := ConstructServiceURL(serviceName, namespace, port, "")
		resolvedURL := ResolveServiceURL(t, serviceURL, tmplData)

		logger.Success(fmt.Sprintf("Service exposed and accessible at: %s", resolvedURL))

		// Store the resolved URL in template data for use by subsequent steps
		// This allows scripts in "run" steps to access the exposed service
		serviceKey := fmt.Sprintf("ExposedService_%s", serviceName)
		tmplData[serviceKey] = resolvedURL
	}

	logger.Success("All services exposed successfully")
}
