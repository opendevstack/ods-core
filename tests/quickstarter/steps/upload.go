package steps

import (
	b64 "encoding/base64"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"text/template"

	"github.com/opendevstack/ods-core/tests/utils"
)

// ExecuteUpload handles the upload step type.
func ExecuteUpload(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string, projectName string) {
	if step.UploadParams == nil || step.UploadParams.File == "" {
		t.Fatalf("Missing upload parameters.")
	}
	if step.UploadParams.Filename == "" {
		step.UploadParams.Filename = filepath.Base(step.UploadParams.File)
	}
	cdUserPassword, err := b64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		t.Fatalf("Execution of `upload-file-to-bitbucket.sh` failed: \nErr: %s\n", err)
	}

	fileToUpload := fmt.Sprintf("%s/%s", testdataPath, step.UploadParams.File)

	if step.UploadParams.Render {
		fmt.Printf("Rendering template to upload.\n")
		tmpl, err := template.ParseFiles(fileToUpload)
		if err != nil {
			t.Fatalf("Failed to load file to upload: \nErr: %s\n", err)

		}
		outputFile, err := os.Create(fileToUpload)
		if err != nil {
			t.Fatalf("Error creating output file: \nErr: %s\n", err)

		}
		defer outputFile.Close()
		fmt.Printf("Rendering file.\n")
		err = tmpl.Execute(outputFile, tmplData)
		if err != nil {
			t.Fatalf("Failed to render file: \nErr: %s\n", err)
		}
	}
	var targetRepository string = repoName
	if len(step.UploadParams.Repository) > 0 {
		targetRepository = renderTemplate(t, step.UploadParams.Repository, tmplData)
	}
	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/upload-file-to-bitbucket-with-git.sh", []string{
		fmt.Sprintf("--bitbucket=%s", config["BITBUCKET_URL"]),
		fmt.Sprintf("--user=%s", config["CD_USER_ID"]),
		fmt.Sprintf("--password=%s", cdUserPassword),
		fmt.Sprintf("--project=%s", projectName),
		fmt.Sprintf("--repository=%s", targetRepository),
		fmt.Sprintf("--file=%s", fileToUpload),
		fmt.Sprintf("--filename=%s", step.UploadParams.Filename),
	}, []string{})
	fmt.Printf("%s", stdout)
	if err != nil {
		t.Fatalf(
			"Execution of `upload-file-to-bitbucket-with-git.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf("Uploaded file %s to %s\n", step.UploadParams.File, config["BITBUCKET_URL"])
	}
}
