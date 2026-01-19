package steps

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
	"github.com/opendevstack/ods-core/tests/utils"
)

// ExecuteProvision handles the provision step type.
func ExecuteProvision(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, quickstarterRepo string, quickstarterName string, config map[string]string, projectName string) {
	logger.Running(fmt.Sprintf("Provision for %s-%s", projectName, repoName))

	// cleanup and create bb resources for this test
	err := recreateBitbucketRepo(config, projectName, repoName)
	if err != nil {
		logger.Failure("Provision - BitBucket repo recreation", err)
		t.Fatal(err)
	}
	logger.Success("BitBucket repo created/updated")

	projectNameDev := fmt.Sprintf("%s-dev", projectName)
	projectNameTest := fmt.Sprintf("%s-test", projectName)
	projectNameCD := fmt.Sprintf("%s-cd", projectName)

	err = deleteOpenShiftResources(projectName, step.ComponentID, projectNameCD)
	if err != nil {
		logger.Failure(fmt.Sprintf("Delete OpenShift resources in %s-cd", projectName), err)
		t.Fatal(err)
	}
	err = deleteOpenShiftResources(projectName, step.ComponentID, projectNameDev)
	if err != nil {
		logger.Failure(fmt.Sprintf("Delete OpenShift resources in %s-dev", projectName), err)
		t.Fatal(err)
	}
	err = deleteOpenShiftResources(projectName, step.ComponentID, projectNameTest)
	if err != nil {
		logger.Failure(fmt.Sprintf("Delete OpenShift resources in %s-test", projectName), err)
		t.Fatal(err)
	}
	logger.Success("OpenShift resources cleaned up")

	if len(step.ProvisionParams.TestResourcesCleanUp) > 0 {
		logger.Running("Cleaning up test resources")
		for _, it := range step.ProvisionParams.TestResourcesCleanUp {
			tmpNamespace := it.Namespace
			if tmpNamespace == "" {
				tmpNamespace = DefaultNamespace
			}
			namespace := fmt.Sprintf("%s-%s", projectName, tmpNamespace)
			if err := deleteOpenShiftResourceByName(it.ResourceType, it.ResourceName, namespace); err != nil {
				logger.Warn(fmt.Sprintf("Failed to cleanup resource %s/%s: %v", it.ResourceType, it.ResourceName, err))
			} else {
				logger.KeyValue(fmt.Sprintf("Cleaned %s", it.ResourceType), it.ResourceName)
			}
		}
	}

	branch := config["ODS_GIT_REF"]
	if len(step.ProvisionParams.Branch) > 0 {
		branch = renderTemplate(t, step.ProvisionParams.Branch, tmplData)
	}
	agentImageTag := config["ODS_IMAGE_TAG"]
	if len(step.ProvisionParams.AgentImageTag) > 0 {
		agentImageTag = renderTemplate(t, step.ProvisionParams.AgentImageTag, tmplData)
	}
	sharedLibraryRef := agentImageTag
	if len(step.ProvisionParams.SharedLibraryRef) > 0 {
		sharedLibraryRef = renderTemplate(t, step.ProvisionParams.SharedLibraryRef, tmplData)
	}
	env := []utils.EnvPair{
		{
			Name:  "ODS_NAMESPACE",
			Value: config["ODS_NAMESPACE"],
		},
		{
			Name:  "ODS_GIT_REF",
			Value: config["ODS_GIT_REF"],
		},
		{
			Name:  "ODS_IMAGE_TAG",
			Value: config["ODS_IMAGE_TAG"],
		},
		{
			Name:  "ODS_BITBUCKET_PROJECT",
			Value: config["ODS_BITBUCKET_PROJECT"],
		},
		{
			Name:  "AGENT_IMAGE_TAG",
			Value: agentImageTag,
		},
		{
			Name:  "SHARED_LIBRARY_REF",
			Value: sharedLibraryRef,
		},
		{
			Name:  "PROJECT_ID",
			Value: projectName,
		},
		{
			Name:  "COMPONENT_ID",
			Value: step.ComponentID,
		},
		{
			Name:  "GIT_URL_HTTP",
			Value: fmt.Sprintf("%s/%s/%s.git", config["REPO_BASE"], projectName, repoName),
		},
	}

	t.Cleanup(func() {
		// Check if resources should be kept
		if os.Getenv("KEEP_RESOURCES") == "true" {
			logger.Warn(fmt.Sprintf("KEEP_RESOURCES=true: Skipping resource cleanup for component %s", step.ComponentID))
			return
		}
		logger.Running(fmt.Sprintf("Cleaning up resources for component %s", step.ComponentID))
		if err := deleteOpenShiftResources(projectName, step.ComponentID, projectNameCD); err != nil {
			logger.Warn(fmt.Sprintf("Failed to cleanup CD resources: %v", err))
		}
		if err := deleteOpenShiftResources(projectName, step.ComponentID, projectNameDev); err != nil {
			logger.Warn(fmt.Sprintf("Failed to cleanup DEV resources: %v", err))
		}
		if err := deleteOpenShiftResources(projectName, step.ComponentID, projectNameTest); err != nil {
			logger.Warn(fmt.Sprintf("Failed to cleanup TEST resources: %v", err))
		}
		if err := deleteHelmRelease(step.ComponentID, projectNameCD); err != nil {
			logger.Warn(fmt.Sprintf("Failed to cleanup Helm release in CD namespace: %v", err))
		}
		if err := deleteHelmRelease(step.ComponentID, projectNameDev); err != nil {
			logger.Warn(fmt.Sprintf("Failed to cleanup Helm release in DEV namespace: %v", err))
		}
		if err := deleteHelmRelease(step.ComponentID, projectNameTest); err != nil {
			logger.Warn(fmt.Sprintf("Failed to cleanup Helm release in TEST namespace: %v", err))
		}
		logger.Success("Resource cleanup completed")
	})

	// Checks if it was overridden including a repository name in the same project like 'repo/quickstarter'.
	var repository string = quickstarterRepo
	var repositoryIndex int = strings.Index(step.ProvisionParams.Quickstarter, "/")
	if len(step.ProvisionParams.Quickstarter) > 0 && repositoryIndex != -1 {
		repository = step.ProvisionParams.Quickstarter[:repositoryIndex]
	}
	// If quickstarter is overridden, use that value. Otherwise
	// we use the quickstarter under test.
	var jenkinsfile string = fmt.Sprintf("%s/%s", quickstarterName, DefaultJenkinsfile)
	if len(step.ProvisionParams.Quickstarter) > 0 {
		jenkinsfile = fmt.Sprintf("%s/%s", step.ProvisionParams.Quickstarter, DefaultJenkinsfile)
	}
	if len(step.ProvisionParams.Quickstarter) > 0 && repositoryIndex != -1 {
		jenkinsfile = fmt.Sprintf("%s/%s", step.ProvisionParams.Quickstarter[repositoryIndex+1:], DefaultJenkinsfile)
	}

	pipelineName := step.ProvisionParams.Pipeline
	verify := step.ProvisionParams.Verify

	// Render environment variable values through template engine
	renderedEnv := make([]utils.EnvPair, len(step.ProvisionParams.Env))
	for i, envPair := range step.ProvisionParams.Env {
		renderedEnv[i] = utils.EnvPair{
			Name:  envPair.Name,
			Value: renderTemplate(t, envPair.Value, tmplData),
		}
	}

	request := utils.RequestBuild{
		Repository: repository,
		Branch:     branch,
		Project:    config["ODS_BITBUCKET_PROJECT"],
		Env:        append(env, renderedEnv...),
	}

	buildName, err := utils.RunJenkinsPipeline(jenkinsfile, request, pipelineName)
	if err != nil {
		t.Fatal(err)
	}
	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config, projectName)
}
