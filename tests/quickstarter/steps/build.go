package steps

import (
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

// ExecuteBuild handles the build step type.
func ExecuteBuild(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string, projectName string) {
	branch := DefaultBranch
	if len(step.BuildParams.Branch) > 0 {
		branch = renderTemplate(t, step.BuildParams.Branch, tmplData)
	}
	var repository string = repoName
	if len(step.BuildParams.Repository) > 0 {
		repository = renderTemplate(t, step.BuildParams.Repository, tmplData)
	}
	request := utils.RequestBuild{
		Repository: repository,
		Branch:     branch,
		Project:    projectName,
		Env:        step.BuildParams.Env,
	}
	jenkinsfile := DefaultJenkinsfile
	pipelineName := renderTemplate(t, step.BuildParams.Pipeline, tmplData)
	verify := step.BuildParams.Verify

	buildName, err := utils.RunJenkinsPipeline(jenkinsfile, request, pipelineName)
	if err != nil {
		t.Fatal(err)
	}
	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config, projectName)
}
