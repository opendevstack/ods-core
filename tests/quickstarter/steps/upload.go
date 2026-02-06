package steps

import (
	"testing"
)

// ExecuteUpload handles the upload step type.
func ExecuteUpload(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string, projectName string) {
	if step.UploadParams == nil {
		t.Fatalf("Missing upload parameters.")
	}

	uploadFileToBitbucket(t, step.UploadParams, tmplData, testdataPath, repoName, projectName, config)
}
