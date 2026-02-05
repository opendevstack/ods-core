package steps

import (
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"text/template"
	"time"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
	"github.com/opendevstack/ods-core/tests/utils"
)

// BitbucketPullRequest represents a Bitbucket pull request response
type BitbucketPullRequest struct {
	ID          int    `json:"id"`
	Version     int    `json:"version"`
	Title       string `json:"title"`
	Description string `json:"description"`
	State       string `json:"state"`
	Open        bool   `json:"open"`
	Closed      bool   `json:"closed"`
	FromRef     struct {
		ID           string `json:"id"`
		DisplayID    string `json:"displayId"`
		LatestCommit string `json:"latestCommit"`
	} `json:"fromRef"`
	ToRef struct {
		ID           string `json:"id"`
		DisplayID    string `json:"displayId"`
		LatestCommit string `json:"latestCommit"`
	} `json:"toRef"`
	Author struct {
		User struct {
			Name string `json:"name"`
		} `json:"user"`
	} `json:"author"`
	// Raw JSON for flexible querying
	RawJSON map[string]interface{} `json:"-"`
}

// BitbucketPRVerification represents a verification rule for PR content
type BitbucketPRVerification struct {
	JSONPath      string      // JSON path like ".title", ".state", ".fromRef.displayId"
	ExpectedValue interface{} // Expected value (string, bool, int, etc.)
	Description   string      // Human-readable description of what's being checked
}

// BitbucketRepository represents a Bitbucket repository
type BitbucketRepository struct {
	Slug string `json:"slug"`
}

// BitbucketRepositoriesResponse represents the list of repositories response
type BitbucketRepositoriesResponse struct {
	Values []BitbucketRepository `json:"values"`
}

// ExecuteBitbucket handles the bitbucket step type for Bitbucket interactions.
func ExecuteBitbucket(t *testing.T, step TestStep, tmplData TemplateData, config map[string]string, projectName string, testdataPath string) {
	if step.BitbucketParams == nil {
		t.Fatal("Missing bitbucket parameters")
	}

	params := step.BitbucketParams
	action := params.Action
	logger.KeyValue("Action", action)

	switch action {
	case "recreate-repo":
		executeBitbucketRecreateRepo(t, step, params, config, projectName)
	case "approve-pr":
		executeBitbucketApprovePR(t, step, params, config, projectName)
	case "get-pullrequest":
		executeBitbucketGetPullRequest(t, step, params, config, projectName)
	case "delete-files":
		executeBitbucketDeleteFiles(t, step, params, config, projectName)
	case "upload-file":
		executeBitbucketUpload(t, step, params, tmplData, config, projectName, testdataPath)
	default:
		t.Fatalf("Unknown bitbucket action: %s (allowed: recreate-repo, approve-pr, get-pullrequest, delete-files, upload-file)", action)
	}
}

// executeBitbucketRecreateRepo handles repository recreation
func executeBitbucketRecreateRepo(t *testing.T, step TestStep, params *TestStepBitbucketParams, config map[string]string, projectName string) {
	if params.Repository == "" {
		t.Fatal("Missing repository parameter for recreate-repo action")
	}

	project := params.Project
	if project == "" {
		project = projectName
	}
	project = renderTemplate(t, project, CreateTemplateData(config, step.ComponentID, "", projectName))

	repository := renderTemplate(t, params.Repository, CreateTemplateData(config, step.ComponentID, "", projectName))

	logger.Running(fmt.Sprintf("Recreating Bitbucket repository: %s/%s", project, repository))
	logger.KeyValue("Project", project)
	logger.KeyValue("Repository", repository)

	if err := recreateBitbucketRepo(config, project, repository); err != nil {
		logger.Failure(fmt.Sprintf("Recreate repository %s/%s", project, repository), err)
		t.Fatalf("Failed to recreate repository: %v", err)
	}

	logger.Success(fmt.Sprintf("Repository %s/%s recreated successfully", project, repository))
}

// executeBitbucketDeleteFiles handles deletion of files/folders from a repository
func executeBitbucketDeleteFiles(t *testing.T, step TestStep, params *TestStepBitbucketParams, config map[string]string, projectName string) {
	if params.Repository == "" || len(params.Paths) == 0 {
		t.Fatal("Missing repository or paths parameter for delete-files action")
	}

	project := params.Project
	if project == "" {
		project = projectName
	}
	project = renderTemplate(t, project, CreateTemplateData(config, step.ComponentID, "", projectName))

	repository := renderTemplate(t, params.Repository, CreateTemplateData(config, step.ComponentID, "", projectName))

	// Render all paths through template engine
	tmplData := CreateTemplateData(config, step.ComponentID, "", projectName)
	var renderedPaths []string
	for _, path := range params.Paths {
		renderedPaths = append(renderedPaths, renderTemplate(t, path, tmplData))
	}

	commitMessage := params.CommitMessage
	if commitMessage == "" {
		commitMessage = "Remove files/folders"
	}
	commitMessage = renderTemplate(t, commitMessage, tmplData)

	logger.Running(fmt.Sprintf("Deleting files from Bitbucket repository: %s/%s", project, repository))
	logger.KeyValue("Project", project)
	logger.KeyValue("Repository", repository)
	logger.KeyValue("Paths to delete", strings.Join(renderedPaths, ", "))
	logger.KeyValue("Commit message", commitMessage)

	cdUserPassword, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		logger.Failure("Decode CD user password", err)
		t.Fatalf("Failed to decode CD user password: %v", err)
	}

	// Build arguments for the shell script
	scriptArgs := []string{
		fmt.Sprintf("--bitbucket=%s", config["BITBUCKET_URL"]),
		fmt.Sprintf("--user=%s", config["CD_USER_ID"]),
		fmt.Sprintf("--password=%s", cdUserPassword),
		fmt.Sprintf("--project=%s", project),
		fmt.Sprintf("--repository=%s", repository),
		fmt.Sprintf("--message=%s", commitMessage),
	}

	// Add each path to delete as a separate argument
	for _, path := range renderedPaths {
		scriptArgs = append(scriptArgs, fmt.Sprintf("--files=%s", path))
	}

	logger.Waiting("Executing Bitbucket delete-files script")
	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/delete-files-from-bitbucket-with-git.sh", scriptArgs, []string{})
	if err != nil {
		logger.Error(fmt.Sprintf("Bitbucket delete-files script output:\n%s", stdout))
		logger.Failure("Delete files from Bitbucket", err)
		t.Fatalf(
			"Execution of `delete-files-from-bitbucket-with-git.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			stdout,
			stderr,
			err)
	} else {
		logger.Success(fmt.Sprintf("Deleted %d file(s)/folder(s) from %s/%s", len(renderedPaths), project, repository))
	}
}

// executeBitbucketUpload handles uploading a file to a Bitbucket repository
func executeBitbucketUpload(t *testing.T, step TestStep, params *TestStepBitbucketParams, tmplData TemplateData, config map[string]string, projectName string, testdataPath string) {
	if params.File == "" {
		t.Fatal("Missing file parameter for upload-file action")
	}

	project := params.Project
	if project == "" {
		project = projectName
	}
	project = renderTemplate(t, project, tmplData)

	defaultRepository := fmt.Sprintf("%s-%s", strings.ToLower(projectName), step.ComponentID)
	uploadParams := &TestStepUploadParams{
		File:       params.File,
		Filename:   params.Filename,
		Render:     params.Render,
		Repository: params.Repository,
	}

	uploadFileToBitbucket(t, uploadParams, tmplData, testdataPath, defaultRepository, project, config)
}

// uploadFileToBitbucket uploads a file to a Bitbucket repository using the shared script.
func uploadFileToBitbucket(t *testing.T, uploadParams *TestStepUploadParams, tmplData TemplateData, testdataPath string, defaultRepository string, project string, config map[string]string) {
	if uploadParams == nil || uploadParams.File == "" {
		t.Fatalf("Missing upload parameters.")
	}

	filename := uploadParams.Filename
	if filename == "" {
		filename = filepath.Base(uploadParams.File)
	}

	fileToUpload := filepath.Clean(filepath.Join(testdataPath, uploadParams.File))

	if _, err := os.Stat(fileToUpload); err != nil {
		logger.Failure("Load file to upload", err)
		t.Fatalf("Failed to load file to upload: \nErr: %s\n", err)
	}

	if uploadParams.Render {
		logger.Waiting("Rendering template to upload")
		if err := renderUploadFile(fileToUpload, tmplData); err != nil {
			logger.Failure("Render file", err)
			t.Fatalf("Failed to render file: \nErr: %s\n", err)
		}
	}

	targetRepository := defaultRepository
	if len(uploadParams.Repository) > 0 {
		targetRepository = renderTemplate(t, uploadParams.Repository, tmplData)
	}

	project = renderTemplate(t, project, tmplData)

	logger.Running(fmt.Sprintf("Uploading file %s", uploadParams.File))
	logger.KeyValue("Repository", targetRepository)
	logger.KeyValue("Filename", filename)
	logger.Waiting("Executing BitBucket upload script")

	cdUserPassword, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		logger.Failure("Decode CD user password", err)
		t.Fatalf("Execution of `upload-file-to-bitbucket-with-git.sh` failed: \nErr: %s\n", err)
	}

	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/upload-file-to-bitbucket-with-git.sh", []string{
		fmt.Sprintf("--bitbucket=%s", config["BITBUCKET_URL"]),
		fmt.Sprintf("--user=%s", config["CD_USER_ID"]),
		fmt.Sprintf("--password=%s", cdUserPassword),
		fmt.Sprintf("--project=%s", project),
		fmt.Sprintf("--repository=%s", targetRepository),
		fmt.Sprintf("--file=%s", fileToUpload),
		fmt.Sprintf("--filename=%s", filename),
	}, []string{})
	if err != nil {
		logger.Error(fmt.Sprintf("BitBucket upload script output:\n%s", stdout))
		logger.Failure("Upload file to BitBucket", err)
		t.Fatalf(
			"Execution of `upload-file-to-bitbucket-with-git.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			stdout,
			stderr,
			err)
	}

	logger.Success(fmt.Sprintf("Uploaded file %s to %s/%s", filename, project, targetRepository))
}

// renderUploadFile renders the given file as a Go template using tmplData.
func renderUploadFile(filePath string, tmplData TemplateData) error {
	tmpl, err := template.ParseFiles(filePath)
	if err != nil {
		return err
	}

	outputFile, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer outputFile.Close() //nolint:errcheck

	logger.Waiting("Rendering file")
	if err := tmpl.Execute(outputFile, tmplData); err != nil {
		return err
	}

	logger.Success("File rendered")
	return nil
}

func executeBitbucketGetPullRequest(t *testing.T, step TestStep, params *TestStepBitbucketParams, config map[string]string, projectName string) {
	if params.Repository == "" || params.PullRequestID == "" {
		t.Fatal("Missing repository or pullRequestID parameter for get-pullrequest action")
	}

	project := params.Project
	if project == "" {
		project = projectName
	}
	project = renderTemplate(t, project, CreateTemplateData(config, step.ComponentID, "", projectName))

	repository := renderTemplate(t, params.Repository, CreateTemplateData(config, step.ComponentID, "", projectName))
	prID := params.PullRequestID

	logger.Running(fmt.Sprintf("Fetching Bitbucket pull request: %s/%s#%s", project, repository, prID))
	logger.KeyValue("Project", project)
	logger.KeyValue("Repository", repository)
	logger.KeyValue("Pull Request ID", prID)

	pr, err := getBitbucketPR(config, project, repository, prID)
	if err != nil {
		logger.Failure(fmt.Sprintf("Get PR %s/%s#%s details", project, repository, prID), err)
		t.Fatalf("Failed to get pull request details: %v", err)
	}
	if pr == nil {
		logger.Failure(fmt.Sprintf("PR %s/%s#%s does not exist", project, repository, prID), nil)
		t.Fatalf("Pull request %s/%s#%s does not exist", project, repository, prID)
	}

	logger.Success(fmt.Sprintf("Pull request %s/%s#%s found - Title: '%s', State: %s, Branch: %s",
		project, repository, prID, pr.Title, pr.State, pr.FromRef.DisplayID))
	logger.KeyValue("Latest commit", pr.FromRef.LatestCommit)
	logger.KeyValue("Author", pr.Author.User.Name)

	// Verify PR content if verification rules are provided
	if params.Verify != nil && params.Verify.PRChecks != nil {
		logger.Running(fmt.Sprintf("Verifying pull request content: %s/%s#%s", project, repository, prID))
		verifications := buildVerificationsFromMap(params.Verify.PRChecks)
		if err := verifyBitbucketPRContent(pr, verifications); err != nil {
			logger.Failure(fmt.Sprintf("PR content verification failed for %s/%s#%s", project, repository, prID), err)
			t.Fatalf("Pull request content verification failed: %v", err)
		}
		logger.Success(fmt.Sprintf("Pull request content verified successfully (%d checks passed)", len(verifications)))
	}
}

// executeBitbucketApprovePR handles pull request approval with validation, reviewer addition, and approval
func executeBitbucketApprovePR(t *testing.T, step TestStep, params *TestStepBitbucketParams, config map[string]string, projectName string) {
	if params.Repository == "" || params.PullRequestID == "" {
		t.Fatal("Missing repository or pullRequestID parameter for approve-pr action")
	}

	project := params.Project
	if project == "" {
		project = projectName
	}
	project = renderTemplate(t, project, CreateTemplateData(config, step.ComponentID, "", projectName))

	repository := renderTemplate(t, params.Repository, CreateTemplateData(config, step.ComponentID, "", projectName))
	prID := params.PullRequestID
	reviewer := params.Reviewer

	logger.Running(fmt.Sprintf("Approving Bitbucket pull request: %s/%s#%s", project, repository, prID))
	logger.KeyValue("Project", project)
	logger.KeyValue("Repository", repository)
	logger.KeyValue("Pull Request ID", prID)
	if reviewer != "" {
		logger.KeyValue("Reviewer to add", reviewer)
	}

	// Step 1: Get PR details (validates existence and retrieves commit info)
	logger.Running(fmt.Sprintf("Fetching pull request details: %s/%s#%s", project, repository, prID))
	pr, err := getBitbucketPR(config, project, repository, prID)
	if err != nil {
		logger.Failure(fmt.Sprintf("Get PR %s/%s#%s details", project, repository, prID), err)
		t.Fatalf("Failed to get pull request details: %v", err)
	}
	if pr == nil {
		logger.Failure(fmt.Sprintf("PR %s/%s#%s does not exist", project, repository, prID), nil)
		t.Fatalf("Pull request %s/%s#%s does not exist", project, repository, prID)
	}
	logger.Success(fmt.Sprintf("Pull request %s/%s#%s found - Title: '%s', State: %s, Branch: %s",
		project, repository, prID, pr.Title, pr.State, pr.FromRef.DisplayID))
	logger.KeyValue("Latest commit", pr.FromRef.LatestCommit)
	logger.KeyValue("Author", pr.Author.User.Name)

	// Step 1.5: Verify PR content if verification rules are provided
	if params.Verify != nil && params.Verify.PRChecks != nil {
		logger.Running(fmt.Sprintf("Verifying pull request content: %s/%s#%s", project, repository, prID))
		verifications := buildVerificationsFromMap(params.Verify.PRChecks)
		if err := verifyBitbucketPRContent(pr, verifications); err != nil {
			logger.Failure(fmt.Sprintf("PR content verification failed for %s/%s#%s", project, repository, prID), err)
			t.Fatalf("Pull request content verification failed: %v", err)
		}
		logger.Success(fmt.Sprintf("Pull request content verified successfully (%d checks passed)", len(verifications)))
	}

	// Step 2: Add reviewer (use CD_USER if not specified)
	reviewerToAdd := reviewer
	if reviewerToAdd == "" {
		reviewerToAdd = config["CD_USER_ID"]
	}
	logger.Running(fmt.Sprintf("Adding reviewer %s to pull request: %s/%s#%s", reviewerToAdd, project, repository, prID))
	if err := addBitbucketPRReviewer(config, project, repository, prID, reviewerToAdd); err != nil {
		logger.Failure(fmt.Sprintf("Add reviewer %s to PR %s/%s#%s", reviewerToAdd, project, repository, prID), err)
		t.Fatalf("Failed to add reviewer: %v", err)
	}
	logger.Success(fmt.Sprintf("Reviewer %s added to pull request", reviewerToAdd))

	// Step 3: Approve the pull request
	logger.Running(fmt.Sprintf("Approving pull request: %s/%s#%s", project, repository, prID))
	if err := approveBitbucketPR(config, project, repository, prID); err != nil {
		logger.Failure(fmt.Sprintf("Approve PR %s/%s#%s", project, repository, prID), err)
		t.Fatalf("Failed to approve pull request: %v", err)
	}

	logger.Success(fmt.Sprintf("Pull request %s/%s#%s approved successfully", project, repository, prID))
}

// recreateBitbucketRepo recreates a Bitbucket repository
func recreateBitbucketRepo(config map[string]string, project string, repo string) error {
	password, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		return fmt.Errorf("Error decoding cd_user password: %w", err)
	}

	// Delete the repository
	url := fmt.Sprintf("%s/rest/api/1.0/projects/%s/repos/%s",
		config["BITBUCKET_URL"], project, repo)

	tlsConfig := &tls.Config{InsecureSkipVerify: true}
	client := &http.Client{Transport: &http.Transport{TLSClientConfig: tlsConfig}}

	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return fmt.Errorf("Failed to create delete request for repository %s/%s: %w", project, repo, err)
	}

	req.SetBasicAuth(config["CD_USER_ID"], string(password))

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("Failed to delete repository %s/%s: %w", project, repo, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	// Accept 202 (Accepted - scheduled for deletion), 204 (No Content), or 200 (OK)
	if resp.StatusCode != http.StatusAccepted && resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body) //nolint:errcheck
		return fmt.Errorf("Failed to delete repository %s/%s: HTTP %d - %s", project, repo, resp.StatusCode, string(body))
	}

	// If deletion was scheduled (202), wait for it to complete
	if resp.StatusCode == http.StatusAccepted {
		logger.Info(fmt.Sprintf("Repository %s/%s scheduled for deletion, waiting...", project, repo))
		// Wait for repository to be deleted
		for i := 0; i < 30; i++ {
			time.Sleep(2 * time.Second)
			exists, err := checkBitbucketRepositoryExists(config, project, repo)
			if err != nil {
				return fmt.Errorf("Failed to check repository deletion status: %w", err)
			}
			if !exists {
				logger.Success(fmt.Sprintf("Repository %s/%s deleted", project, repo))
				break
			}
			if i == 29 {
				return fmt.Errorf("Timeout waiting for repository %s/%s to be deleted", project, repo)
			}
			logger.Info(fmt.Sprintf("Waiting for repository deletion (attempt %d/30)...", i+1))
		}
	}

	// Recreate the repository
	createURL := fmt.Sprintf("%s/rest/api/1.0/projects/%s/repos",
		config["BITBUCKET_URL"], project)

	payload := fmt.Sprintf(`{"name":"%s","scmId":"git"}`, repo)

	req, err = http.NewRequest("POST", createURL, strings.NewReader(payload))
	if err != nil {
		return fmt.Errorf("Failed to create repository creation request for %s/%s: %w", project, repo, err)
	}

	req.SetBasicAuth(config["CD_USER_ID"], string(password))
	req.Header.Set("Accept", "application/json;charset=UTF-8")
	req.Header.Set("Content-Type", "application/json")

	resp, err = client.Do(req)
	if err != nil {
		return fmt.Errorf("Failed to recreate repository %s/%s: %w", project, repo, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body) //nolint:errcheck
		return fmt.Errorf("Failed to recreate repository %s/%s: HTTP %d - %s", project, repo, resp.StatusCode, string(body))
	}

	return nil
}

// approveBitbucketPR approves a pull request in Bitbucket
func approveBitbucketPR(config map[string]string, project string, repo string, prID string) error {
	password, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		return fmt.Errorf("Error decoding cd_user password: %w", err)
	}

	url := fmt.Sprintf("%s/rest/api/latest/projects/%s/repos/%s/pull-requests/%s/review",
		config["BITBUCKET_URL"], project, repo, prID)

	payload := `{"participantStatus":"APPROVED"}`

	tlsConfig := &tls.Config{InsecureSkipVerify: true}
	client := &http.Client{Transport: &http.Transport{TLSClientConfig: tlsConfig}}

	req, err := http.NewRequest("PUT", url, strings.NewReader(payload))
	if err != nil {
		return fmt.Errorf("Failed to create request to approve PR %s/%s#%s: %w", project, repo, prID, err)
	}

	req.SetBasicAuth(config["CD_USER_ID"], string(password))
	req.Header.Set("Accept", "application/json;charset=UTF-8")
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("Failed to approve PR %s/%s#%s: %w", project, repo, prID, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body) //nolint:errcheck
		return fmt.Errorf("Failed to approve PR %s/%s#%s: HTTP %d - %s", project, repo, prID, resp.StatusCode, string(body))
	}

	return nil
}

// getBitbucketPR retrieves the full pull request details
func getBitbucketPR(config map[string]string, project string, repo string, prID string) (*BitbucketPullRequest, error) {
	password, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		return nil, fmt.Errorf("Error decoding cd_user password: %w", err)
	}

	url := fmt.Sprintf("%s/rest/api/1.0/projects/%s/repos/%s/pull-requests/%s",
		config["BITBUCKET_URL"], project, repo, prID)

	tlsConfig := &tls.Config{InsecureSkipVerify: true}
	client := &http.Client{Transport: &http.Transport{TLSClientConfig: tlsConfig}}

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("Failed to create request for PR %s/%s#%s: %w", project, repo, prID, err)
	}

	req.SetBasicAuth(config["CD_USER_ID"], string(password))

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("Failed to get pull request %s/%s#%s: %w", project, repo, prID, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode == http.StatusNotFound {
		return nil, nil // PR doesn't exist
	}

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body) //nolint:errcheck
		return nil, fmt.Errorf("Failed to get pull request %s/%s#%s: HTTP %d - %s", project, repo, prID, resp.StatusCode, string(body))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("Failed to read response body for PR %s/%s#%s: %w", project, repo, prID, err)
	}

	var pr BitbucketPullRequest
	err = json.Unmarshal(body, &pr)
	if err != nil {
		return nil, fmt.Errorf("Failed to parse PR response for %s/%s#%s: %w", project, repo, prID, err)
	}

	// Also unmarshal to raw map for flexible querying
	var rawJSON map[string]interface{}
	err = json.Unmarshal(body, &rawJSON)
	if err == nil {
		pr.RawJSON = rawJSON
	}

	return &pr, nil
}

// verifyBitbucketPRContent verifies pull request content using JSON path queries
func verifyBitbucketPRContent(pr *BitbucketPullRequest, verifications []BitbucketPRVerification) error {
	if pr == nil {
		return fmt.Errorf("PR is nil")
	}

	if pr.RawJSON == nil {
		return fmt.Errorf("PR raw JSON data is not available")
	}

	for _, verification := range verifications {
		actualValue, err := extractJSONPathValue(pr.RawJSON, verification.JSONPath)
		if err != nil {
			return fmt.Errorf("Failed to extract value from path '%s': %w", verification.JSONPath, err)
		}

		if !compareValues(actualValue, verification.ExpectedValue) {
			return fmt.Errorf("%s: expected '%v', got '%v' (path: %s)",
				verification.Description, verification.ExpectedValue, actualValue, verification.JSONPath)
		}
		logger.Debug("%s: expected '%v', got '%v' (path: %s)",
			verification.Description, verification.ExpectedValue, actualValue, verification.JSONPath)
	}

	return nil
}

// extractJSONPathValue extracts a value from a JSON object using a simple path notation
// Supports paths like ".title", ".state", ".fromRef.displayId", ".author.user.name"
func extractJSONPathValue(data map[string]interface{}, path string) (interface{}, error) {
	if path == "" {
		return nil, fmt.Errorf("Empty path")
	}

	// Remove leading dot if present
	path = strings.TrimPrefix(path, ".")

	// Split path by dots
	parts := strings.Split(path, ".")

	var current interface{} = data

	for _, part := range parts {
		switch v := current.(type) {
		case map[string]interface{}:
			if val, ok := v[part]; ok {
				current = val
			} else {
				return nil, fmt.Errorf("Key '%s' not found in path '%s'", part, path)
			}
		default:
			return nil, fmt.Errorf("Cannot navigate through non-object at '%s' in path '%s'", part, path)
		}
	}

	return current, nil
}

// compareValues compares two values for equality, handling different types
func compareValues(actual, expected interface{}) bool {
	// Handle nil cases
	if actual == nil && expected == nil {
		return true
	}
	if actual == nil || expected == nil {
		return false
	}

	// Convert both to strings for comparison
	actualStr := fmt.Sprintf("%v", actual)
	expectedStr := fmt.Sprintf("%v", expected)

	// Check for "contains:" prefix for substring matching
	if strings.HasPrefix(expectedStr, "contains:") {
		substring := strings.TrimPrefix(expectedStr, "contains:")
		return strings.Contains(actualStr, substring)
	}

	// Exact match
	return actualStr == expectedStr
}

// buildVerificationsFromMap converts a map of JSON paths to expected values into BitbucketPRVerification structs
func buildVerificationsFromMap(checks map[string]interface{}) []BitbucketPRVerification {
	var verifications []BitbucketPRVerification
	for path, expectedValue := range checks {
		verifications = append(verifications, BitbucketPRVerification{
			JSONPath:      path,
			ExpectedValue: expectedValue,
			Description:   fmt.Sprintf("Check '%s'", path),
		})
	}
	return verifications
}

// addBitbucketPRReviewer adds a user as a reviewer to a pull request
func addBitbucketPRReviewer(config map[string]string, project string, repo string, prID string, username string) error {
	password, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		return fmt.Errorf("Error decoding cd_user password: %w", err)
	}

	url := fmt.Sprintf("%s/rest/api/1.0/projects/%s/repos/%s/pull-requests/%s/participants",
		config["BITBUCKET_URL"], project, repo, prID)

	payload := fmt.Sprintf(`{"role":"REVIEWER","user":{"name":"%s"}}`, username)

	// Create HTTP client with insecure TLS
	tlsConfig := &tls.Config{InsecureSkipVerify: true}
	client := &http.Client{Transport: &http.Transport{TLSClientConfig: tlsConfig}}

	req, err := http.NewRequest("POST", url, strings.NewReader(payload))
	if err != nil {
		return fmt.Errorf("Failed to create request to add reviewer to PR %s/%s#%s: %w", project, repo, prID, err)
	}

	req.SetBasicAuth(config["CD_USER_ID"], string(password))
	req.Header.Set("Accept", "application/json;charset=UTF-8")
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("Failed to add reviewer to PR %s/%s#%s: %w", project, repo, prID, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body) //nolint:errcheck
		return fmt.Errorf("Failed to add reviewer to PR %s/%s#%s: HTTP %d - %s", project, repo, prID, resp.StatusCode, string(body))
	}

	return nil
}

// checkBitbucketRepositoryExists checks if a repository exists in a Bitbucket project
func checkBitbucketRepositoryExists(config map[string]string, project string, repo string) (bool, error) {
	password, err := base64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		return false, fmt.Errorf("Error decoding cd_user password: %w", err)
	}

	url := fmt.Sprintf("%s/rest/api/1.0/projects/%s/repos/%s", config["BITBUCKET_URL"], project, repo)

	tlsConfig := &tls.Config{InsecureSkipVerify: true}
	client := &http.Client{Transport: &http.Transport{TLSClientConfig: tlsConfig}}

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return false, fmt.Errorf("Failed to create request to check repository %s/%s: %w", project, repo, err)
	}

	req.SetBasicAuth(config["CD_USER_ID"], string(password))

	resp, err := client.Do(req)
	if err != nil {
		return false, fmt.Errorf("Failed to check repository %s/%s: %w", project, repo, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	return resp.StatusCode == http.StatusOK, nil
}
