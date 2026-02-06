package quickstarter

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/ghodss/yaml"
	"github.com/opendevstack/ods-core/tests/quickstarter/steps"
)

// TestSteps defines the steps the test runner should execute.
type TestSteps struct {
	// Name of the component to provision
	ComponentID string `json:"componentID"`
	// Steps to execute
	Steps []steps.TestStep `json:"steps"`
}

// readSteps reads "steps.yml" in given folder.
// It does not allow extra fields to avoid typos, and checks if the given
// step types are known.
func readSteps(folder string) (*TestSteps, error) {
	yamlContent, err := os.ReadFile(folder + "/steps.yml")
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
	allowedTypes := map[string]bool{
		steps.StepTypeProvision:     true,
		steps.StepTypeBuild:         true,
		steps.StepTypeUpload:        true,
		steps.StepTypeRun:           true,
		steps.StepTypeHTTP:          true,
		steps.StepTypeWait:          true,
		steps.StepTypeInspect:       true,
		steps.StepTypeExposeService: true,
		steps.StepTypeBitbucket:     true,
	}

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
