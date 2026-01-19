package steps

import (
	"fmt"
	"testing"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
	"github.com/opendevstack/ods-core/tests/utils"
)

// ExecuteBuild handles the build step type.
func ExecuteBuild(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string, projectName string) {
	logger.Running(fmt.Sprintf("Build for repository %s", repoName))

	branch := DefaultBranch
	if len(step.BuildParams.Branch) > 0 {
		branch = renderTemplate(t, step.BuildParams.Branch, tmplData)
	}
	logger.KeyValue("Branch", branch)

	var repository string = repoName
	if len(step.BuildParams.Repository) > 0 {
		repository = renderTemplate(t, step.BuildParams.Repository, tmplData)
	}
	logger.KeyValue("Repository", repository)

	// Render environment variable values through template engine
	renderedEnv := make([]utils.EnvPair, len(step.BuildParams.Env))
	for i, envPair := range step.BuildParams.Env {
		renderedEnv[i] = utils.EnvPair{
			Name:  envPair.Name,
			Value: renderTemplate(t, envPair.Value, tmplData),
		}
	}

	request := utils.RequestBuild{
		Repository: repository,
		Branch:     branch,
		Project:    projectName,
		Env:        renderedEnv,
	}
	pipelineName := renderTemplate(t, step.BuildParams.Pipeline, tmplData)
	logger.KeyValue("Pipeline", pipelineName)

	verify := step.BuildParams.Verify

	logger.Waiting("Jenkins pipeline execution")
	buildName, err := utils.RunJenkinsPipeline(DefaultJenkinsfile, request, pipelineName)
	if err != nil {
		logger.Failure("Jenkins pipeline execution", err)
		t.Fatal(err)
	}
	logger.Success(fmt.Sprintf("Build triggered with name %s", buildName))

	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config, projectName)
}
