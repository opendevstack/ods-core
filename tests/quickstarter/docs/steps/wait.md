# wait Step

Waits for asynchronous operations to complete by polling for specific conditions on Kubernetes resources or HTTP endpoints.

## Configuration

```yaml
- type: wait
  description: "Wait for pod to be ready"
  waitParams:
    condition: "pod-ready"
    resource: "pod/{{.ComponentID}}"
    namespace: "{{.ProjectID}}-dev"  # optional, defaults to {{.ProjectID}}-dev
    timeout: "300s"                  # optional, defaults to 300s
    interval: "5s"                   # optional, defaults to 5s
```

## Parameters

### `condition` (required)
The condition to wait for. Supported values:

- **`pod-ready`**: Wait for a pod to reach Ready state
- **`deployment-complete`**: Wait for a deployment to complete its rollout
- **`job-complete`**: Wait for a Kubernetes job to complete
- **`route-accessible`**: Wait for an OpenShift route to be accessible
- **`http-accessible`**: Wait for an HTTP endpoint to respond with 2xx or 3xx status
- **`log-contains`**: Wait for a specific message to appear in logs

### `resource` (required for pod, deployment, job, route, log conditions)
The Kubernetes resource to wait for. Format: `<kind>/<name>` or just `<name>`.
Supports Go template rendering (e.g., `{{.ComponentID}}`).

### `url` (required for http-accessible)
The HTTP URL to wait for. Supports Go template rendering.

### `message` (required for log-contains)
The log message to wait for. Supports Go template rendering.

### `namespace` (optional)
Kubernetes namespace where the resource runs. Defaults to `{{.ProjectID}}-dev`.
Supports Go template rendering.

### `timeout` (optional)
Maximum time to wait. Defaults to `300s`. Accepts Go duration format (e.g., `60s`, `5m`).

### `interval` (optional)
How often to check the condition. Defaults to `5s`. Accepts Go duration format.

## How It Works

1. **Polling Loop**: Repeatedly checks the condition until timeout is reached
2. **Success**: Returns when the condition is met
3. **Failure**: Times out and fails the test if condition is not met within timeout period
4. **Retries**: Uses the interval to determine how often to check

## Examples

**Wait for pod to be ready:**
```yaml
- type: wait
  waitParams:
    condition: "pod-ready"
    resource: "{{.ComponentID}}"
    timeout: "120s"
```

**Wait for deployment to complete:**
```yaml
- type: wait
  waitParams:
    condition: "deployment-complete"
    resource: "deployment/{{.ComponentID}}"
    timeout: "300s"
    interval: "10s"
```

**Wait for job to complete:**
```yaml
- type: wait
  waitParams:
    condition: "job-complete"
    resource: "job/my-job"
    namespace: "{{.ProjectID}}-dev"
    timeout: "600s"
```

**Wait for route to be accessible:**
```yaml
- type: wait
  waitParams:
    condition: "route-accessible"
    resource: "{{.ComponentID}}"
    timeout: "180s"
    interval: "5s"
```

**Wait for HTTP endpoint to be accessible:**
```yaml
- type: wait
  waitParams:
    condition: "http-accessible"
    url: "http://{{.ComponentID}}.example.com/health"
    timeout: "120s"
    interval: "10s"
```

**Wait for log message:**
```yaml
- type: wait
  waitParams:
    condition: "log-contains"
    resource: "{{.ComponentID}}"
    message: "Application started successfully"
    timeout: "60s"
    interval: "5s"
```

## Common Scenarios

**Wait after deployment with custom interval:**
```yaml
- type: wait
  waitParams:
    condition: "deployment-complete"
    resource: "{{.ComponentID}}"
    namespace: "{{.ProjectID}}-dev"
    timeout: "300s"
    interval: "15s"
```

**Chain multiple waits:**
```yaml
- type: wait
  waitParams:
    condition: "pod-ready"
    resource: "{{.ComponentID}}"

- type: wait
  waitParams:
    condition: "http-accessible"
    url: "http://localhost:8080/health"
```
