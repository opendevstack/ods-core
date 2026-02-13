package steps

import (
	"fmt"
	"sync"
	"testing"
)

// Registry Pattern for Step Execution
//
// The test framework uses a registry pattern to manage step handlers, making it easy to
// add new step types without modifying the core test execution logic.
//
// To add a new step type:
//
//  1. Define a step type constant in types.go:
//     const StepTypeMyCustom = "my-custom"
//
//  2. Add parameters struct to types.go (if needed):
//     type MyCustomParams struct {
//         Target string `json:"target"`
//     }
//
//  3. Add params field to TestStep in types.go:
//     MyCustomParams *MyCustomParams `json:"myCustomParams,omitempty"`
//
//  4. Implement execution logic in my_custom.go:
//     func ExecuteMyCustom(t *testing.T, step TestStep, ...) {
//         // Your implementation here
//     }
//
//  5. Create handler adapter below:
//     type MyCustomHandler struct{}
//     func (h *MyCustomHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
//         ExecuteMyCustom(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
//         return nil
//     }
//
//  6. Register in registerDefaultHandlers():
//     defaultRegistry.Register(StepTypeMyCustom, &MyCustomHandler{})
//
// See QUICKSTARTERS_TESTS.md section "Developing Custom Step Types" for complete guide.

// ExecutionParams consolidates all parameters needed for step execution.
// This struct provides a unified interface for passing context to step handlers,
// making it easier to add new parameters without changing handler signatures.
//
// When adding new commonly-needed parameters, extend this struct rather than
// changing individual step function signatures.
type ExecutionParams struct {
	TestdataPath     string            // Path to the testdata directory
	TmplData         TemplateData      // Template variables for rendering
	RepoName         string            // Repository name (format: project-component)
	QuickstarterRepo string            // Quickstarter repository name
	QuickstarterName string            // Quickstarter name
	Config           map[string]string // Configuration key-value pairs
	ProjectName      string            // OpenShift project name
}

// StepHandler defines the interface that all step handlers must implement.
// This allows for a clean registry pattern where steps can be registered
// and executed polymorphically.
//
// Implementations should delegate to specific Execute* functions (e.g., ExecuteUpload,
// ExecuteRun) which contain the actual step logic.
type StepHandler interface {
	// Execute runs the step logic with the given parameters.
	// Returns an error if the step execution fails.
	Execute(t *testing.T, step *TestStep, params *ExecutionParams) error
}

// StepRegistry manages the mapping of step types to their handlers.
// It provides thread-safe registration and retrieval of step handlers,
// enabling a plugin-like architecture for step types.
type StepRegistry struct {
	handlers map[string]StepHandler
	mu       sync.RWMutex
}

// NewStepRegistry creates a new empty step registry.
func NewStepRegistry() *StepRegistry {
	return &StepRegistry{
		handlers: make(map[string]StepHandler),
	}
}

// Register adds a handler for a specific step type.
// If a handler already exists for the given type, it will be overwritten.
func (r *StepRegistry) Register(stepType string, handler StepHandler) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.handlers[stepType] = handler
}

// Get retrieves the handler for a specific step type.
// Returns an error if no handler is registered for the given type.
func (r *StepRegistry) Get(stepType string) (StepHandler, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	handler, ok := r.handlers[stepType]
	if !ok {
		return nil, fmt.Errorf("unknown step type: %s", stepType)
	}
	return handler, nil
}

// defaultRegistry is the global registry instance used throughout the application.
var (
	defaultRegistry *StepRegistry
	once            sync.Once
)

// DefaultRegistry returns the singleton global step registry.
func DefaultRegistry() *StepRegistry {
	once.Do(func() {
		defaultRegistry = NewStepRegistry()
		registerDefaultHandlers()
	})
	return defaultRegistry
}

// registerDefaultHandlers registers all built-in step handlers.
//
// To add a new step type, add a registration line here:
//
//	defaultRegistry.Register(StepTypeMyCustom, &MyCustomHandler{})
//
// Make sure your handler implements the StepHandler interface.
func registerDefaultHandlers() {
	defaultRegistry.Register(StepTypeUpload, &UploadHandler{})
	defaultRegistry.Register(StepTypeRun, &RunHandler{})
	defaultRegistry.Register(StepTypeProvision, &ProvisionHandler{})
	defaultRegistry.Register(StepTypeBuild, &BuildHandler{})
	defaultRegistry.Register(StepTypeHTTP, &HTTPHandler{})
	defaultRegistry.Register(StepTypeWait, &WaitHandler{})
	defaultRegistry.Register(StepTypeInspect, &InspectHandler{})
	defaultRegistry.Register(StepTypeExposeService, &ExposeServiceHandler{})
	defaultRegistry.Register(StepTypeBitbucket, &BitbucketHandler{})
}

// Handler Implementations
//
// Each handler below implements the StepHandler interface by delegating to
// its corresponding Execute* function. The handler adapter pattern allows us
// to maintain the existing function signatures while integrating with the
// registry pattern.

// UploadHandler implements the handler for upload steps.
type UploadHandler struct{}

func (h *UploadHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteUpload(t, *step, params.TestdataPath, params.TmplData, params.RepoName, params.Config, params.ProjectName)
	return nil
}

// RunHandler implements the handler for run steps.
type RunHandler struct{}

func (h *RunHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteRun(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
	return nil
}

// ProvisionHandler implements the handler for provision steps.
type ProvisionHandler struct{}

func (h *ProvisionHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteProvision(t, *step, params.TestdataPath, params.TmplData, params.RepoName, params.QuickstarterRepo, params.QuickstarterName, params.Config, params.ProjectName)
	return nil
}

// BuildHandler implements the handler for build steps.
type BuildHandler struct{}

func (h *BuildHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteBuild(t, *step, params.TestdataPath, params.TmplData, params.RepoName, params.Config, params.ProjectName)
	return nil
}

// HTTPHandler implements the handler for HTTP steps.
type HTTPHandler struct{}

func (h *HTTPHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteHTTP(t, *step, params.TestdataPath, params.TmplData)
	return nil
}

// WaitHandler implements the handler for wait steps.
type WaitHandler struct{}

func (h *WaitHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteWait(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
	return nil
}

// InspectHandler implements the handler for inspect steps.
type InspectHandler struct{}

func (h *InspectHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteInspect(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
	return nil
}

// ExposeServiceHandler implements the handler for expose-service steps.
type ExposeServiceHandler struct{}

func (h *ExposeServiceHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteExposeService(t, *step, params.TmplData, params.ProjectName)
	return nil
}

// BitbucketHandler implements the handler for bitbucket steps.
type BitbucketHandler struct{}

func (h *BitbucketHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
	ExecuteBitbucket(t, *step, params.TmplData, params.Config, params.ProjectName, params.TestdataPath)
	return nil
}
