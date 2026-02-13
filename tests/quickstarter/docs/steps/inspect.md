# inspect Step

Inspects container behavior by checking logs, environment variables, and resource metrics. Useful for validating that containers are running with correct configuration and logging expected messages.

## Configuration

```yaml
- type: inspect
  description: "Inspect container configuration"
  componentID: "my-component"
  inspectParams:
    resource: "pod/{{.ComponentID}}-xyz"   # pod or deployment name
    namespace: "{{.ProjectID}}-dev"        # optional, defaults to {{.ProjectID}}-dev
    checks:
      logs:                                # optional, validate log output
        contains:
          - "Application started"
        notContains:
          - "ERROR"
          - "FATAL"
        matches:
          - "version: \\d+\\.\\d+\\.\\d+"
      env:                                 # optional, validate environment variables
        - name: "APP_ENV"
          expectedValue: "production"
        - name: "DEBUG_MODE"
          expectedValue: "false"
      resources:                           # optional, validate resource requests/limits
        requestsCPU: "100m"
        requestsMemory: "256Mi"
        limitsCPU: "500m"
        limitsMemory: "512Mi"
```

## Parameters

### `resource` (required)
The Kubernetes resource to inspect. Can be:
- Pod name: `my-pod`
- Deployment name: `my-deployment`
- Full resource: `pod/my-pod`

Supports Go template rendering (e.g., `{{.ComponentID}}`).

### `namespace` (optional)
Kubernetes namespace where the resource runs. Defaults to `{{.ProjectID}}-dev`.
Supports Go template rendering.

### `checks` (optional)
Object containing inspection checks:

**`logs`** (optional): Validate container logs
- **`contains`** (optional): Array of strings that must appear in logs
- **`notContains`** (optional): Array of strings that must not appear in logs
- **`matches`** (optional): Array of regex patterns that must match in logs

**`env`** (optional): Validate environment variables
- Array of objects with:
  - **`name`** (required): Environment variable name
  - **`expectedValue`** (required): Expected value (supports Go template rendering)

**`resources`** (optional): Validate resource requests and limits
- **`requestsCPU`** (optional): Expected CPU request (e.g., `100m`)
- **`requestsMemory`** (optional): Expected memory request (e.g., `256Mi`)
- **`limitsCPU`** (optional): Expected CPU limit (e.g., `500m`)
- **`limitsMemory`** (optional): Expected memory limit (e.g., `512Mi`)

## How It Works

1. **Resource Lookup**: Finds the specified pod or deployment
2. **Log Inspection**: Retrieves logs and validates against patterns
3. **Environment Check**: Inspects environment variables inside the container
4. **Resource Validation**: Checks resource requests and limits
5. **Error Handling**: Fails if any check fails

## Examples

**Inspect logs:**
```yaml
- type: inspect
  componentID: "app"
  inspectParams:
    resource: "{{.ComponentID}}"
    namespace: "{{.ProjectID}}-dev"
    checks:
      logs:
        contains:
          - "Application started successfully"
          - "Listening on port"
        notContains:
          - "ERROR"
```

**Inspect environment variables:**
```yaml
- type: inspect
  componentID: "service"
  inspectParams:
    resource: "deployment/{{.ComponentID}}"
    checks:
      env:
        - name: "ENVIRONMENT"
          expectedValue: "production"
        - name: "LOG_LEVEL"
          expectedValue: "info"
```

**Inspect resource requests/limits:**
```yaml
- type: inspect
  componentID: "app"
  inspectParams:
    resource: "{{.ComponentID}}"
    checks:
      resources:
        requestsCPU: "100m"
        requestsMemory: "256Mi"
        limitsCPU: "500m"
        limitsMemory: "512Mi"
```

**Comprehensive inspection:**
```yaml
- type: inspect
  componentID: "api"
  inspectParams:
    resource: "pod/{{.ComponentID}}-deployment"
    namespace: "{{.ProjectID}}-dev"
    checks:
      logs:
        contains:
          - "API server started"
          - "Database connected"
        matches:
          - "version: \\d+\\.\\d+\\.\\d+"
      env:
        - name: "APP_MODE"
          expectedValue: "production"
        - name: "DATABASE_URL"
          expectedValue: "postgresql://db:5432"
      resources:
        requestsCPU: "200m"
        requestsMemory: "512Mi"
        limitsCPU: "1000m"
        limitsMemory: "1Gi"
```
