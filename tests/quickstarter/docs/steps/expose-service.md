# expose-service Step

Makes Kubernetes services accessible to test steps by resolving their URLs and setting up port-forwards for local testing.

## Configuration

```yaml
- type: expose-service
  description: "Expose service with defaults"
  exposeServiceParams:
    services:
      - serviceName: "{{.ComponentID}}"
        port: "8080"
        namespace: "{{.ProjectID}}-dev"  # optional, defaults to {{.ProjectID}}-dev
```

## Parameters

### `services` (required)
Array of services to expose. Each service object contains:

- **`serviceName`** (required, string): The Kubernetes service name. Supports Go template rendering (e.g., `{{.ComponentID}}`).
- **`port`** (optional, string): Service port number. Defaults to `8080`.
- **`namespace`** (optional, string): Kubernetes namespace where the service runs. Defaults to `{{.ProjectID}}-dev`. Supports Go template rendering.

## How It Works

1. **Service Lookup**: Waits for the service to be ready (up to 120 seconds)
2. **URL Resolution**: 
   - In cluster: `http://service-name.namespace.svc.cluster.local:port`
   - Locally: Sets up `kubectl port-forward` → `http://localhost:forwarded_port`
3. **Storage**: URLs stored as `ExposedService_<serviceName>` in template data

## Accessing Services in Later Steps

### Single Service in `run` steps

```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "api"

- type: run
  runParams:
    file: "test.sh"
```

Access via `$SERVICE_URL`:
```bash
curl -s "$SERVICE_URL/health"
```

### Multiple Services in `run` steps

```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "api"
        port: "8080"
      - serviceName: "backend"
        port: "9000"

- type: run
  runParams:
    file: "test.sh"
    services:
      api: "api"
      backend: "backend"
```

Access via named environment variables:
```bash
curl -s "$API_SERVICE_URL/health"
curl -s "$BACKEND_SERVICE_URL/metrics"
```

The service alias is converted to uppercase and suffixed with `_SERVICE_URL`.

### In `http` steps

Use Kubernetes DNS directly:
```yaml
- type: http
  httpParams:
    url: "http://api.{{.ProjectID}}-dev.svc.cluster.local:8080/health"
```

## Examples

**Single service:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "app"
        port: "8080"

- type: run
  runParams:
    file: "test.sh"
```

**Multiple services:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "api"
        port: "8080"
      - serviceName: "db"
        port: "5432"

- type: run
  runParams:
    file: "integration_test.sh"
    services:
      api: "api"
      db: "db"
```

Script receives: `$API_SERVICE_URL` and `$DB_SERVICE_URL`

## Cleanup

Port-forwards are automatically cleaned up when tests complete, fail, or are interrupted.

## Common Scenarios

**Custom namespace:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "my-service"
        port: "3000"
        namespace: "custom-namespace"
```

**Template variables in service names:**
```yaml
- type: expose-service
  exposeServiceParams:
    services:
      - serviceName: "{{.ComponentID}}-api"
```
