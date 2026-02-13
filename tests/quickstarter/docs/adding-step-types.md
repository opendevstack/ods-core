# Adding New Step Types - Quick Reference

This is a condensed guide for adding new step types to the quickstarter test framework. For comprehensive documentation, see the "Developing Custom Step Types" section in [QUICKSTARTERS_TESTS.md](../QUICKSTARTERS_TESTS.md).

## Quick Start Checklist

- [ ] 1. Add step type constant to `steps/types.go`
- [ ] 2. Add parameters struct to `steps/types.go` (if needed)
- [ ] 3. Add params field to `TestStep` struct in `steps/types.go`
- [ ] 4. Create `steps/my_step.go` with `ExecuteMyStep()` function
- [ ] 5. Add handler adapter to `steps/registry.go`
- [ ] 6. Register handler in `registerDefaultHandlers()` in `steps/registry.go`
- [ ] 7. Create documentation in `docs/steps/my-step.md`
- [ ] 8. Update step overview in `docs/steps.md`
- [ ] 9. Write tests in `steps/my_step_test.go`
- [ ] 10. Test in a real `testdata/steps.yml`

## Code Templates

### 1. Step Type Constant (`steps/types.go`)

```go
const (
    // ... existing types ...
    StepTypeMyStep = "my-step"
)
```

### 2. Parameters Struct (`steps/types.go`)

```go
// MyStepParams defines parameters for the my-step step type.
type MyStepParams struct {
    Target   string   `json:"target"`
    Options  []string `json:"options,omitempty"`
    Timeout  int      `json:"timeout,omitempty"`
}
```

### 3. Add to TestStep (`steps/types.go`)

```go
type TestStep struct {
    // ... existing fields ...
    MyStepParams *MyStepParams `json:"myStepParams,omitempty"`
}
```

### 4. Implementation (`steps/my_step.go`)

```go
package steps

import (
    "fmt"
    "testing"
)

// ExecuteMyStep handles the my-step step type.
func ExecuteMyStep(t *testing.T, step TestStep, testdataPath string, 
                   tmplData TemplateData, projectName string) {
    
    // Validate parameters
    if step.MyStepParams == nil {
        t.Fatalf("Missing my-step parameters")
    }
    
    params := step.MyStepParams
    
    // Render templates
    target := RenderTemplate(t, params.Target, tmplData)
    
    // Implement logic
    fmt.Printf("Executing my-step on target: %s\n", target)
    
    // ... your implementation here ...
    
    // Fail on error
    if err != nil {
        t.Fatalf("my-step failed: %v", err)
    }
}
```

### 5. Handler Adapter (`steps/registry.go`)

Add this handler struct with other handlers in the file:

```go
// MyStepHandler implements the handler for my-step steps.
type MyStepHandler struct{}

func (h *MyStepHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
    ExecuteMyStep(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
    return nil
}
```

### 6. Registration (`steps/registry.go`)

Add to `registerDefaultHandlers()`:

```go
func registerDefaultHandlers() {
    // ... existing registrations ...
    defaultRegistry.Register(StepTypeMyStep, &MyStepHandler{})
}
```

### 7. YAML Usage (`testdata/steps.yml`)

```yaml
steps:
  - type: my-step
    description: "Execute my custom step"
    myStepParams:
      target: "{{.ComponentID}}-resource"
      options:
        - "verbose"
        - "debug"
      timeout: 30
```

## Parameter Mapping Guide

Your handler receives `ExecutionParams` which contains:

| Field | Description | Use For |
|-------|-------------|---------|
| `TestdataPath` | Path to testdata directory | Loading test files |
| `TmplData` | Template variables | Rendering dynamic values |
| `RepoName` | Repository name | Git operations |
| `QuickstarterRepo` | QS repo name | Component info |
| `QuickstarterName` | QS name | Component info |
| `Config` | Configuration map | Global settings |
| `ProjectName` | OpenShift project | Resource namespace |

Map these to your `ExecuteMyStep()` function signature as needed.

## Common Patterns

### Template Rendering
```go
target := RenderTemplate(t, params.Target, tmplData)
```

### OpenShift Commands
```go
namespace := fmt.Sprintf("%s-dev", projectName)
cmd := []string{"oc", "get", "pods", "-n", namespace}
stdout, stderr, err := utils.RunCommand("oc", cmd[1:], []string{})
```

### File Operations
```go
filePath := fmt.Sprintf("%s/%s", testdataPath, params.FileName)
content, err := os.ReadFile(filePath)
```

### Conditional Logic with Templates
```go
if step.MyStepParams.Condition != "" {
    shouldRun := RenderTemplate(t, step.MyStepParams.Condition, tmplData)
    if shouldRun == "false" {
        return // Skip execution
    }
}
```

## Testing Your Step

### Unit Test Template (`steps/my_step_test.go`)

```go
package steps

import "testing"

func TestMyStepHandler(t *testing.T) {
    registry := DefaultRegistry()
    
    handler, err := registry.Get(StepTypeMyStep)
    if err != nil {
        t.Fatalf("Handler not registered: %v", err)
    }
    
    if handler == nil {
        t.Fatal("Handler is nil")
    }
    
    // Additional tests for your step logic
}
```

### Integration Test

Create a test quickstarter with `testdata/steps.yml`:

```bash
cd /path/to/test-quickstarter
mkdir -p testdata
cat > testdata/steps.yml << 'EOF'
componentID: test-component
steps:
  - type: my-step
    myStepParams:
      target: "test-target"
EOF

# Run the test
cd ods-core/tests
./dev-test.sh ../test-quickstarter test-project
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "unknown step type" | Check registration in `registerDefaultHandlers()` |
| Parameters are nil | Verify JSON tags and YAML structure match |
| Template errors | Ensure variables exist in `TemplateData` |
| Import cycle | Keep all step code in `steps` package |
| Handler not found in tests | Call `DefaultRegistry()` to trigger registration |

## Examples

See existing step implementations for reference:
- Simple step: `steps/http.go`
- Complex step: `steps/provision.go`
- With verification: `steps/inspect.go`
- With retries: Use `retry` in step YAML

## Additional Resources

- Full guide: [QUICKSTARTERS_TESTS.md](../QUICKSTARTERS_TESTS.md#developing-custom-step-types)
- Step types overview: [docs/steps.md](steps.md)
- Individual step docs: [docs/steps/](steps/)
- Registry pattern code: [steps/registry.go](../steps/registry.go)
