package steps

import (
	"bytes"
	"testing"
	"text/template"

	"github.com/opendevstack/ods-core/tests/utils"
)

// Step type constants
const (
	StepTypeUpload    = "upload"
	StepTypeRun       = "run"
	StepTypeProvision = "provision"
	StepTypeBuild     = "build"
	StepTypeHTTP      = "http"
	StepTypeWait      = "wait"
	StepTypeInspect   = "inspect"
)

// Default values
const (
	DefaultBranch      = "master"
	DefaultJenkinsfile = "Jenkinsfile"
	DefaultNamespace   = "dev"
)

// Verification strategies
const (
	VerifyStrategyAggregate = "aggregate"
	VerifyStrategyFailFast  = "fail-fast"
)

// TestStep describes one step to execute. A step consists of a type (e.g.
// "build"), and the related params for it (e.g. "buildParams").
type TestStep struct {
	// Type of the step - one of "build", "provision", "upload", "run", "http", "wait"
	Type string `json:"type"`
	// Optional description to explain the step's purpose
	Description string `json:"description"`
	// ComponentID name for that step (overwrites global component name)
	ComponentID string `json:"componentID"`
	// Parameters for "provison" step type
	ProvisionParams *TestStepProvisionParams `json:"provisionParams"`
	// Parameters for "build" step type
	BuildParams *TestStepBuildParams `json:"buildParams"`
	// Parameters for "upload" step type
	UploadParams *TestStepUploadParams `json:"uploadParams"`
	// Parameters for "run" step type
	RunParams *TestStepRunParams `json:"runParams"`
	// Parameters for "http" step type
	HTTPParams *TestStepHTTPParams `json:"httpParams"`
	// Parameters for "wait" step type
	WaitParams *TestStepWaitParams `json:"waitParams"`
	// Parameters for "inspect" step type
	InspectParams *TestStepInspectParams `json:"inspectParams"`
}

// TestStepRunParams defines the parameters for the "run" step type.
type TestStepRunParams struct {
	// File to execute relative to "testdata" directory
	File string `json:"file"`
}

// TestStepUploadParams defines the parameters for the "upload" step type.
type TestStepUploadParams struct {
	// File to add, commit and push to the repository (relative to "testdata" directory)
	File string `json:"file"`
	// Name of the uploaded file in the repository. Defaults to just the filename of +File+.
	Filename string `json:"filename"`
	// In case this is a template file that we want to render.
	Render bool `json:"render"`
	// In case we want to override the repository, it is relative to the project where we run it.
	Repository string `json:"repository"`
}

// TestStepProvisionParams defines the parameters for the "provision" step type.
type TestStepProvisionParams struct {
	// Name of the quickstarter to provision.
	Quickstarter string `json:"quickstarter"`
	// Pipeline allows to customize the pipeline name.
	// If empty, the pipeline name is generated.
	Pipeline string `json:"pipeline"`
	// Quickstarter branch for which to run the pipeline.
	// For "provision" steps, it defaults to ODS_GIT_REF.
	// For "build" steps, it defaults to "master".
	Branch string `json:"branch"`
	// Jenkins Agent image tag.
	// Defaults to ODS_IMAGE_TAG.
	AgentImageTag string `json:"agentImageTag"`
	// Jenkins Shared library Git reference.
	// Defaults to AgentImageTag.
	SharedLibraryRef string `json:"sharedLibraryRef"`
	// Additional environment variables
	Env []utils.EnvPair `json:"env"`
	// Verify parameters.
	Verify *TestStepVerify `json:"verify"`
	// In case we want to override the repository, it is relative to the project where we run it.
	Repository string `json:"repository"`
	// Extra resources to remove
	TestResourcesCleanUp []struct {
		// Type of the resource
		ResourceType string `json:"resourceType"`
		// Name of the resource
		ResourceName string `json:"resourceName"`
		// Namespace
		Namespace string `json:"namespace"`
	} `json:"testResourcesCleanUp"`
}

// TestStepBuildParams defines the parameters for the "build" step type.
type TestStepBuildParams TestStepProvisionParams

// TestStepHTTPParams defines the parameters for the "http" step type.
type TestStepHTTPParams struct {
	// URL to test (supports templating)
	URL string `json:"url"`
	// HTTP method (GET, POST, PUT, DELETE, etc.)
	Method string `json:"method"`
	// Request headers
	Headers map[string]string `json:"headers"`
	// Request body
	Body string `json:"body"`
	// Expected HTTP status code
	ExpectedStatus int `json:"expectedStatus"`
	// Path to golden file with expected response body (relative to "testdata" directory)
	ExpectedBody string `json:"expectedBody"`
	// JSONPath assertions
	Assertions []HTTPAssertion `json:"assertions"`
	// Timeout in seconds
	Timeout int `json:"timeout"`
	// Retry configuration
	Retry *HTTPRetry `json:"retry"`
}

// HTTPAssertion defines a JSONPath-based assertion
type HTTPAssertion struct {
	// JSONPath expression
	Path string `json:"path"`
	// Expected value (exact match)
	Equals interface{} `json:"equals"`
	// Check if path exists
	Exists *bool `json:"exists"`
	// Check if value contains string
	Contains string `json:"contains"`
	// Check if value matches regex
	Matches string `json:"matches"`
}

// HTTPRetry defines retry configuration for HTTP requests
type HTTPRetry struct {
	// Number of retry attempts
	Attempts int `json:"attempts"`
	// Delay between retries (e.g., "2s", "500ms")
	Delay string `json:"delay"`
}

// TestStepWaitParams defines the parameters for the "wait" step type.
type TestStepWaitParams struct {
	// Type of wait condition
	Condition string `json:"condition"`
	// Resource to wait for (for OpenShift resources)
	Resource string `json:"resource"`
	// URL to wait for (for http-accessible condition)
	URL string `json:"url"`
	// Log message to wait for (for log-contains condition)
	Message string `json:"message"`
	// Namespace (defaults to {{.ProjectID}}-dev)
	Namespace string `json:"namespace"`
	// Timeout duration (e.g., "300s", "5m")
	Timeout string `json:"timeout"`
	// Polling interval (e.g., "5s")
	Interval string `json:"interval"`
}

// TestStepInspectParams defines the parameters for the "inspect" step type.
type TestStepInspectParams struct {
	// Resource to inspect (e.g., "deployment/my-app", "pod/my-pod")
	Resource string `json:"resource"`
	// Namespace (defaults to {{.ProjectID}}-dev)
	Namespace string `json:"namespace"`
	// Checks to perform
	Checks *InspectChecks `json:"checks"`
}

// InspectChecks defines what to check in the container
type InspectChecks struct {
	// Log content checks
	Logs *LogChecks `json:"logs"`
	// Environment variable checks
	Env map[string]string `json:"env"`
	// Resource limit checks
	Resources *ResourceChecks `json:"resources"`
}

// LogChecks defines log content assertions
type LogChecks struct {
	// Log should contain these strings
	Contains []string `json:"contains"`
	// Log should NOT contain these strings
	NotContains []string `json:"notContains"`
	// Log should match these regex patterns
	Matches []string `json:"matches"`
}

// ResourceChecks defines resource limit/request checks
type ResourceChecks struct {
	// Resource limits
	Limits *ResourceValues `json:"limits"`
	// Resource requests
	Requests *ResourceValues `json:"requests"`
}

// ResourceValues defines CPU and memory values
type ResourceValues struct {
	CPU    string `json:"cpu"`
	Memory string `json:"memory"`
}

// TestStepVerify defines the items to verify.
type TestStepVerify struct {
	// Verification strategy: "aggregate" (default) collects all failures; "fail-fast" stops on first.
	Strategy string `json:"strategy"`
	// JSON file defining expected Jenkins stages (relative to "testdata" directory).
	JenkinsStages string `json:"jenkinsStages"`
	// JSON file defining expected Sonar scan result (relative to "testdata" directory).
	SonarScan string `json:"sonarScan"`
	// Names of expected attachments to the Jenkins run.
	RunAttachments []string `json:"runAttachments"`
	// Number of expected test results.
	TestResults int `json:"testResults"`
	// Expected OpenShift resources in the *-dev namespace.
	OpenShiftResources *struct {
		// Namespace in which to look for resources (defaults to *-dev).
		Namespace string `json:"namespace"`
		// Image tags
		ImageTags []struct {
			// Name of the image
			Name string `json:"name"`
			// Tag of the image
			Tag string `json:"tag"`
		} `json:"imageTags"`
		// BuildConfig resources
		BuildConfigs []string `json:"buildConfigs"`
		// ImageStream resources
		ImageStreams []string `json:"imageStreams"`
		// DeploymentConfig resources
		DeploymentConfigs []string `json:"deploymentConfigs"`
		// Service resources. The check includes verifying that a running, ready pod is assigned.
		Services []string `json:"services"`
		// Route resources
		Routes []string `json:"routes"`
		// ConfigMap resources
		ConfigMaps []string `json:"configMaps"`
		// Secret resources
		Secrets []string `json:"secrets"`
		// PersistentVolumeClaim resources
		PersistentVolumeClaims []string `json:"persistentVolumeClaims"`
		// ServiceAccount resources
		ServiceAccounts []string `json:"serviceAccounts"`
		// RoleBinding resources
		RoleBindings []string `json:"roleBindings"`
	} `json:"openShiftResources"`
}

// TemplateData holds template parameters. Those will be applied to all
// values defined in the steps, as they are treated as Go templates.
type TemplateData map[string]interface{}

// renderTemplate applies template data to a template string
func renderTemplate(t *testing.T, tpl string, tmplData TemplateData) string {
	var buffer bytes.Buffer
	tmpl, err := template.New("template").Parse(tpl)
	if err != nil {
		t.Fatalf("Error parsing template: %s", err)
	}
	tmplErr := tmpl.Execute(&buffer, tmplData)
	if tmplErr != nil {
		t.Fatalf("Error rendering template: %s", tmplErr)
	}
	return buffer.String()
}

// renderTemplates applies template data to multiple template strings
func renderTemplates(t *testing.T, tpls []string, tmplData TemplateData) []string {
	rendered := []string{}
	for _, tpl := range tpls {
		rendered = append(rendered, renderTemplate(t, tpl, tmplData))
	}
	return rendered
}
