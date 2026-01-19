# Quickstarters Test Framework

## Index
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [How to Run](#how-to-run)
- [Logging and Output](#logging-and-output)
- [Templates and Variables](#templates-and-variables)
- [Testdata Layout](#testdata-layout)
- [Step Types (How to Use)](#step-types-how-to-use)
  - [provision](#provision)
  - [build](#build)
  - [upload](#upload)
  - [wait](#wait)
  - [http](#http)
  - [inspect](#inspect)
  - [expose-service](#expose-service)
  - [run](#run)
- [Advanced Features](#advanced-features)
  - [Test Lifecycle Hooks](#test-lifecycle-hooks)
  - [Step Execution Control](#step-execution-control)
  - [Retry Logic](#retry-logic)
  - [Test Reporting](#test-reporting)
- [Complete Example (steps.yml + run script)](#complete-example-stepsyml--run-script)
- [Service URL Resolution](#service-url-resolution)
- [Migration Guidance](#migration-guidance)
- [Developing Custom Step Types](#developing-custom-step-types)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview
Step-based tests driven by `testdata/steps.yml` to validate quickstarters.

A test is a sequence of steps such as:
- provision a quickstarter
- upload config/fixtures
- build/deploy
- wait for readiness
- expose service URLs
- call HTTP endpoints
- inspect logs/env/resources
- run an end-to-end shell script

## Prerequisites
- Logged in to the target OpenShift cluster (`oc whoami`).
- `oc`, `curl`, and `jq` available locally.
- Quickstarter repo contains a `testdata` folder with `steps.yml`.

## How to Run
- Wrapper (recommended):
  ```bash
  cd ods-core/tests
  ./dev-test.sh <quickstarter> <project>
  ```
- Make:
  ```bash
  cd ods-core/tests
  make test-quickstarter QS=<quickstarter> PROJECT_NAME=<project>
  ```
- Go test directly:
  ```bash
  cd ods-core/tests/quickstarter
  go test -v -run TestQuickstarter -timeout 30m \
    -args -quickstarter=<quickstarter> -project=<project> -testPhase=devtest
  ```

## Logging and Output

### Structured Logging with Colors and Emojis

The test framework uses [charmbracelet/log](https://github.com/charmbracelet/log) to provide structured, readable logging with colors and emojis for better visibility and ease of following test execution.

#### Output Features:
- **🚀 Sections**: Major test milestones are marked with visual section headers
- **📋 Sub-sections**: Logical groupings within a test use sub-section headers
- **▶️ Step Markers**: Each step execution is prefixed with the step number and type
- **✅ Success Messages**: Completed operations are marked with green checkmarks
- **❌ Error Messages**: Failed operations are marked with red X symbols
- **⚙️ Running Operations**: Ongoing operations show a gear symbol
- **⏳ Waiting Indicators**: Operations in waiting states show a hourglass
- **⚠️ Warnings**: Important warnings use the warning symbol

#### Example Log Output:
```
🚀 ╔═════════════════════════════════════════════════════════════╗
  🚀 Starting Quickstarter Test Framework
🚀 ╚═════════════════════════════════════════════════════════════╝

🚀 ╔═════════════════════════════════════════════════════════════╗
  🚀 Test Paths
🚀 ╚═════════════════════════════════════════════════════════════╝

  • Found 2 quickstarter(s) to test:
  • ./quickstarters/be-java-springboot
  • ./quickstarters/fe-angular

🚀 ╔═════════════════════════════════════════════════════════════╗
  🚀 Testing Quickstarter: be-java-springboot
🚀 ╚═════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────
  📋 Component: myapp
┌─────────────────────────────────────────────────────────────────

  • Total steps to execute: 3

▶️  Step 1/3 [provision]: Provision quickstarter

⚙️  Running: Provision for test-myapp
✅ Success: BitBucket repo created/updated

⏳ Waiting: Jenkins pipeline execution
✅ Success: Build triggered with name jenkins-1234

▶️  Step 2/3 [build]: Trigger build pipeline

...
```

#### Environment Variable Support:

You can control logging verbosity by setting the `LOG_LEVEL` environment variable:
```bash
LOG_LEVEL=debug go test -v -run TestQuickstarter -timeout 30m \
  -args -quickstarter=<quickstarter> -project=<project>
```

#### Color Legend:
- **Cyan** (#00d7ff): Information messages
- **Yellow** (#ffaf00): Warning messages
- **Red** (#ff005f): Error messages
- **Green** (#00ff00): Success indicators

## Templates and Variables
All string fields in `steps.yml` support Go-template rendering.

Common template variables:
- `{{.ProjectID}}`: the project passed to the test
- `{{.ComponentID}}`: the component passed to the test (or overridden per step via `componentID`)

Common environment variables passed to `run` scripts:
- `PROJECT_ID`, `COMPONENT_ID`, `NAMESPACE` (defaults to `<project>-dev`)
- `ODS_NAMESPACE`, `ODS_GIT_REF`, `ODS_IMAGE_TAG` (when available)
- `{ALIAS}_SERVICE_URL` for each entry under `runParams.services` (e.g. `API_SERVICE_URL`)

## Testdata Layout
Typical structure in a quickstarter repo:

```text
testdata/
├── steps.yml
├── golden/
│   ├── jenkins-provision-stages.json
│   ├── jenkins-build-stages.json
│   └── sonar-scan.json
└── functional/
    ├── api/
    │   └── health-response.json
    └── integration/
        └── e2e_test.sh
```

Key principles:
- Use templates and internal service DNS in `steps.yml` URLs.
- Avoid hardcoding localhost and manual port-forwarding.
- For `run` steps that need URLs, declare services in `runParams.services` and consume `{ALIAS}_SERVICE_URL`.

## Step Types (How to Use)
The YAML file is a list under `steps:`:

```yaml
steps:
  - type: <step-type>
    description: Optional human-friendly description
    componentID: Optional override for this step
    <step-type>Params:
      ...
```

### provision
Provision via ODS; optionally verify Jenkins provision stages.

Minimal example:
```yaml
- type: provision
  provisionParams:
    quickstarter: be-python-flask
```

With common options:
```yaml
- type: provision
  description: Provision quickstarter
  provisionParams:
    quickstarter: be-python-flask
    pipeline: "{{.ProjectID}}-{{.ComponentID}}"
    branch: "master"
    env:
      - key: SOME_PARAM
        value: "some-value"
    verify:
      strategy: fail-fast
      jenkinsStages: golden/jenkins-provision-stages.json
```

### build
Build/deploy; optionally verify Jenkins stages, Sonar scan, test results, and OpenShift resources.

Minimal example:
```yaml
- type: build
  buildParams: {}
```

With verification:
```yaml
- type: build
  description: Build and deploy
  buildParams:
    verify:
      strategy: aggregate
      jenkinsStages: golden/jenkins-build-stages.json
      sonarScan: golden/sonar-scan.json
      runAttachments: ["metadata.json"]
      testResults: 5
      openShiftResources:
        deployments: ["{{.ComponentID}}"]
        services: ["{{.ComponentID}}", "{{.ComponentID}}-backend"]
        routes: ["{{.ComponentID}}"]
```

### upload
Add a file into the created repository.

```yaml
- type: upload
  description: Upload config into repo
  uploadParams:
    file: fixtures/app-config.json
    filename: config/app-config.json
    render: true
```

Notes:
- `file` is relative to `testdata/`.
- `filename` is the destination path inside the provisioned repository.
- `render: true` applies templating to the file contents.

### wait
Poll for readiness/conditions.

Supported conditions:
- `pod-ready` (resource: selector like `-l app=...` or a pod name)
- `deployment-complete` (resource: `deployment/<name>` or `dc/<name>`)
- `job-complete` (resource: `job/<name>`)
- `route-accessible` (resource: `route/<name>`)
- `http-accessible` (url: `...`)
- `log-contains` (resource: `pod/<name>`, `deployment/<name>`, `dc/<name>`; message: `...`)

Examples:

Deployment rollout:
```yaml
- type: wait
  waitParams:
    condition: deployment-complete
    resource: "deployment/{{.ComponentID}}"
    timeout: "10m"
    interval: "5s"
```

Pod readiness by label:
```yaml
- type: wait
  waitParams:
    condition: pod-ready
    resource: "-l app={{.ProjectID}}-{{.ComponentID}}"
    timeout: "5m"
    interval: "5s"
```

Log message appears:
```yaml
- type: wait
  waitParams:
    condition: log-contains
    resource: "deployment/{{.ComponentID}}"
    message: "Server listening"
    timeout: "5m"
    interval: "10s"
```

Route exists and is reachable:
```yaml
- type: wait
  waitParams:
    condition: route-accessible
    resource: "route/{{.ComponentID}}"
    timeout: "5m"
    interval: "5s"
```

Arbitrary URL becomes reachable:
```yaml
- type: wait
  waitParams:
    condition: http-accessible
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
    timeout: "5m"
    interval: "2s"
```

Job completes:
```yaml
- type: wait
  waitParams:
    condition: job-complete
    resource: "job/{{.ProjectID}}-{{.ComponentID}}-migration"
    timeout: "10m"
    interval: "5s"
```

### http
Call endpoints with status/body/assertions and optional retries.

Status + golden JSON body:
```yaml
- type: http
  description: Health endpoint returns expected JSON
  httpParams:
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
    method: GET
    headers:
      Accept: application/json
    expectedStatus: 200
    expectedBody: functional/api/health-response.json
    retry:
      attempts: 10
      delay: "2s"
```

Assertions (JSONPath via `path`):
```yaml
- type: http
  description: Assert JSON fields
  httpParams:
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
    expectedStatus: 200
    assertions:
      - path: "status"
        equals: "ok"
      - path: "version"
        exists: true
      - path: "message"
        contains: "ready"
      - path: "commit"
        matches: "^[a-f0-9]{7,}$"
```

POST with JSON body and custom timeout:
```yaml
- type: http
  description: Create resource
  httpParams:
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/api/v1/items"
    method: POST
    headers:
      Content-Type: application/json
      Accept: application/json
    body: '{"name":"example"}'
    expectedStatus: 201
    timeout: 60
```

### inspect
Check logs/env/resources for a resource.

```yaml
- type: inspect
  description: Verify runtime signals
  inspectParams:
    resource: "deployment/{{.ComponentID}}"
    namespace: "{{.ProjectID}}-dev"
    checks:
      logs:
        contains: ["Server listening on :8080"]
        notContains: ["Traceback", "panic:"]
        matches: ["Listening on.*8080"]
      env:
        APP_ENV: "dev"
        ODS_PROJECT: "{{.ProjectID}}"
      resources:
        limits:
          cpu: "500m"
          memory: "512Mi"
        requests:
          cpu: "100m"
          memory: "128Mi"
```

### expose-service
Resolve stable URLs for one or more services and make them available to later `http` / `run` steps.

```yaml
- type: expose-service
  description: Expose services for local/Jenkins runs
  exposeServiceParams:
    services:
      - serviceName: "{{.ComponentID}}"
        namespace: "{{.ProjectID}}-dev"
        port: "8080"
      - serviceName: "{{.ComponentID}}-backend"
        # namespace defaults to "<project>-dev" if omitted
        # port defaults to 8080 if omitted
```

Notes:
- Use one entry per Kubernetes/OpenShift Service.
- If you use `runParams.services`, ensure those service names are exposed here first.

### run
Execute a shell script. If `runParams.services` is set, the script receives one env var per alias: `{ALIAS}_SERVICE_URL`.

```yaml
- type: run
  description: End-to-end tests
  runParams:
    file: functional/integration/e2e_test.sh
    services:
      api: "{{.ComponentID}}"
      backend: "{{.ComponentID}}-backend"
```

Minimal script pattern:
```bash
#!/usr/bin/env bash
set -euo pipefail

: "${API_SERVICE_URL:?missing API_SERVICE_URL}"
: "${BACKEND_SERVICE_URL:?missing BACKEND_SERVICE_URL}"

curl -fsS "$API_SERVICE_URL/health" | jq -e '.status == "ok"' >/dev/null
curl -fsS "$BACKEND_SERVICE_URL/metrics" >/dev/null
```

## Advanced Features

### Test Lifecycle Hooks

Each step can execute shell scripts before and after execution. This is useful for setup, cleanup, or custom validation logic.

#### beforeStep Hook
Executes a script before the main step. Useful for setup operations:

```yaml
- type: build
  description: Build and deploy with custom setup
  beforeStep: "hooks/pre-build-setup.sh"
  buildParams:
    verify:
      jenkinsStages: golden/jenkins-build-stages.json
```

Example `testdata/hooks/pre-build-setup.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Setting up build environment..."
export CUSTOM_BUILD_VAR="custom-value"
# Additional setup logic
```

#### afterStep Hook
Executes a script after the main step, even if the step fails. Useful for cleanup:

```yaml
- type: http
  description: Call API endpoint
  afterStep: "hooks/post-http-cleanup.sh"
  httpParams:
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
    expectedStatus: 200
```

Example `testdata/hooks/post-http-cleanup.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up HTTP test artifacts..."
# Cleanup logic that always runs
```

**Notes:**
- Hooks are executed relative to the `testdata/` directory.
- Hooks receive environment variables from template data.
- Hook failures in `beforeStep` will prevent the main step from executing.
- Hook failures in `afterStep` are logged but don't fail the test (useful for cleanup).
- Hooks support full bash scripting, including conditional logic.

### Step Execution Control

#### Skip Steps Conditionally

You can skip steps based on static conditions or template expressions:

**Static Skip:**
```yaml
- type: inspect
  description: Optional diagnostic step (skipped in CI)
  skip: true
  inspectParams:
    resource: "deployment/{{.ComponentID}}"
```

**Conditional Skip (Template Expression):**
```yaml
- type: build
  description: Only build in non-production environments
  skipIf: "{{eq .Environment \"production\"}}"
  buildParams: {}
```

Template variables can be any standard Go template expression. Examples:
```yaml
- skipIf: "{{.IsProduction}}"        # Boolean variable
- skipIf: "{{eq .Environment \"ci\"}}" # Environment comparison
- skipIf: "{{gt .Replicas 1}}"       # Numeric comparison
```

#### Step-Level Timeout

Override the default timeout for individual steps:

```yaml
- type: wait
  description: Wait for slow deployment
  timeout: 900  # seconds (overrides default)
  waitParams:
    condition: deployment-complete
    resource: "deployment/{{.ComponentID}}"
```

### Retry Logic

Automatically retry steps on failure with configurable behavior:

#### Basic Retry
```yaml
- type: http
  description: API call with retry
  retry:
    attempts: 5        # Retry up to 5 times
    delay: "2s"        # Wait 2 seconds between attempts
  httpParams:
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
    expectedStatus: 200
```

#### Smart Transient Error Retry
Only retry on transient errors (timeouts, connection issues):

```yaml
- type: wait
  description: Wait with smart retry
  retry:
    attempts: 10
    delay: "1s"
    onlyTransient: true  # Skip retries for permanent errors
  waitParams:
    condition: http-accessible
    url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080"
    timeout: "5m"
```

**Transient Errors:** The framework automatically detects:
- Connection timeouts
- Connection refused
- Temporary unavailability
- EOF and broken pipes
- I/O timeouts

### Test Reporting

The test framework generates structured reports with execution metrics and can export to multiple formats.

#### Automatic Report Generation

Test reports are automatically generated and printed to console:

```
Test Report: be-java-springboot
  Total Steps:     5
  Passed:          5
  Failed:          0
  Skipped:         0
  Success Rate:    100.00%
  Total Duration:  2m30s
  Avg Per Step:    30s
```

#### Export Reports to File

Enable report export by setting an environment variable:

```bash
EXPORT_TEST_REPORTS=true go test -v -run TestQuickstarter -timeout 30m \
  -args -quickstarter=<quickstarter> -project=<project>
```

This generates a `test-report-<quickstarter>.json` file with detailed metrics:

```json
{
  "startTime": "2024-01-21T10:30:00Z",
  "endTime": "2024-01-21T10:32:30Z",
  "totalDuration": 150000000000,
  "quickstarterID": "be-java-springboot",
  "steps": [
    {
      "index": 0,
      "type": "provision",
      "description": "Provision quickstarter",
      "startTime": "2024-01-21T10:30:00Z",
      "endTime": "2024-01-21T10:30:30Z",
      "duration": 30000000000,
      "status": "passed",
      "error": null,
      "context": {}
    }
  ],
  "summary": {
    "totalSteps": 5,
    "passedSteps": 5,
    "failedSteps": 0,
    "skippedSteps": 0,
    "successRate": 100.0,
    "averageDuration": 30000000000
  }
}
```

#### Report Contents

Each report includes:
- **Execution Timeline:** Start/end times and duration for each step
- **Step Status:** Passed, failed, or skipped
- **Error Details:** Full error messages for failed steps
- **Context Information:** Pod logs, events, and environment at time of failure
- **Aggregate Statistics:** Pass rate, timing averages, counts by status

#### CI/CD Integration

Reports can be processed by CI/CD systems for:
- Trend analysis (run-to-run metrics)
- Performance regression detection
- Test flakiness tracking
- Automated failure notifications

## Complete Example (steps.yml + run script)
Example `testdata/steps.yml` using all step types with advanced features:

```yaml
steps:
  - type: provision
    description: Provision quickstarter
    beforeStep: "hooks/pre-provision.sh"
    provisionParams:
      quickstarter: be-python-flask
      branch: master
      verify:
        jenkinsStages: golden/jenkins-provision-stages.json

  - type: upload
    description: Add runtime config
    uploadParams:
      file: fixtures/app-config.json
      filename: config/app-config.json
      render: true

  - type: build
    description: Build and deploy
    retry:
      attempts: 2
      delay: "5s"
    buildParams:
      verify:
        jenkinsStages: golden/jenkins-build-stages.json
        sonarScan: golden/sonar-scan.json
        testResults: 1
        openShiftResources:
          deployments: ["{{.ComponentID}}"]
          services: ["{{.ComponentID}}", "{{.ComponentID}}-backend"]

  - type: wait
    description: Wait for rollout
    waitParams:
      condition: deployment-complete
      resource: "deployment/{{.ComponentID}}"
      timeout: 10m
      interval: 5s

  - type: expose-service
    description: Resolve external/local URLs for tests
    exposeServiceParams:
      services:
        - serviceName: "{{.ComponentID}}"
          port: "8080"
        - serviceName: "{{.ComponentID}}-backend"
          port: "8080"

  - type: http
    description: Healthcheck with retry and assertions
    retry:
      attempts: 10
      delay: 2s
      onlyTransient: true
    httpParams:
      url: "http://{{.ComponentID}}.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
      expectedStatus: 200
      assertions:
        - path: "status"
          equals: "ok"

  - type: inspect
    description: Verify logs and env
    inspectParams:
      resource: "deployment/{{.ComponentID}}"
      checks:
        logs:
          notContains: ["Traceback", "panic:"]
        env:
          ODS_PROJECT: "{{.ProjectID}}"

  - type: run
    description: End-to-end shell test
    runParams:
      file: functional/integration/e2e_test.sh
      services:
        api: "{{.ComponentID}}"
        backend: "{{.ComponentID}}-backend"

  # Optional: diagnostic step (skipped by default in CI)
  - type: inspect
    description: Diagnostic pod inspection (optional)
    skip: true
    inspectParams:
      resource: "deployment/{{.ComponentID}}"
```

Example `testdata/functional/integration/e2e_test.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${PROJECT_ID:?missing PROJECT_ID}"
: "${COMPONENT_ID:?missing COMPONENT_ID}"
: "${NAMESPACE:?missing NAMESPACE}"

: "${API_SERVICE_URL:?missing API_SERVICE_URL}"
: "${BACKEND_SERVICE_URL:?missing BACKEND_SERVICE_URL}"

echo "Project: $PROJECT_ID"
echo "Component: $COMPONENT_ID"
echo "Namespace: $NAMESPACE"
echo "API: $API_SERVICE_URL"
echo "Backend: $BACKEND_SERVICE_URL"

curl -fsS "$API_SERVICE_URL/health" | jq -e '.status == "ok"' >/dev/null
curl -fsS "$API_SERVICE_URL/api/v1/info" | jq -e '.name != null' >/dev/null
curl -fsS "$BACKEND_SERVICE_URL/metrics" >/dev/null

echo "OK"
```

Example `testdata/hooks/pre-provision.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Pre-provisioning checks..."
# Verify cluster connectivity
oc whoami > /dev/null || exit 1
# Any custom setup logic
echo "Pre-provisioning checks passed"
```

## Service URL Resolution
Priority:
1) Route exists → use route URL (https/http).
2) In-cluster (Jenkins) → use service DNS.
3) Local → automatic `oc port-forward` on 8000–8009 with cleanup and reuse.

## Migration Guidance
- Replace hardcoded localhost URLs with templated service DNS in `steps.yml`.
- Add an `expose-service` step for every service you need to access from local runs.
- Remove manual port-forwarding from scripts.
- In `run` steps, declare services under `runParams.services` and consume `{ALIAS}_SERVICE_URL`.
- Validate with `./dev-test.sh <quickstarter> <project>`.

## Developing Custom Step Types

The quickstarter test framework uses a **registry pattern** that makes it easy to add new step types without modifying the core test execution logic. This section explains how to implement and register custom step types.

### Architecture Overview

The framework consists of:
- **StepHandler Interface**: Defines the contract all step types must implement
- **StepRegistry**: Maps step type names to their handler implementations  
- **ExecutionParams**: Consolidates all context needed for step execution
- **Handler Implementations**: Individual step type logic (upload, build, http, etc.)

### Step 1: Define the Step Type Constant

Add your new step type constant to `steps/types.go`:

```go
const (
    StepTypeUpload        = "upload"
    StepTypeRun           = "run"
    // ... existing types ...
    StepTypeMyCustom      = "my-custom"  // Add your new type here
)
```

### Step 2: Add Step Parameters to TestStep

In `steps/types.go`, add a parameters struct for your step if needed:

```go
// MyCustomParams defines parameters for the my-custom step type
type MyCustomParams struct {
    // Add your custom fields here
    Target      string   `json:"target"`
    Options     []string `json:"options"`
    RetryCount  int      `json:"retryCount"`
}
```

Then add a field to the `TestStep` struct:

```go
type TestStep struct {
    Type        string `json:"type"`
    Description string `json:"description"`
    // ... existing params ...
    MyCustomParams *MyCustomParams `json:"myCustomParams,omitempty"`
}
```

### Step 3: Implement the Execution Logic

Create a new file `steps/my_custom.go` with your step implementation:

```go
package steps

import (
    "fmt"
    "testing"
)

// ExecuteMyCustom handles the my-custom step type.
// This function contains the actual logic for your step.
func ExecuteMyCustom(t *testing.T, step TestStep, testdataPath string, 
                     tmplData TemplateData, projectName string) {
    
    // Validate parameters
    if step.MyCustomParams == nil {
        t.Fatalf("Missing my-custom parameters")
    }
    
    params := step.MyCustomParams
    
    // Implement your step logic here
    fmt.Printf("Executing custom step with target: %s\n", params.Target)
    
    // Example: Run some operation
    for _, option := range params.Options {
        fmt.Printf("Processing option: %s\n", option)
        // Your custom logic here
    }
    
    // Use template data for dynamic values
    renderedTarget := RenderTemplate(t, params.Target, tmplData)
    fmt.Printf("Rendered target: %s\n", renderedTarget)
    
    // Fail the test if something goes wrong
    if someCondition {
        t.Fatalf("Custom step failed: %v", err)
    }
}
```

### Step 4: Create a Handler Adapter

In `steps/registry.go`, add a handler struct that implements the `StepHandler` interface:

```go
// MyCustomHandler implements the handler for my-custom steps.
type MyCustomHandler struct{}

func (h *MyCustomHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
    ExecuteMyCustom(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
    return nil
}
```

**Note**: The handler adapter maps between the `StepHandler` interface (which receives `ExecutionParams`) and your specific execution function signature.

### Step 5: Register the Handler

In `steps/registry.go`, add your handler to the `registerDefaultHandlers()` function:

```go
func registerDefaultHandlers() {
    defaultRegistry.Register(StepTypeUpload, &UploadHandler{})
    defaultRegistry.Register(StepTypeRun, &RunHandler{})
    // ... existing registrations ...
    defaultRegistry.Register(StepTypeMyCustom, &MyCustomHandler{})  // Add this line
}
```

### Step 6: Add Documentation

Create `docs/steps/my-custom.md` documenting your new step type:

```markdown
# my-custom Step

## Purpose
Brief description of what this step does.

## Parameters

- `target` (string, required): Description of target parameter
- `options` (array, optional): Description of options
- `retryCount` (int, optional): Number of retry attempts

## Example

\```yaml
- type: my-custom
  description: "Execute custom operation"
  myCustomParams:
    target: "{{.ComponentID}}"
    options:
      - "verbose"
      - "debug"
    retryCount: 3
\```

## Common Use Cases
- Use case 1
- Use case 2
```

Update `docs/steps.md` to include your new step in the overview table.

### Step 7: Write Unit Tests

Create `steps/my_custom_test.go` to test your handler:

```go
package steps

import (
    "testing"
)

func TestMyCustomHandler(t *testing.T) {
    registry := DefaultRegistry()
    
    handler, err := registry.Get(StepTypeMyCustom)
    if err != nil {
        t.Fatalf("Expected my-custom handler to be registered: %v", err)
    }
    
    if handler == nil {
        t.Fatal("Handler should not be nil")
    }
    
    // Test execution (may need mocking for complex steps)
    step := &TestStep{
        Type: StepTypeMyCustom,
        MyCustomParams: &MyCustomParams{
            Target: "test-target",
            Options: []string{"opt1"},
        },
    }
    
    params := &ExecutionParams{
        TestdataPath: "/tmp/testdata",
        TmplData:     TemplateData{},
        ProjectName:  "test-project",
    }
    
    // Test that handler executes without panic
    // (Actual behavior testing may require more setup)
}
```

### Step 8: Use Your New Step in Tests

Add your step to any `testdata/steps.yml`:

```yaml
componentID: my-component

steps:
  - type: provision
    # ... provision step ...
  
  - type: my-custom
    description: "Run my custom operation"
    myCustomParams:
      target: "{{.ComponentID}}-resource"
      options:
        - "enable-feature-x"
        - "debug-mode"
      retryCount: 2
```

### Best Practices for Custom Steps

1. **Keep Steps Focused**: Each step should do one thing well
2. **Use Template Data**: Leverage `{{.Variable}}` syntax for dynamic values
3. **Fail Fast**: Use `t.Fatalf()` for unrecoverable errors
4. **Add Logging**: Use `fmt.Printf()` or the logger package for visibility
5. **Parameter Validation**: Always validate required parameters at the start
6. **Error Context**: Provide clear error messages with context
7. **Idempotency**: Consider making steps idempotent when possible
8. **Documentation**: Document all parameters and provide examples

### Example: Complete Custom Step

Here's a complete example of a custom step that validates database connectivity:

```go
// steps/database.go
package steps

import (
    "fmt"
    "testing"
    "database/sql"
    _ "github.com/lib/pq"
)

type DatabaseParams struct {
    ConnectionString string `json:"connectionString"`
    Query           string `json:"query"`
    ExpectedRows    int    `json:"expectedRows"`
}

func ExecuteDatabase(t *testing.T, step TestStep, testdataPath string, 
                     tmplData TemplateData, projectName string) {
    if step.DatabaseParams == nil {
        t.Fatalf("Missing database parameters")
    }
    
    params := step.DatabaseParams
    connStr := RenderTemplate(t, params.ConnectionString, tmplData)
    query := RenderTemplate(t, params.Query, tmplData)
    
    db, err := sql.Open("postgres", connStr)
    if err != nil {
        t.Fatalf("Failed to connect to database: %v", err)
    }
    defer db.Close()
    
    rows, err := db.Query(query)
    if err != nil {
        t.Fatalf("Query failed: %v", err)
    }
    defer rows.Close()
    
    count := 0
    for rows.Next() {
        count++
    }
    
    if count != params.ExpectedRows {
        t.Fatalf("Expected %d rows, got %d", params.ExpectedRows, count)
    }
    
    fmt.Printf("✅ Database validation passed: %d rows\n", count)
}

// steps/registry.go - add this handler
type DatabaseHandler struct{}

func (h *DatabaseHandler) Execute(t *testing.T, step *TestStep, params *ExecutionParams) error {
    ExecuteDatabase(t, *step, params.TestdataPath, params.TmplData, params.ProjectName)
    return nil
}

// In registerDefaultHandlers():
// defaultRegistry.Register("database", &DatabaseHandler{})
```

### Advanced: Handler Parameters

If your step needs additional context beyond `ExecutionParams`, you can:

1. **Add to ExecutionParams**: Extend the struct if the parameter is commonly needed
2. **Use TestStep Fields**: Store step-specific data in your params struct
3. **Access Global Config**: Use the `config` map in ExecutionParams

### Registry Pattern Benefits

- ✅ **No Switch Statements**: Add steps without modifying test runner code
- ✅ **Plugin Architecture**: External packages can register custom steps
- ✅ **Testability**: Individual handlers can be unit tested in isolation
- ✅ **Type Safety**: Go compiler ensures all handlers implement the interface
- ✅ **Maintainability**: Step logic is cleanly separated and organized

### Troubleshooting Custom Steps

**Handler not found**: Ensure you've registered it in `registerDefaultHandlers()`  
**Parameters nil**: Check YAML structure and JSON tags match  
**Template errors**: Verify template syntax and that variables exist in `TemplateData`  
**Import cycles**: Keep step implementations in the `steps` package  
**Test failures**: Check parameter validation and error handling

## Troubleshooting
- Login: `oc whoami`.
- Port-forwards: `ps aux | grep "oc port-forward" | grep -v grep`; kill with `pkill -f "oc port-forward"`.
- Ports in use: `lsof -i :8000-8009`.
- Resources: `oc get svc -n <project>-dev`, `oc get pods -n <project>-dev`.
- Add/extend `wait` steps if endpoints are not ready.

## Best Practices
- Add `wait` before `http`/`run` to avoid races.
- Use retries for early endpoints.
- Keep scripts small; fail fast when expected `{ALIAS}_SERVICE_URL` is missing.
- Prefer templates for names/namespaces; avoid hardcoded hostnames.
