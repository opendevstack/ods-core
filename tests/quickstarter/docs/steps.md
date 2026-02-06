# Test Steps Documentation

This guide documents all available test step types used to build comprehensive end-to-end tests for ODS components.

## Step Types Overview

The following test step types are available:

| Step Type | Purpose | Use Case |
|-----------|---------|----------|
| [expose-service](steps/expose-service.md) | Make Kubernetes services accessible | Access service URLs in tests |
| [wait](steps/wait.md) | Wait for conditions to be met | Wait for deployments, pods, endpoints |
| [run](steps/run.md) | Execute shell scripts | Run custom test scripts |
| [upload](steps/upload.md) | Upload files to Bitbucket | Commit test artifacts to repos |
| [build](steps/build.md) | Trigger Jenkins pipeline builds | Test build/deployment processes |
| [http](steps/http.md) | Test HTTP endpoints | Validate APIs and services |
| [inspect](steps/inspect.md) | Inspect container configuration | Verify logs, environment variables |
| [bitbucket](steps/bitbucket.md) | Manage Bitbucket repositories | Recreate repos, approve PRs |
| [provision](steps/provision.md) | Prepare test environment | Set up resources for tests |

## Quick Start

### Basic Test Workflow

```yaml
# 1. Provision resources and run pipeline
- type: provision
  componentID: "my-app"
  provisionParams:
    quickstarter: "docker"

# 2. Wait for deployment to complete
- type: wait
  waitParams:
    condition: "deployment-complete"
    resource: "deployment/my-app"

# 3. Expose the service
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "my-app"
        port: "8080"

# 4. Test the API
- type: http
  httpParams:
    url: "http://my-app.example.com/health"
    expectedStatus: 200

# 5. Run test scripts
- type: run
  componentID: "my-app"
  runParams:
    file: "test-suite.sh"

# 6. Inspect container
- type: inspect
  componentID: "my-app"
  inspectParams:
    resource: "deployment/my-app"
    checks:
      logs:
        contains:
          - "Application started"
```

## Common Patterns

### Testing a Quickstarter

```yaml
- type: provision
  componentID: "test-component"
  provisionParams:
    quickstarter: "python"
    verify:
      testResults: 25
      openShiftResources:
        deployments:
          - "test-component"
```

### Service Testing

```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "api"
      - serviceName: "database"

- type: http
  httpParams:
    url: "http://api.example.com/api/health"
    expectedStatus: 200
```

### Resource Verification

```yaml
- type: provision
  componentID: "app"
  provisionParams:
    verify:
      openShiftResources:
        deployments:
          - "{{.ComponentID}}"
        services:
          - "{{.ComponentID}}"
        routes:
          - "{{.ComponentID}}"
```

## Template Variables

All steps support Go template rendering with these variables:

- **`{{.ProjectID}}`**: Project identifier
- **`{{.ComponentID}}`**: Component identifier
- **`{{.OdsNamespace}}`**: ODS cluster namespace
- **`{{.OdsGitRef}}`**: ODS Git reference
- **`{{.OdsImageTag}}`**: ODS image tag

## Best Practices

1. **Use wait steps**: Always wait for resources to be ready before testing
2. **Clear verification rules**: Use verification to ensure expected outcomes
3. **Template variables**: Use template variables for dynamic test configuration
4. **Service isolation**: Expose services in separate steps for clarity
5. **Sequential execution**: Steps execute in order; arrange them logically
6. **Error handling**: Each step fails the test if it encounters an error
7. **Cleanup**: Resources are automatically cleaned up after tests

## Detailed Documentation

For detailed information about each step type, see the links in the table above or navigate to the `steps/` directory.

Each step documentation includes:
- Configuration examples
- Parameter descriptions
- How the step works
- Practical examples
- Common scenarios
- Best practices

---
