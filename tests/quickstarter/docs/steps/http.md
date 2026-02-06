# http Step

Tests HTTP endpoints by making requests and validating responses. Supports retries, method variations, request/response body validation, and header checks.

## Configuration

```yaml
- type: http
  description: "Test API endpoint"
  httpParams:
    url: "http://{{.ComponentID}}.example.com/health"
    method: "GET"                           # optional, defaults to GET
    timeout: 30                              # optional, timeout in seconds, defaults to 30
    headers:                                 # optional, HTTP headers
      Authorization: "Bearer token123"
    body: '{"key": "value"}'                # optional, request body
    retry:                                  # optional, retry configuration
      attempts: 3
      delay: "5s"
    expectedStatus: 200                      # optional, expected HTTP status code
    expectedBody: "golden/health.json"       # optional, path to a golden file for response body validation
    assertions:                              # optional, assertions to run on the response
      - path: "status"
        equals: "UP"
      - path: "components.db.status"
        equals: "UP"
      - path: "body.message"
        contains: "Hello"
      - path: "timestamp"
        matches: "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z"
      - path: "optionalField"
        exists: false
```

## Parameters

### `url` (required)
The HTTP endpoint URL to test. Supports Go template rendering (e.g., `{{.ComponentID}}`).

### `method` (optional)
HTTP method to use. Defaults to `GET`.
Allowed values: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`

### `timeout` (optional)
Request timeout in seconds. Defaults to `30`.

### `headers` (optional)
Map of HTTP headers to include in the request.

### `body` (optional)
Request body as a string (typically JSON).
Supports Go template rendering.

### `retry` (optional)
Retry configuration with:
- **`attempts`** (optional): Number of retry attempts. Defaults to 1.
- **`delay`** (optional): Delay between retries (Go duration format like `5s`, `1m`).

### `expectedStatus` (optional)
Expected HTTP status code. If not specified, accepts any 2xx or 3xx response.

### `expectedBody` (optional)
Path to a "golden file" containing the expected response body. The response body will be compared against the content of this file. This is typically used for validating JSON responses.

### `assertions` (optional)
A list of assertions to validate the response body. This is especially useful for JSON responses. Each assertion can have the following fields:
- **`path`** (required for most assertions): A [GJSON path](https://github.com/tidwall/gjson/blob/master/SYNTAX.md) to extract a value from the JSON response body.
- **`equals`** (optional): Checks if the value at `path` is equal to the given value.
- **`exists`** (optional): Checks if the given `path` exists in the JSON response. The value should be `true` or `false`.
- **`contains`** (optional): Checks if the value at `path` (if provided) or the whole body contains the given string.
- **`matches`** (optional): Checks if the value at `path` (if provided) or the whole body matches the given regular expression.

## How It Works

1. **URL Resolution**: Resolves the URL (handles route names, in-cluster DNS, port-forwards)
2. **Request Building**: Constructs the HTTP request with headers, body, and method
3. **Retry Logic**: Retries the request on failure up to specified attempts
4. **Response Validation**: Checks status code, compares body against a golden file (if `expectedBody` is set), and runs assertions (if `assertions` are set).
5. **Error Handling**: Fails the test if validation fails

## Examples

**Simple GET request:**
```yaml
- type: http
  httpParams:
    url: "http://localhost:8080/health"
    expectedStatus: 200
```

**POST with request body:**
```yaml
- type: http
  httpParams:
    url: "http://api.example.com/users"
    method: "POST"
    headers:
      Content-Type: "application/json"
      Authorization: "Bearer token123"
    body: '{"name": "test", "email": "test@example.com"}'
    expectedStatus: 201
```

**Validate response body with assertions:**
```yaml
- type: http
  httpParams:
    url: "http://{{.ComponentID}}.example.com/api/status"
    expectedStatus: 200
    assertions:
      - path: "status"
        equals: "healthy"
      - path: "details.version"
        matches: '"\\d+\\.\\d+\\.\\d+"'
      - path: "message"
        contains: "service is running"
```

**Validate response against a golden file:**
```yaml
- type: http
  httpParams:
    url: "http://api.example.com/data"
    expectedBody: "golden/api-data.json"
```

**HTTP request with retries:**
```yaml
- type: http
  httpParams:
    url: "http://{{.ComponentID}}.example.com/ready"
    timeout: 10
    retry:
      attempts: 5
      delay: "3s"
    expectedStatus: 200
    assertions:
      - path: "status"
        equals: "ready"
```

**DELETE request:**
```yaml
- type: http
  httpParams:
    url: "http://api.example.com/resource/123"
    method: "DELETE"
    expectedStatus: 204
```
