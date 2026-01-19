# provision Step

Prepares the environment for testing by recreating Bitbucket repositories, cleaning up OpenShift resources, and executing Jenkins pipelines with customizable configuration.

## Configuration

```yaml
- type: provision
  description: "Provision component resources"
  componentID: "my-component"
  provisionParams:
    quickstarter: "docker"                  # optional, defaults to quickstarter under test
    pipeline: "Jenkinsfile"                 # optional, Jenkins pipeline file
    branch: "main"                          # optional, Git branch, defaults to ODS_GIT_REF
    agentImageTag: "latest"                 # optional, image tag for agent, defaults to ODS_IMAGE_TAG
    sharedLibraryRef: "master"              # optional, shared library reference, defaults to agentImageTag
    env:                                    # optional, additional environment variables
      - name: "CUSTOM_VAR"
        value: "custom-value"
    testResourcesCleanUp:                   # optional, resources to clean before provisioning
      - resourceType: "pod"
        resourceName: "old-pod"
        namespace: "dev"                    # optional, defaults to "dev"
    verify:                                 # optional, pipeline verification configuration
      logs:
        - "Build started"
        - "Deployment successful"
```

## Parameters

### `quickstarter` (optional)
The quickstarter to use for provisioning. Can be:
- Simple name: `docker`
- With repository: `quickstarters/docker`
- Defaults to the quickstarter under test

Supports Go template rendering (e.g., `{{.ComponentID}}`).

### `pipeline` (optional)
The Jenkins pipeline file to execute. Defaults to `Jenkinsfile`.

### `branch` (optional)
Git branch to use for the pipeline. Defaults to the value of `ODS_GIT_REF` from configuration.
Supports Go template rendering.

### `agentImageTag` (optional)
Docker image tag for the Jenkins agent. Defaults to `ODS_IMAGE_TAG` from configuration.
Supports Go template rendering.

### `sharedLibraryRef` (optional)
Git reference for the shared library. Defaults to the value of `agentImageTag`.
Supports Go template rendering.

### `env` (optional)
Array of additional environment variables to pass to the Jenkins pipeline. Each entry has:
- **`name`** (required): Environment variable name
- **`value`** (required): Environment variable value (supports Go template rendering)

### `testResourcesCleanUp` (optional)
Array of OpenShift resources to clean up before provisioning. Each entry has:
- **`resourceType`** (required): Kubernetes resource type (e.g., `pod`, `deployment`, `job`)
- **`resourceName`** (required): Name of the resource to delete
- **`namespace`** (optional): Namespace suffix (defaults to `dev`). Full namespace is `{PROJECT_ID}-{namespace}`

### `verify` (optional)
Verification configuration for the Jenkins pipeline run. See [Verification Configuration](#verification-configuration).

## Verification Configuration

The `verify` section allows checking that the Jenkins pipeline executed successfully by validating various aspects:

### `jenkinsStages` (optional)
Path to a JSON golden file containing expected Jenkins pipeline stages.
The build stages are compared against this file to ensure the pipeline structure matches expectations.

```yaml
verify:
  jenkinsStages: "expected-stages.json"
```

### `sonarScan` (optional)
Path to a JSON golden file containing expected SonarQube analysis results.
Verifies that code quality metrics match expected values.

```yaml
verify:
  sonarScan: "expected-sonar-results.json"
```

### `runAttachments` (optional)
Array of artifact names that should be attached to the Jenkins build.
Verifies that specific build artifacts (logs, reports, binaries) were created and attached.

```yaml
verify:
  runAttachments:
    - "{{.ComponentID}}-artifact.jar"
    - "build-report.html"
    - "test-results.xml"
```

Each attachment name supports Go template rendering.

### `testResults` (optional)
Minimum number of unit tests that should have been executed.
Verifies that at least this many unit tests were run during the build.

```yaml
verify:
  testResults: 50  # Expect at least 50 unit tests
```

### `openShiftResources` (optional)
Configuration for verifying OpenShift/Kubernetes resources created by the pipeline.

**Namespace** (optional):
Target namespace for resource verification. Defaults to `{PROJECT_ID}-dev`.
Supports Go template rendering.

**Resource Types** (optional):
Arrays of resource names to verify exist in the namespace. Supported types:

- **`buildConfigs`**: BuildConfig resources
- **`deploymentConfigs`**: DeploymentConfig resources
- **`deployments`**: Kubernetes Deployments
- **`statefulSets`**: StatefulSet resources
- **`daemonSets`**: DaemonSet resources
- **`replicaSets`**: ReplicaSet resources
- **`services`**: Kubernetes Services
- **`imageStreams`**: OpenShift ImageStream resources
- **`routes`**: OpenShift Route resources
- **`ingresses`**: Kubernetes Ingress resources
- **`configMaps`**: ConfigMap resources
- **`secrets`**: Secret resources
- **`persistentVolumeClaims`**: PVC resources
- **`serviceAccounts`**: ServiceAccount resources
- **`roles`**: RBAC Role resources
- **`roleBindings`**: RBAC RoleBinding resources
- **`networkPolicies`**: NetworkPolicy resources
- **`jobs`**: Kubernetes Job resources
- **`cronJobs`**: CronJob resources
- **`pods`**: Pod resources
- **`horizontalPodAutoscalers`**: HPA resources

Each resource name supports Go template rendering.

```yaml
verify:
  openShiftResources:
    namespace: "{{.ProjectID}}-dev"
    deployments:
      - "{{.ComponentID}}"
      - "{{.ComponentID}}-secondary"
    services:
      - "{{.ComponentID}}"
      - "{{.ComponentID}}-api"
    routes:
      - "{{.ComponentID}}"
    configMaps:
      - "{{.ComponentID}}-config"
```

### Verification Strategies

By default, verification uses the **aggregate** strategy, which collects all verification failures and reports them together. You can also use **fail-fast** strategy to stop at the first failure:

```yaml
verify:
  strategy: "fail-fast"  # or "aggregate" (default)
  jenkinsStages: "expected-stages.json"
  testResults: 25
```

## How It Works

1. **Bitbucket Preparation**: Recreates the Bitbucket repository for the component
2. **Resource Cleanup**: Deletes existing OpenShift resources in dev, test, and cd namespaces
3. **Test Cleanup**: Removes any test-specific resources if specified
4. **Cleanup Registration**: Registers automatic cleanup to run after the test completes
5. **Pipeline Execution**: Runs the Jenkins pipeline with merged configuration
6. **Verification**: Checks the pipeline execution against specified verification criteria
7. **Resource Preservation** (optional): If `KEEP_RESOURCES=true` environment variable is set, skips final cleanup

## Automatically Provided Environment Variables

The Jenkins pipeline automatically receives:

- **`ODS_NAMESPACE`**: ODS cluster namespace
- **`ODS_GIT_REF`**: ODS Git reference
- **`ODS_IMAGE_TAG`**: ODS image tag
- **`ODS_BITBUCKET_PROJECT`**: ODS Bitbucket project
- **`AGENT_IMAGE_TAG`**: Docker agent image tag
- **`SHARED_LIBRARY_REF`**: Shared library Git reference
- **`PROJECT_ID`**: Project identifier
- **`COMPONENT_ID`**: Component identifier
- **`GIT_URL_HTTP`**: HTTP Git URL to the Bitbucket repository
- **Custom `env` variables**: Any additional variables defined in provisionParams

## Examples

**Minimal provision:**
```yaml
- type: provision
  componentID: "my-component"
  provisionParams: {}
```

**Provision with specific quickstarter:**
```yaml
- type: provision
  componentID: "backend"
  provisionParams:
    quickstarter: "go"
    branch: "develop"
```

**Provision with custom agent and shared library:**
```yaml
- type: provision
  componentID: "frontend"
  provisionParams:
    quickstarter: "node"
    agentImageTag: "v1.2.3"
    sharedLibraryRef: "release/1.2"
```

**Provision with custom environment variables:**
```yaml
- type: provision
  componentID: "app"
  provisionParams:
    branch: "main"
    env:
      - name: "BUILD_TYPE"
        value: "production"
      - name: "DEPLOYMENT_REGION"
        value: "us-east-1"
```

**Provision with resource cleanup:**
```yaml
- type: provision
  componentID: "service"
  provisionParams:
    quickstarter: "python"
    testResourcesCleanUp:
      - resourceType: "pod"
        resourceName: "old-service-pod"
      - resourceType: "configmap"
        resourceName: "legacy-config"
        namespace: "test"
```

**Provision with Jenkins stages verification:**
```yaml
- type: provision
  componentID: "backend"
  provisionParams:
    quickstarter: "go"
    verify:
      jenkinsStages: "golden/jenkins-stages.json"
      testResults: 30
```

**Provision with SonarQube verification:**
```yaml
- type: provision
  componentID: "api"
  provisionParams:
    quickstarter: "java"
    verify:
      sonarScan: "golden/sonar-results.json"
      testResults: 100
```

**Provision with artifact verification:**
```yaml
- type: provision
  componentID: "app"
  provisionParams:
    quickstarter: "docker"
    verify:
      runAttachments:
        - "{{.ComponentID}}-build.log"
        - "{{.ComponentID}}-image.tar"
        - "test-results.xml"
```

**Provision with OpenShift resource verification:**
```yaml
- type: provision
  componentID: "microservice"
  provisionParams:
    quickstarter: "python"
    verify:
      openShiftResources:
        namespace: "{{.ProjectID}}-dev"
        deployments:
          - "{{.ComponentID}}"
        services:
          - "{{.ComponentID}}"
          - "{{.ComponentID}}-api"
        routes:
          - "{{.ComponentID}}"
        configMaps:
          - "{{.ComponentID}}-config"
        secrets:
          - "{{.ComponentID}}-credentials"
```

**Provision with comprehensive verification:**
```yaml
- type: provision
  componentID: "api"
  provisionParams:
    quickstarter: "java"
    verify:
      strategy: "fail-fast"
      jenkinsStages: "golden/java-stages.json"
      sonarScan: "golden/java-sonar.json"
      testResults: 50
      runAttachments:
        - "{{.ComponentID}}-*.jar"
        - "coverage-report.html"
      openShiftResources:
        namespace: "{{.ProjectID}}-dev"
        deployments:
          - "{{.ComponentID}}"
        services:
          - "{{.ComponentID}}"
        routes:
          - "{{.ComponentID}}"
```

**Provision with repository override:**
```yaml
- type: provision
  componentID: "shared-lib"
  provisionParams:
    quickstarter: "shared-libraries/groovy"
```

**Provision with all options:**
```yaml
- type: provision
  componentID: "microservice"
  provisionParams:
    quickstarter: "node"
    pipeline: "Jenkinsfile.prod"
    branch: "release/2.0"
    agentImageTag: "v2.0.0"
    sharedLibraryRef: "release/2.0"
    env:
      - name: "ENVIRONMENT"
        value: "production"
      - name: "REPLICAS"
        value: "3"
      - name: "LOG_LEVEL"
        value: "info"
    testResourcesCleanUp:
      - resourceType: "pvc"
        resourceName: "temp-storage"
    verify:
      logs:
        - "Provisioning started"
        - "All tests passed"
        - "Deployment successful"
```

## Common Scenarios

**Test a quickstarter in isolation:**
```yaml
- type: provision
  componentID: "test-component"
  provisionParams:
    quickstarter: "docker"
```

**Test with specific Git branch:**
```yaml
- type: provision
  componentID: "component"
  provisionParams:
    branch: "feature/new-build-system"
```

**Test with custom Jenkins agent version:**
```yaml
- type: provision
  componentID: "component"
  provisionParams:
    agentImageTag: "3.0.0"
    sharedLibraryRef: "3.0"
```

**Provision and run tests:**
```yaml
- type: provision
  componentID: "app"
  provisionParams:
    quickstarter: "python"

- type: wait
  waitParams:
    condition: "deployment-complete"
    resource: "deployment/app"

- type: run
  componentID: "app"
  runParams:
    file: "integration-tests.sh"
```

**Clean up specific test resources:**
```yaml
- type: provision
  componentID: "service"
  provisionParams:
    testResourcesCleanUp:
      - resourceType: "pod"
        resourceName: "temporary-test-pod"
      - resourceType: "configmap"
        resourceName: "test-config"
        namespace: "test"
```

## Best Practices

- **Use verified logs**: Include specific log messages in verify section to ensure pipeline completed successfully
- **Clean test resources**: Specify any temporary resources to clean up before provisioning
- **Use meaningful component IDs**: Choose descriptive component IDs that match your quickstarter type
- **Set KEEP_RESOURCES for debugging**: Set environment variable `KEEP_RESOURCES=true` to preserve resources for investigation
- **Version management**: Pin agent and shared library versions for reproducible builds
- **Custom environment**: Use `env` parameter for environment-specific configuration
- **Branch strategy**: Use feature branches to test new pipeline changes before merging to main
