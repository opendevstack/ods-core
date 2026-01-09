package steps

import (
	"fmt"
	"strings"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

// ExecuteProvision handles the provision step type.
func ExecuteProvision(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, quickstarterRepo string, quickstarterName string, config map[string]string, projectName string) {
	fmt.Printf("== executeProvision %s-%s\n", projectName, repoName)

	// cleanup and create bb resources for this test
	err := recreateBitbucketRepo(config, projectName, repoName)
	if err != nil {
		t.Fatal(err)
	}
	projectNameDev := fmt.Sprintf("%s-dev", projectName)
	projectNameTest := fmt.Sprintf("%s-test", projectName)
	projectNameCD := fmt.Sprintf("%s-cd", projectName)

	err = deleteOpenShiftResources(projectName, step.ComponentID, projectNameDev)
	if err != nil {
		t.Fatal(err)
	}
	err = deleteOpenShiftResources(projectName, step.ComponentID, projectNameTest)
	if err != nil {
		t.Fatal(err)
	}

	if len(step.ProvisionParams.TestResourcesCleanUp) > 0 {
		for _, it := range step.ProvisionParams.TestResourcesCleanUp {
			tmpNamespace := it.Namespace
			if tmpNamespace == "" {
				tmpNamespace = DefaultNamespace
			}
			namespace := fmt.Sprintf("%s-%s", projectName, tmpNamespace)
			if err := deleteOpenShiftResourceByName(it.ResourceType, it.ResourceName, namespace); err != nil {
				t.Logf("Warning: failed to cleanup resource %s/%s: %v", it.ResourceType, it.ResourceName, err)
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
		if err := deleteOpenShiftResources(projectName, step.ComponentID, projectNameCD); err != nil {
			t.Logf("Warning: failed to cleanup CD resources: %v", err)
		}
		if err := deleteOpenShiftResources(projectName, step.ComponentID, projectNameDev); err != nil {
			t.Logf("Warning: failed to cleanup DEV resources: %v", err)
		}
		if err := deleteOpenShiftResources(projectName, step.ComponentID, projectNameTest); err != nil {
			t.Logf("Warning: failed to cleanup TEST resources: %v", err)
		}
		if err := deleteHelmRelease(step.ComponentID, projectNameCD); err != nil {
			t.Logf("Warning: failed to cleanup Helm release in CD namespace: %v", err)
		}
		if err := deleteHelmRelease(step.ComponentID, projectNameDev); err != nil {
			t.Logf("Warning: failed to cleanup Helm release in DEV namespace: %v", err)
		}
		if err := deleteHelmRelease(step.ComponentID, projectNameTest); err != nil {
			t.Logf("Warning: failed to cleanup Helm release in TEST namespace: %v", err)
		}
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

	request := utils.RequestBuild{
		Repository: repository,
		Branch:     branch,
		Project:    config["ODS_BITBUCKET_PROJECT"],
		Env:        append(env, step.ProvisionParams.Env...),
	}

	buildName, err := utils.RunJenkinsPipeline(jenkinsfile, request, pipelineName)
	if err != nil {
		t.Fatal(err)
	}
	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config, projectName)
}
