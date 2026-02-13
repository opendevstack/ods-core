# bitbucket Step

Interacts with Bitbucket repositories: recreate repositories, upload/delete files, and manage pull requests with optional content verification.

## Basic Usage

```yaml
- type: bitbucket
  description: "Manage Bitbucket resources"
  componentID: "my-component"
  bitbucketParams:
    action: "recreate-repo"          # required – see actions below
    repository: "my-repo"            # repo slug; templating supported
    project: "{{.ProjectID}}"        # optional project key
```

## Common Parameters (bitbucketParams)

- `action` (string, required): One of `recreate-repo`, `approve-pr`, `get-pullrequest`, `delete-files`, `upload-file`.
- `repository` (string, optional): Repository slug. If omitted for some actions, defaults to `<project>-<componentID>` in code paths where needed.
- `project` (string, optional): Bitbucket project key. Defaults to current test project.
- `verify` (object, optional): For PR-related actions; supports `prChecks` map of JSON paths → expected values.

Verification format (for PR actions):

```yaml
verify:
  prChecks:
    .title: "Feature: Add new API endpoint"
    .state: "OPEN"
    .fromRef.displayId: "contains:feature/"
```

Notes:
- JSON paths use a simple dot notation (e.g. `.author.user.name`).
- Expected values support exact match or prefix `contains:` for substring checks.

---

## Action: `recreate-repo`

Deletes an existing repository (waits until removal if scheduled) and creates a fresh one with the same slug.

Parameters:
- `repository` (required)
- `project` (optional)

Example:
```yaml
- type: bitbucket
  componentID: "my-component"
  bitbucketParams:
    action: recreate-repo
    repository: "custom-repo-name"
```

---

## Action: `delete-files`

Delete one or more files/folders from a repository via Git.

Parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `repository` | string | Yes | Repository slug (templating supported). |
| `project` | string | No | Project key (defaults to current). |
| `paths` | array[string] | Yes | Relative paths in the repo; files or folders. |
| `commitMessage` | string | No | Commit message (default: "Remove files/folders"). |

Examples:

```yaml
- type: bitbucket
  description: "Delete configuration file from repository"
  bitbucketParams:
    action: delete-files
    repository: my-repo
    paths:
      - "config/old-settings.yaml"
```

```yaml
- type: bitbucket
  description: "Clean up deprecated files"
  bitbucketParams:
    action: delete-files
    repository: "{{.ProjectID}}-app"
    project: "{{.ProjectID}}"
    paths:
      - "src/deprecated/old-component.ts"
      - "tests/legacy-test.spec.ts"
      - "docs/outdated-guide.md"
      - "legacy-tests/"
    commitMessage: "Clean up deprecated code and documentation"
```

How it works:
1. Clones the repo
2. Removes the specified paths
3. Commits and pushes the change

---

## Action: `upload-file`

Uploads a local file from the quickstarter testdata fixtures into the target repository using Git.

Parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | string | Yes | Source file path relative to the quickstarter `testdata` folder. |
| `filename` | string | No | Target path in the repository; defaults to the basename of `file`. Paths are created if needed. |
| `repository` | string | No | Target repository slug; defaults to `<project>-<componentID>`. |
| `project` | string | No | Project key (defaults to current). |
| `render` | bool | No | If true, renders the source file as a Go template with the test template data. |

Example:

```yaml
- type: bitbucket
  componentID: "my-component"
  bitbucketParams:
    action: upload-file
    file: "fixtures/pipeline/Jenkinsfile"
    repository: "{{.ProjectID}}-my-component"
    filename: "Jenkinsfile"
    render: true
```

Notes:
- If `filename` contains directories (e.g., `tests/acceptance/spec.cy.ts`), the step ensures the path exists before copying.

---

## Action: `get-pullrequest`

Fetches a pull request and optionally validates its content via `verify.prChecks`.

Parameters:
- `repository` (required)
- `project` (optional)
- `pullRequestID` (required)
- `verify.prChecks` (optional) – map of JSONPath → expected value

Example:
```yaml
- type: bitbucket
  componentID: "my-component"
  bitbucketParams:
    action: get-pullrequest
    repository: my-repo
    pullRequestID: "42"
    verify:
      prChecks:
        title: "Feature: Add new API endpoint"
        state: "OPEN"
        description: "contains: This is the expected text..."
```

---

## Action: `approve-pr`

Adds a reviewer (defaults to the CD user if not provided) and approves the PR.

Parameters:
- `repository` (required)
- `project` (optional)
- `pullRequestID` (required)
- `reviewer` (optional)
- `verify.prChecks` (optional) – validations run before approval

Example:
```yaml
- type: bitbucket
  componentID: "my-component"
  bitbucketParams:
    action: approve-pr
    repository: my-repo
    pullRequestID: "42"
    reviewer: "j.doe"
```

---

## General Behavior

1. Authentication via `CD_USER_ID` and `CD_USER_PWD_B64` from the test configuration
2. Action-specific behavior as described above
3. Optional verification for PRs using simple JSON path assertions
4. Meaningful error messages on failure (HTTP status, script output)

## End-to-End Workflow Example

```yaml
- type: bitbucket
  componentID: "feature-component"
  bitbucketParams:
    action: recreate-repo

- type: build
  componentID: "feature-component"
  buildParams:
    branch: "feature/test"

- type: bitbucket
  componentID: "feature-component"
  bitbucketParams:
    action: approve-pr
    repository: feature-repo
    pullRequestID: "1"
```
