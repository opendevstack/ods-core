# run Step

Executes shell scripts with access to test context, service URLs, and configuration variables as environment variables.

## Configuration

```yaml
- type: run
  description: "Run test script"
  componentID: "my-component"
  runParams:
    file: "test.sh"
    services:
      api: "api-service"        # optional, maps service aliases to service names
      backend: "backend-service"
```

## Parameters

### `file` (required)
Path to the shell script to execute, relative to the test data directory.
Supports Go template rendering (e.g., `scripts/{{.ComponentID}}_test.sh`).

### `services` (optional)
Map of service aliases to Kubernetes service names. Each alias is converted to an environment variable.
- **Key**: The alias name (e.g., `api`, `backend`)
- **Value**: The Kubernetes service name (supports Go template rendering)

If no services map is defined, the `ComponentID` is automatically exported as `SERVICE_URL` for backward compatibility.

## Environment Variables

Scripts automatically receive these environment variables:

### Always Provided

- **`COMPONENT_ID`**: The component ID from the test step
- **`PROJECT_ID`**: The project name
- **`NAMESPACE`**: The default namespace (`{PROJECT_ID}-dev`)

### From Exposed Services

When services are exposed via `expose-service` steps:

- **Single service (backward compatible)**: `$SERVICE_URL`
- **Named services map**: `${ALIAS}_SERVICE_URL` (uppercase alias, e.g., `$API_SERVICE_URL`, `$BACKEND_SERVICE_URL`)

### From Template Data

- **`ODS_NAMESPACE`**: ODS cluster namespace if available
- **`ODS_GIT_REF`**: ODS Git reference if available
- **`ODS_IMAGE_TAG`**: ODS image tag if available

## How It Works

1. **Script Execution**: Runs the shell script at the specified path
2. **Environment Setup**: Injects all relevant environment variables before execution
3. **Service Resolution**: Looks up exposed service URLs from previous `expose-service` steps
4. **Error Handling**: Fails the test if the script exits with non-zero status
5. **Output Capture**: Captures and logs both stdout and stderr

## Examples

**Simple script execution:**
```yaml
- type: run
  componentID: "my-app"
  runParams:
    file: "test.sh"
```

Script can use:
```bash
#!/bin/bash
echo "Component: $COMPONENT_ID"
echo "Project: $PROJECT_ID"
echo "Namespace: $NAMESPACE"
```

**With single exposed service:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "my-app"
        port: "8080"

- type: run
  componentID: "my-app"
  runParams:
    file: "integration-test.sh"
```

Script can use:
```bash
#!/bin/bash
curl -s "$SERVICE_URL/health"
```

**With multiple named services:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "api"
        port: "8080"
      - serviceName: "database"
        port: "5432"

- type: run
  componentID: "api"
  runParams:
    file: "full-integration-test.sh"
    services:
      api: "api"
      database: "database"
```

Script can use:
```bash
#!/bin/bash
# Test API health
curl -s "$API_SERVICE_URL/health"

# Test database connectivity
nc -zv "$DATABASE_SERVICE_URL" 5432
```

**With template variables:**
```yaml
- type: run
  componentID: "{{.ComponentID}}"
  runParams:
    file: "tests/{{.ComponentID}}_validation.sh"
    services:
      component: "{{.ComponentID}}"
```

**Accessing ODS configuration:**
```yaml
- type: run
  componentID: "my-component"
  runParams:
    file: "ods-config-test.sh"
```

Script can use:
```bash
#!/bin/bash
echo "ODS Namespace: $ODS_NAMESPACE"
echo "ODS Git Ref: $ODS_GIT_REF"
echo "ODS Image Tag: $ODS_IMAGE_TAG"
```

## Common Scenarios

**Verify service connectivity:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "api"
        port: "8080"

- type: run
  componentID: "api"
  runParams:
    file: "verify-connectivity.sh"
```

**Run multiple test scripts in sequence:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "app"

- type: run
  runParams:
    file: "unit-tests.sh"

- type: run
  runParams:
    file: "integration-tests.sh"

- type: run
  runParams:
    file: "smoke-tests.sh"
```

**Test with component-specific script:**
```yaml
- type: run
  componentID: "{{.ComponentID}}"
  runParams:
    file: "test-{{.ComponentID}}.sh"
```

## Best Practices

- **Fail on errors**: Start scripts with `set -e` to fail immediately on errors
- **Log output**: Use `set -x` for debugging script execution
- **Clean paths**: Use absolute paths when referencing test data files
- **Exit codes**: Ensure scripts return 0 on success and non-zero on failure
- **Service URLs**: Always check if `$SERVICE_URL` or named service URLs are set before using them
