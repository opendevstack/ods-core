package steps

import (
	b64 "encoding/base64"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"testing"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
	"github.com/opendevstack/ods-core/tests/utils"
)

// VerificationContext holds context for verifications
type VerificationContext struct {
	TestdataPath string
	RepoName     string
	BuildName    string
	Config       map[string]string
	TmplData     TemplateData
	ProjectName  string
}

// verifyPipelineRun checks that all expected values from the TestStepVerify
// definition are present.
func verifyPipelineRun(t *testing.T, step TestStep, verify *TestStepVerify, testdataPath string, repoName string, buildName string, config map[string]string, projectName string) {
	if verify == nil {
		logger.Info("No verification defined for build: %s", buildName)
		return
	}

	logger.StepVerification(fmt.Sprintf("pipeline run: %s", buildName))

	projectNameCD := fmt.Sprintf("%s-cd", projectName)

	ctx := VerificationContext{
		TestdataPath: testdataPath,
		RepoName:     repoName,
		BuildName:    buildName,
		Config:       config,
		TmplData:     CreateTemplateData(config, step.ComponentID, buildName, projectName),
		ProjectName:  projectName,
	}

	strategy := strings.ToLower(strings.TrimSpace(verify.Strategy))
	if strategy == "" {
		strategy = VerifyStrategyAggregate
	}
	if strategy != VerifyStrategyAggregate && strategy != VerifyStrategyFailFast {
		logger.Warn("Unknown verify strategy %q, defaulting to aggregate", strategy)
		strategy = VerifyStrategyAggregate
	}

	logger.KeyValue("Verification Strategy", strategy)

	var errs []string
	runCheck := func(name string, fn func() error) {
		if fn == nil {
			return
		}
		if strategy == VerifyStrategyFailFast {
			if err := fn(); err != nil {
				logger.Failure(fmt.Sprintf("Verification: %s", name), err)
				t.Fatalf("Verification %s failed: %v", name, err)
			}
			return
		}
		if err := fn(); err != nil {
			errs = append(errs, fmt.Sprintf("%s: %v", name, err))
		}
	}

	runCheck("jenkins stages", func() error {
		if len(verify.JenkinsStages) == 0 {
			return nil
		}
		return verifyJenkinsStages(t, step, verify, ctx, projectNameCD)
	})
	runCheck("sonar scan", func() error {
		if len(verify.SonarScan) == 0 {
			return nil
		}
		return verifySonarScan(t, step, verify, ctx)
	})
	runCheck("run attachments", func() error {
		if len(verify.RunAttachments) == 0 {
			return nil
		}
		return verifyRunAttachments(t, verify, ctx, projectNameCD)
	})
	runCheck("test results", func() error {
		if verify.TestResults == 0 {
			return nil
		}
		return verifyTestResults(t, verify, ctx, projectNameCD)
	})
	runCheck("openshift resources", func() error {
		if verify.OpenShiftResources == nil {
			return nil
		}
		return verifyOpenShiftResources(t, step, verify, ctx, projectName)
	})

	if strategy == VerifyStrategyAggregate && len(errs) > 0 {
		msg := fmt.Sprintf("Verification failed with %d issue(s):\n- %s", len(errs), strings.Join(errs, "\n- "))
		t.Fatal(msg)
	}
}

// verifyJenkinsStages verifies Jenkins stages
func verifyJenkinsStages(t *testing.T, step TestStep, verify *TestStepVerify, ctx VerificationContext, projectNameCD string) error {
	logger.Waiting(fmt.Sprintf("Jenkins stages of %s", ctx.BuildName))
	stages, err := utils.RetrieveJenkinsBuildStagesForBuild(projectNameCD, ctx.BuildName)
	if err != nil {
		logger.Failure(fmt.Sprintf("Retrieve Jenkins stages for %s", ctx.BuildName), err)
		return err
	}
	return verifyJSONGoldenFile(
		step.ComponentID,
		fmt.Sprintf("%s/%s", ctx.TestdataPath, verify.JenkinsStages),
		stages,
		ctx.TmplData,
	)
}

// verifySonarScan verifies the Sonar scan
func verifySonarScan(t *testing.T, step TestStep, verify *TestStepVerify, ctx VerificationContext) error {
	logger.Waiting(fmt.Sprintf("Sonar scan of %s", ctx.BuildName))
	sonarscan, err := retrieveSonarScan(ctx.RepoName, ctx.Config)
	if err != nil {
		return err
	}
	return verifyJSONGoldenFile(
		step.ComponentID,
		fmt.Sprintf("%s/%s", ctx.TestdataPath, verify.SonarScan),
		sonarscan,
		ctx.TmplData,
	)
}

// verifyRunAttachments verifies run attachments
func verifyRunAttachments(t *testing.T, verify *TestStepVerify, ctx VerificationContext, projectNameCD string) error {
	logger.Waiting(fmt.Sprintf("Jenkins run attachments of %s", ctx.BuildName))
	artifactsToVerify := []string{}
	for _, a := range verify.RunAttachments {
		artifact := renderTemplate(t, a, ctx.TmplData)
		artifactsToVerify = append(artifactsToVerify, artifact)
	}
	return utils.VerifyJenkinsRunAttachments(projectNameCD, ctx.BuildName, artifactsToVerify)
}

// verifyTestResults verifies test results
func verifyTestResults(t *testing.T, verify *TestStepVerify, ctx VerificationContext, projectNameCD string) error {
	logger.Waiting(fmt.Sprintf("Unit tests of %s", ctx.BuildName))
	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/print-jenkins-unittest-results.sh", []string{
		projectNameCD,
		ctx.BuildName,
	}, []string{})
	if err != nil {
		return fmt.Errorf("could not find unit tests for build:%s\nstdout: %s\nstderr:%s\nerr: %s", ctx.BuildName, stdout, stderr, err)
	}
	r := regexp.MustCompile("([0-9]+) tests")
	match := r.FindStringSubmatch(stdout)
	if match == nil {
		return fmt.Errorf("could not find any unit tests for build:%s\nstdout: %s\nstderr:%s\nerr: %s", ctx.BuildName, stdout, stderr, err)
	}
	foundTests, err := strconv.Atoi(match[1])
	if err != nil {
		return fmt.Errorf("could not convert number of unit tests to int: %w", err)
	}
	if foundTests < verify.TestResults {
		return fmt.Errorf("expected %d unit tests, but found only %d for build:%s", verify.TestResults, foundTests, ctx.BuildName)
	}
	return nil
}

// verifyOpenShiftResources verifies OpenShift resources
func verifyOpenShiftResources(t *testing.T, step TestStep, verify *TestStepVerify, ctx VerificationContext, projectName string) error {
	projectNameDev := fmt.Sprintf("%s-dev", projectName)
	ocNamespace := projectNameDev

	// Use custom namespace if specified, otherwise default to dev
	if verify.OpenShiftResources.Namespace != "" {
		customNamespace := renderTemplate(t, verify.OpenShiftResources.Namespace, ctx.TmplData)
		// If it doesn't contain the project prefix, add it
		if !strings.HasPrefix(customNamespace, projectName) {
			ocNamespace = fmt.Sprintf("%s-%s", projectName, customNamespace)
		} else {
			ocNamespace = customNamespace
		}
	}

	logger.Waiting(fmt.Sprintf("OpenShift resources of %s in %s", step.ComponentID, ocNamespace))

	imageTags := []utils.ImageTag{}

	resources := utils.Resources{
		Namespace:                ocNamespace,
		ImageTags:                imageTags,
		BuildConfigs:             renderTemplates(t, verify.OpenShiftResources.BuildConfigs, ctx.TmplData),
		DeploymentConfigs:        renderTemplates(t, verify.OpenShiftResources.DeploymentConfigs, ctx.TmplData),
		Deployments:              renderTemplates(t, verify.OpenShiftResources.Deployments, ctx.TmplData),
		StatefulSets:             renderTemplates(t, verify.OpenShiftResources.StatefulSets, ctx.TmplData),
		DaemonSets:               renderTemplates(t, verify.OpenShiftResources.DaemonSets, ctx.TmplData),
		ReplicaSets:              renderTemplates(t, verify.OpenShiftResources.ReplicaSets, ctx.TmplData),
		Services:                 renderTemplates(t, verify.OpenShiftResources.Services, ctx.TmplData),
		ImageStreams:             renderTemplates(t, verify.OpenShiftResources.ImageStreams, ctx.TmplData),
		Routes:                   renderTemplates(t, verify.OpenShiftResources.Routes, ctx.TmplData),
		Ingresses:                renderTemplates(t, verify.OpenShiftResources.Ingresses, ctx.TmplData),
		ConfigMaps:               renderTemplates(t, verify.OpenShiftResources.ConfigMaps, ctx.TmplData),
		Secrets:                  renderTemplates(t, verify.OpenShiftResources.Secrets, ctx.TmplData),
		PersistentVolumeClaims:   renderTemplates(t, verify.OpenShiftResources.PersistentVolumeClaims, ctx.TmplData),
		ServiceAccounts:          renderTemplates(t, verify.OpenShiftResources.ServiceAccounts, ctx.TmplData),
		Roles:                    renderTemplates(t, verify.OpenShiftResources.Roles, ctx.TmplData),
		RoleBindings:             renderTemplates(t, verify.OpenShiftResources.RoleBindings, ctx.TmplData),
		NetworkPolicies:          renderTemplates(t, verify.OpenShiftResources.NetworkPolicies, ctx.TmplData),
		Jobs:                     renderTemplates(t, verify.OpenShiftResources.Jobs, ctx.TmplData),
		CronJobs:                 renderTemplates(t, verify.OpenShiftResources.CronJobs, ctx.TmplData),
		Pods:                     renderTemplates(t, verify.OpenShiftResources.Pods, ctx.TmplData),
		HorizontalPodAutoscalers: renderTemplates(t, verify.OpenShiftResources.HorizontalPodAutoscalers, ctx.TmplData),
	}

	utils.CheckResources(resources, t)
	return nil
}

// retrieveSonarScan retrieves a Sonar scan result
func retrieveSonarScan(projectKey string, config map[string]string) (string, error) {
	logger.Running(fmt.Sprintf("Retrieving Sonar scan for: %s", projectKey))

	sonartoken, err := b64.StdEncoding.DecodeString(config["SONAR_AUTH_TOKEN_B64"])
	if err != nil {
		return "", fmt.Errorf("failed to decode Sonar auth token: %w", err)
	}

	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/print-sonar-scan-run.sh", []string{
		string(sonartoken),
		config["SONARQUBE_URL"],
		projectKey,
	}, []string{})

	if err != nil {
		logger.Error("Execution of print-sonar-scan-run.sh failed: stdout=%s, stderr=%s", stdout, stderr)
		return "", err
	}
	logger.Success("Sonar scan result retrieved")

	return stdout, nil
}
