# upload Step

Uploads files to a Bitbucket repository with optional template rendering support. Useful for committing test artifacts, configuration files, or generated content back to the repository.

## Configuration

```yaml
- type: upload
  description: "Upload test artifact to repository"
  uploadParams:
    file: "artifacts/test-output.json"
    filename: "test-results.json"           # optional, defaults to basename of file
    repository: "{{.ComponentID}}"          # optional, defaults to component repository
    render: true                             # optional, renders file as Go template before upload
```

## Parameters

### `file` (required)
Path to the file to upload, relative to the test data directory.
Supports Go template rendering (e.g., `outputs/{{.ComponentID}}_result.txt`).

### `filename` (optional)
The target filename in the repository. If not specified, defaults to the basename of the source file.
Example: `test-output.json` → uploaded as `test-output.json`

### `repository` (optional)
The Bitbucket repository to upload to. Defaults to the component's repository.
Supports Go template rendering (e.g., `{{.ComponentID}}-tests`).

### `render` (optional)
Whether to render the file as a Go template before uploading. Defaults to `false`.
When `true`, the file is processed using Go's `text/template` package with access to template data (project ID, component ID, etc.).

## How It Works

1. **File Resolution**: Locates the file in the test data directory
2. **Template Rendering** (if enabled): Processes the file as a Go template with test context
3. **Bitbucket Upload**: Uploads the file to the target repository using git-based upload script
4. **Success Logging**: Reports the successful upload to the configured BitBucket URL
5. **Error Handling**: Fails the test if upload fails

## Template Data Available

When `render: true`, files have access to all template variables:

- **`{{.ProjectID}}`**: The project identifier
- **`{{.ComponentID}}`**: The component identifier
- **`{{.OdsNamespace}}`**: The ODS namespace
- Custom variables from the test configuration

## Examples

**Upload a static file:**
```yaml
- type: upload
  uploadParams:
    file: "results/test-summary.txt"
    filename: "test-summary.txt"
```

**Upload with custom filename:**
```yaml
- type: upload
  uploadParams:
    file: "output.json"
    filename: "{{.ComponentID}}-test-results.json"
```

**Upload to different repository:**
```yaml
- type: upload
  uploadParams:
    file: "artifacts/deployment-log.txt"
    repository: "shared-resources"
    filename: "deployment-logs/{{.ComponentID}}-deployment.txt"
```

**Upload with template rendering:**
```yaml
- type: upload
  uploadParams:
    file: "templates/config.yml"
    render: true
    filename: "config/{{.ComponentID}}-config.yml"
```

The template file `templates/config.yml`:
```yaml
project: {{.ProjectID}}
component: {{.ComponentID}}
namespace: {{.OdsNamespace}}
```

**Upload test results:**
```yaml
- type: run
  runParams:
    file: "test-runner.sh"

- type: upload
  uploadParams:
    file: "test-output/results.json"
    filename: "test-results-{{.ComponentID}}.json"
```

**Upload rendered test report:**
```yaml
- type: upload
  uploadParams:
    file: "templates/report.html"
    render: true
    filename: "reports/{{.ComponentID}}-report-{{.Timestamp}}.html"
```

## Common Scenarios

**Save build artifacts:**
```yaml
- type: run
  runParams:
    file: "build.sh"

- type: upload
  uploadParams:
    file: "build-output/artifact.jar"
    repository: "{{.ComponentID}}-builds"
    filename: "builds/{{.ComponentID}}-{{.BuildNumber}}.jar"
```

**Upload configuration after generation:**
```yaml
- type: run
  runParams:
    file: "generate-config.sh"

- type: upload
  uploadParams:
    file: "generated/config.yaml"
    filename: "config/generated-{{.ComponentID}}.yaml"
```

**Upload test report:**
```yaml
- type: run
  runParams:
    file: "run-tests.sh"

- type: upload
  uploadParams:
    file: "test-reports/report.xml"
    filename: "reports/test-report-{{.ComponentID}}.xml"
```

**Upload with template rendering for environment-specific config:**
```yaml
- type: upload
  uploadParams:
    file: "config-template.properties"
    render: true
    filename: "config/{{.ComponentID}}.properties"
```

Template file content:
```properties
app.name={{.ComponentID}}
project={{.ProjectID}}
environment={{.Environment}}
```

## Best Practices

- **Use descriptive filenames**: Include component ID, timestamp, or version in filenames
- **Organize uploads**: Use subdirectories in the filename (e.g., `reports/`, `artifacts/`)
- **Template rendering**: Only enable rendering if your file contains template variables
- **Error recovery**: Ensure uploaded files don't break the build if they contain errors
- **Repository organization**: Use separate repositories for different artifact types when possible
- **Cleanup**: Consider cleanup strategies for old uploads to avoid repository bloat
