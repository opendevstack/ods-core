# build Step

Triggers a Jenkins pipeline build for testing component build and deployment processes. Similar to provision but for testing existing repositories without extensive cleanup.

## Configuration

```yaml
- type: build
  description: "Build component"
  componentID: "my-component"
  buildParams:
    branch: "develop"                    # optional, defaults to "master"
    repository: "my-repo"                # optional, defaults to component repository
    pipeline: "Jenkinsfile"              # optional, Jenkins pipeline file name
    env:                                 # optional, environment variables
      - name: "BUILD_ENV"
        value: "test"
    verify:                              # optional, verification configuration
      testResults: 20
      openShiftResources:
        deployments:
          - "{{.ComponentID}}"
```

## Parameters

### `branch` (optional)
Git branch to use for the pipeline. Defaults to `master`.
Supports Go template rendering (e.g., `{{.ComponentID}}`).

### `repository` (optional)
The Bitbucket repository to build. Defaults to the component's repository.
Supports Go template rendering.

### `pipeline` (optional)
The Jenkins pipeline file to execute. Defaults to `Jenkinsfile`.
Supports Go template rendering.

### `env` (optional)
Array of environment variables to pass to the Jenkins pipeline. Each entry has:
- **`name`** (required): Environment variable name
- **`value`** (required): Environment variable value (supports Go template rendering)

### `verify` (optional)
Verification configuration for the pipeline run. See the provision step's verification section for available verification options.

## How It Works

1. **Repository Setup**: Uses the specified repository and branch
2. **Pipeline Execution**: Runs the Jenkins pipeline with the provided configuration
3. **Verification**: Checks the pipeline execution against specified verification criteria
4. **Error Handling**: Fails the test if the pipeline execution fails

## Examples

**Minimal build:**
```yaml
- type: build
  componentID: "my-app"
  buildParams: {}
```

**Build specific branch:**
```yaml
- type: build
  componentID: "app"
  buildParams:
    branch: "feature/new-feature"
```

**Build with custom environment:**
```yaml
- type: build
  componentID: "service"
  buildParams:
    branch: "main"
    env:
      - name: "ENVIRONMENT"
        value: "staging"
      - name: "DEBUG"
        value: "true"
```

**Build with verification:**
```yaml
- type: build
  componentID: "app"
  buildParams:
    branch: "develop"
    verify:
      testResults: 30
      openShiftResources:
        deployments:
          - "{{.ComponentID}}"
        services:
          - "{{.ComponentID}}"
```
