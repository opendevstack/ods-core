package quickstarter

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"strings"

	"github.com/ghodss/yaml"
	"github.com/opendevstack/ods-core/tests/utils"
)

// TestSteps defines the steps the test runner should execute.
type TestSteps struct {
	// Name of the component to provision
	ComponentID string `json:"componentID"`
	// Steps to execute
	Steps []TestStep `json:"steps"`
}

// TestStep describes one step to execute. A step consists of a type (e.g.
// "build"), and the related params for it (e.g. "buildParams").
type TestStep struct {
	// Type of the step - one of "build", "provision", "upload"
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
}

// TestStepUploadParams defines the parameters for the "provision" step type.
type TestStepRunParams struct {
	// File to execute relative to "testdata" directory
	File string `json:"file"`
}

// TestStepUploadParams defines the parameters for the "provision" step type.
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
}

// TestStepBuildParams defines the parameters for the "build" step type.
type TestStepBuildParams TestStepProvisionParams

// TestStepVerify defines the items to verify.
type TestStepVerify struct {
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
	} `json:"openShiftResources"`
}

// TemplateData holds template parameters. Those will be applied to all
// values defined in the steps, as they are treated as Go templates.
// For example, Jenkins run attachments can be defined like this:
//
//	runAttachments:
//	- SCRR-{{.ProjectID}}-{{.ComponentID}}.docx, and then the
type TemplateData struct {
	// Project ID (the prefix of the *-cd, *-dev and *-test namespaces).
	ProjectID string
	// Component ID (the value of the overall "componentID" or the specific
	// step  "componentID").
	ComponentID string
	// ODS namespace read from the ods-core.env configuration (e.g. "ods")
	OdsNamespace string
	// ODS Git reference read from the ods-core.env configuration (e.g. "v3.0.0")
	OdsGitRef string
	// ODS image tag read from the ods-core.env configuration (e.g. "3.x")
	OdsImageTag string
	// ODS Bitbucket project name read from the ods-core.env configuration (e.g. "OPENDEVSTACK")
	OdsBitbucketProject string
	// ODS Git reference with underscores instead of slashes and dashes.
	SanitizedOdsGitRef string
	// Jenkins Build number
	BuildNumber string
	// Name of the Sonar Quality Profile
	SonarQualityProfile string
	// Is enable Aqua
	AquaEnabled bool
}

// readSteps reads "steps.yml" in given folder.
// It does not allow extra fields to avoid typos, and checks if the given
// step types are known.
func readSteps(folder string) (*TestSteps, error) {
	yamlContent, err := ioutil.ReadFile(folder + "/steps.yml")
	if err != nil {
		return nil, fmt.Errorf("Cannot read file: %w", err)
	}

	var s TestSteps
	jsonContent, err := yaml.YAMLToJSON(yamlContent)
	if err != nil {
		return nil, fmt.Errorf("Could not parse YAML: %v", err)
	}
	dec := json.NewDecoder(bytes.NewReader(jsonContent))
	dec.DisallowUnknownFields() // Force errors
	if err := dec.Decode(&s); err != nil {
		return nil, fmt.Errorf("Could not parse steps: %v", err)
	}
	// A poor man's workaround for missing enums in Go. There are better ways
	// to do it, but nothing as simple as this.
	allowedTypes := map[string]bool{"provision": true, "build": true, "upload": true, "run": true}
	for i, step := range s.Steps {
		if _, ok := allowedTypes[step.Type]; !ok {
			allowed := []string{}
			for k := range allowedTypes {
				allowed = append(allowed, k)
			}
			return nil, fmt.Errorf(
				"Step %d has unknown type %s. Allowed types are: %s",
				i,
				step.Type,
				strings.Join(allowed, ", "),
			)
		}
	}
	return &s, nil
}
