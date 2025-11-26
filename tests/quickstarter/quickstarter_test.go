package quickstarter

import (
	"bytes"
	b64 "encoding/base64"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"text/template"

	"github.com/opendevstack/ods-core/tests/utils"
)

// Step type constants
const (
	StepTypeUpload    = "upload"
	StepTypeRun       = "run"
	StepTypeProvision = "provision"
	StepTypeBuild     = "build"
)

// Default values
const (
	DefaultBranch      = "master"
	DefaultJenkinsfile = "Jenkinsfile"
	DefaultNamespace   = "dev"
)

// Context for verifications
type VerificationContext struct {
	TestdataPath string
	RepoName     string
	BuildName    string
	Config       map[string]string
	TmplData     TemplateData
}

// TestQuickstarter tests given quickstarters. It expects a "steps.yml" file in
// a "testdata" directory within each quickstarter to test.
// The quickstarter(s) to run the tests for can be given as the last command
// line argument.
// If the argument starts with "." or "/", it is assumed to be a path to a
// folder - otherwise a folder next to "ods-core" is assumed, by default
// "ods-quickstarters". If the argument ends with "...", all directories with a
// "testdata" directory are tested, otherwise only the given folder is run.
func TestQuickstarter(t *testing.T) {

	var quickstarterPaths []string
	odsCoreRootPath := "../.."
	project := os.Args[len(os.Args)-1]
	utils.Set_project_name(project)
	target := os.Args[len(os.Args)-2]
	if strings.HasPrefix(target, ".") || strings.HasPrefix(target, "/") {
		if strings.HasSuffix(target, "...") {
			quickstarterPaths = collectTestableQuickstarters(
				t, strings.TrimSuffix(target, "/..."),
			)
		} else {
			quickstarterPaths = append(quickstarterPaths, target)
		}
	} else {
		// No slash = quickstarter in ods-quickstarters
		// Ending with ... = all quickstarters in given folder
		// otherwise = exactly one quickstarter
		if !strings.Contains(target, "/") {
			quickstarterPaths = []string{fmt.Sprintf("%s/../%s/%s", odsCoreRootPath, "ods-quickstarters", target)}
		} else if strings.HasSuffix(target, "...") {
			quickstarterPaths = collectTestableQuickstarters(
				t, fmt.Sprintf("%s/../%s", odsCoreRootPath, strings.TrimSuffix(target, "/...")),
			)
		} else {
			quickstarterPaths = []string{fmt.Sprintf("%s/../%s", odsCoreRootPath, target)}
		}
	}
	dir, err := os.Getwd()
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	quickstarterPaths = utils.RemoveExcludedQuickstarters(t, dir, quickstarterPaths)

	config, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatal(err)
	}

	fmt.Printf("\n\nRunning test steps found in the following directories:\n")
	for _, quickstarterPath := range quickstarterPaths {
		fmt.Printf("- %s\n", quickstarterPath)
	}
	fmt.Printf("\n\n")

	for _, quickstarterPath := range quickstarterPaths {
		testdataPath := fmt.Sprintf("%s/testdata", quickstarterPath)
		quickstarterRepo := filepath.Base(filepath.Dir(quickstarterPath))
		quickstarterName := filepath.Base(quickstarterPath)

		fmt.Printf("\n\n\n\n")
		fmt.Printf("Running tests for quickstarter %s\n", quickstarterName)
		fmt.Printf("\n\n")

		// Run each quickstarter test in a subtest to avoid exiting early
		// when t.Fatal is used.
		t.Run(quickstarterName, func(t *testing.T) {
			t.Parallel()
			s, err := readSteps(testdataPath)
			if err != nil {
				t.Fatal(err)
			}

			for i, step := range s.Steps {
				// Step might overwrite component ID
				if len(step.ComponentID) == 0 {
					step.ComponentID = s.ComponentID
				}
				fmt.Printf(
					"\n\nRun step #%d (%s) of quickstarter %s/%s ... %s\n",
					(i + 1),
					step.Type,
					quickstarterRepo,
					quickstarterName,
					step.Description,
				)

				repoName := fmt.Sprintf("%s-%s", strings.ToLower(utils.PROJECT_NAME), step.ComponentID)
				tmplData := templateData(config, step.ComponentID, "")

				if step.Type == StepTypeUpload {
					executeStepUpload(t, step, testdataPath, tmplData, repoName, config)
					continue
				}

				if step.Type == StepTypeRun {
					executeStepRun(t, step, testdataPath)
					continue
				}

				if step.Type == StepTypeProvision {
					executeProvision(t, step, testdataPath, tmplData, repoName, quickstarterRepo, quickstarterName, config)
					continue
				}

				if step.Type == StepTypeBuild {
					executeBuild(t, step, testdataPath, tmplData, repoName, config)
					continue
				}

				t.Fatal("Unknown step")

			}

			fmt.Printf("\n\n\n\n")
			fmt.Printf("========== End test for Quickstarter %s\n", quickstarterName)
			fmt.Printf("\n\n")
		})

	}

}

func executeProvision(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, quickstarterRepo string, quickstarterName string, config map[string]string) {
	fmt.Printf("== executeProvision %s-%s\n", utils.PROJECT_NAME, repoName)

	// cleanup and create bb resources for this test
	err := recreateBitbucketRepo(config, utils.PROJECT_NAME, repoName)
	if err != nil {
		t.Fatal(err)
	}
	err = deleteOpenShiftResources(utils.PROJECT_NAME, step.ComponentID, utils.PROJECT_NAME_DEV)
	if err != nil {
		t.Fatal(err)
	}
	err = deleteOpenShiftResources(utils.PROJECT_NAME, step.ComponentID, utils.PROJECT_NAME_TEST)
	if err != nil {
		t.Fatal(err)
	}

	if len(step.ProvisionParams.TestResourcesCleanUp) > 0 {
		for _, it := range step.ProvisionParams.TestResourcesCleanUp {
			tmpNamespace := it.Namespace
			if tmpNamespace == "" {
				tmpNamespace = DefaultNamespace
			}
			namespace := fmt.Sprintf("%s-%s", utils.PROJECT_NAME, tmpNamespace)
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
			Value: utils.PROJECT_NAME,
		},
		{
			Name:  "COMPONENT_ID",
			Value: step.ComponentID,
		},
		{
			Name:  "GIT_URL_HTTP",
			Value: fmt.Sprintf("%s/%s/%s.git", config["REPO_BASE"], utils.PROJECT_NAME, repoName),
		},
	}

	t.Cleanup(func() {
		if err := deleteOpenShiftResources(utils.PROJECT_NAME, step.ComponentID, utils.PROJECT_NAME_DEV); err != nil {
			t.Logf("Warning: failed to cleanup DEV resources: %v", err)
		}
		if err := deleteOpenShiftResources(utils.PROJECT_NAME, step.ComponentID, utils.PROJECT_NAME_TEST); err != nil {
			t.Logf("Warning: failed to cleanup TEST resources: %v", err)
		}
		if err := deleteHelmRelease(step.ComponentID, utils.PROJECT_NAME_DEV); err != nil {
			t.Logf("Warning: failed to cleanup Helm release in DEV namespace: %v", err)
		}
		if err := deleteHelmRelease(step.ComponentID, utils.PROJECT_NAME_TEST); err != nil {
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
	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config)
}

func executeBuild(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string) {
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
		Project:    utils.PROJECT_NAME,
		Env:        step.BuildParams.Env,
	}
	jenkinsfile := DefaultJenkinsfile
	pipelineName := step.BuildParams.Pipeline
	verify := step.BuildParams.Verify

	buildName, err := utils.RunJenkinsPipeline(jenkinsfile, request, pipelineName)
	if err != nil {
		t.Fatal(err)
	}
	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config)
}

func executeStepUpload(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string) {
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
		fmt.Sprintf("--project=%s", utils.PROJECT_NAME),
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

func executeStepRun(t *testing.T, step TestStep, testdataPath string) {
	if step.RunParams == nil || step.RunParams.File == "" {
		t.Fatalf("Missing run parameters, not defined script file.")
	}

	fmt.Printf("Executing script: %s\n", step.RunParams.File)
	step.RunParams.File = fmt.Sprintf("%s/%s", testdataPath, step.RunParams.File)

	stdout, stderr, err := utils.RunCommand(step.RunParams.File, []string{}, []string{})
	fmt.Printf("%s", stdout)
	if err != nil {
		t.Fatalf(
			"Execution of script:%s failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			step.RunParams.File,
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf("Executed script: %s\n", step.RunParams.File)
	}
}

// collectTestableQuickstarters collects all subdirs of "dir" that contain
// a "testdata" directory.
func collectTestableQuickstarters(t *testing.T, dir string) []string {
	testableQuickstarters := []string{}
	files, err := os.ReadDir(dir)
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range files {
		if f.IsDir() {
			candidateDir := fmt.Sprintf("%s/%s", dir, f.Name())
			candidateTestdataDir := fmt.Sprintf("%s/testdata", candidateDir)
			if _, err := os.Stat(candidateTestdataDir); !os.IsNotExist(err) {
				testableQuickstarters = append(testableQuickstarters, candidateDir)
			}
		}
	}

	return utils.SortTestableQuickstarters(t, dir, testableQuickstarters)
}

func templateData(config map[string]string, componentID string, buildName string) TemplateData {
	sanitizedOdsGitRef := strings.ReplaceAll(config["ODS_GIT_REF"], "/", "_")
	sanitizedOdsGitRef = strings.ReplaceAll(sanitizedOdsGitRef, "-", "_")
	var buildNumber string
	if len(buildName) > 0 {
		buildParts := strings.Split(buildName, "-")
		buildNumber = buildParts[len(buildParts)-1]
	}
	aquaEnabled, _ := strconv.ParseBool(config["AQUA_ENABLED"])

	// Initialize template data map with standard fields
	data := TemplateData{
		"ProjectID":           utils.PROJECT_NAME,
		"ComponentID":         componentID,
		"OdsNamespace":        config["ODS_NAMESPACE"],
		"OdsGitRef":           config["ODS_GIT_REF"],
		"OdsImageTag":         config["ODS_IMAGE_TAG"],
		"OdsBitbucketProject": config["ODS_BITBUCKET_PROJECT"],
		"SanitizedOdsGitRef":  sanitizedOdsGitRef,
		"BuildNumber":         buildNumber,
		"SonarQualityProfile": utils.GetEnv("SONAR_QUALITY_PROFILE", "Sonar way"),
		"AquaEnabled":         aquaEnabled,
	}

	// Automatically load all environment variables with TMPL_ prefix
	// Example: TMPL_MyVariable becomes accessible as {{.MyVariable}}
	// We check known TMPL_ variables and also scan all environment variables
	tmplVars := []string{
		"TMPL_SonarQualityGate",
		"TMPL_SonarQualityProfile",
	}

	tmplCount := 0
	// First, add any explicitly known TMPL_ variables
	for _, tmplVar := range tmplVars {
		if value, ok := os.LookupEnv(tmplVar); ok {
			key := strings.TrimPrefix(tmplVar, "TMPL_")
			data[key] = value
			fmt.Printf("Loading environment variable: %s -> %s = '%s'\n", tmplVar, key, value)
			tmplCount++
		}
	}

	// Also scan all environment variables for any other TMPL_ prefixed ones
	for _, env := range os.Environ() {
		if strings.HasPrefix(env, "TMPL_") {
			pair := strings.SplitN(env, "=", 2)
			if len(pair) == 2 {
				key := strings.TrimPrefix(pair[0], "TMPL_")
				// Only add if not already added above
				if _, exists := data[key]; !exists {
					data[key] = pair[1]
					fmt.Printf("Loading environment variable: %s -> %s = '%s'\n", pair[0], key, pair[1])
					tmplCount++
				}
			}
		}
	}

	if tmplCount == 0 {
		fmt.Printf("WARNING: No TMPL_ environment variables found!\n")
	} else {
		fmt.Printf("Loaded %d TMPL_ environment variables\n", tmplCount)
	}

	return data
}

// verifyPipelineRun checks that all expected values from the TestStepVerify
// definition are present.
func verifyPipelineRun(t *testing.T, step TestStep, verify *TestStepVerify, testdataPath string, repoName string, buildName string, config map[string]string) {
	if verify == nil {
		fmt.Println("Nothing to verify for", buildName)
		return
	}
	ctx := VerificationContext{
		TestdataPath: testdataPath,
		RepoName:     repoName,
		BuildName:    buildName,
		Config:       config,
		TmplData:     templateData(config, step.ComponentID, buildName),
	}
	if len(verify.JenkinsStages) > 0 {
		verifyJenkinsStages(t, step, verify, ctx)
	}
	if len(verify.SonarScan) > 0 {
		verifySonarScan(t, step, verify, ctx)
	}
	if len(verify.RunAttachments) > 0 {
		verifyRunAttachments(t, verify, ctx)
	}
	if verify.TestResults > 0 {
		verifyTestResults(t, verify, ctx)
	}
	if verify.OpenShiftResources != nil {
		verifyOpenShiftResources(t, step, verify, ctx)
	}
}

// Verifies Jenkins stages
func verifyJenkinsStages(t *testing.T, step TestStep, verify *TestStepVerify, ctx VerificationContext) {
	fmt.Printf("Verifying Jenkins stages of %s ...\n", ctx.BuildName)
	stages, err := utils.RetrieveJenkinsBuildStagesForBuild(utils.PROJECT_NAME_CD, ctx.BuildName)
	if err != nil {
		t.Fatal(err)
	}
	fmt.Printf("%s pipeline run for %s returned:\n%s", step.Type, step.ComponentID, stages)
	err = verifyJSONGoldenFile(
		step.ComponentID,
		fmt.Sprintf("%s/%s", ctx.TestdataPath, verify.JenkinsStages),
		stages,
		ctx.TmplData,
	)
	if err != nil {
		t.Fatal(err)
	}
}

// Verifies the Sonar scan
func verifySonarScan(t *testing.T, step TestStep, verify *TestStepVerify, ctx VerificationContext) {
	fmt.Printf("Verifying Sonar scan of %s ...\n", ctx.BuildName)
	sonarscan, err := retrieveSonarScan(ctx.RepoName, ctx.Config)
	if err != nil {
		t.Fatal(err)
	}
	err = verifyJSONGoldenFile(
		step.ComponentID,
		fmt.Sprintf("%s/%s", ctx.TestdataPath, verify.SonarScan),
		sonarscan,
		ctx.TmplData,
	)
	if err != nil {
		t.Fatal(err)
	}
}

// Verifies run attachments
func verifyRunAttachments(t *testing.T, verify *TestStepVerify, ctx VerificationContext) {
	fmt.Printf("Verifying Jenkins run attachments of %s ...\n", ctx.BuildName)
	artifactsToVerify := []string{}
	for _, a := range verify.RunAttachments {
		artifactsToVerify = append(
			artifactsToVerify,
			renderTemplate(t, a, ctx.TmplData),
		)
	}
	err := utils.VerifyJenkinsRunAttachments(utils.PROJECT_NAME_CD, ctx.BuildName, artifactsToVerify)
	if err != nil {
		t.Fatal(err)
	}
}

// Verifies test results
func verifyTestResults(t *testing.T, verify *TestStepVerify, ctx VerificationContext) {
	fmt.Printf("Verifying unit tests of %s ...\n", ctx.BuildName)
	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/print-jenkins-unittest-results.sh", []string{
		utils.PROJECT_NAME_CD,
		ctx.BuildName,
	}, []string{})
	if err != nil {
		t.Fatalf("Could not find unit tests for build:%s\nstdout: %s\nstderr:%s\nerr: %s\n",
			ctx.BuildName, stdout, stderr, err)
	}
	r := regexp.MustCompile("([0-9]+) tests")
	match := r.FindStringSubmatch(stdout)
	if match == nil {
		t.Fatalf("Could not find any unit tests for build:%s\nstdout: %s\nstderr:%s\nerr: %s\n",
			ctx.BuildName, stdout, stderr, err)
	}
	foundTests, err := strconv.Atoi(match[1])
	if err != nil {
		t.Fatalf("Could not convert number of unit tests to int: %s", err)
	}
	if foundTests < verify.TestResults {
		t.Fatalf("Expected %d unit tests, but found only %d for build:%s\n",
			verify.TestResults, foundTests, ctx.BuildName)
	}
}

// Verifies OpenShift resources
func verifyOpenShiftResources(t *testing.T, step TestStep, verify *TestStepVerify, ctx VerificationContext) {
	var ocNamespace string
	if len(verify.OpenShiftResources.Namespace) > 0 {
		ocNamespace = renderTemplate(t, verify.OpenShiftResources.Namespace, ctx.TmplData)
	} else {
		ocNamespace = utils.PROJECT_NAME_DEV
	}
	fmt.Printf("Verifying OpenShift resources of %s in %s ...\n", step.ComponentID, ocNamespace)
	imageTags := []utils.ImageTag{}
	for _, it := range verify.OpenShiftResources.ImageTags {
		imageTags = append(
			imageTags,
			utils.ImageTag{
				Name: renderTemplate(t, it.Name, ctx.TmplData),
				Tag:  renderTemplate(t, it.Tag, ctx.TmplData),
			},
		)
	}
	resources := utils.Resources{
		Namespace:              ocNamespace,
		ImageTags:              imageTags,
		BuildConfigs:           renderTemplates(t, verify.OpenShiftResources.BuildConfigs, ctx.TmplData),
		DeploymentConfigs:      renderTemplates(t, verify.OpenShiftResources.DeploymentConfigs, ctx.TmplData),
		Services:               renderTemplates(t, verify.OpenShiftResources.Services, ctx.TmplData),
		ImageStreams:           renderTemplates(t, verify.OpenShiftResources.ImageStreams, ctx.TmplData),
		Routes:                 renderTemplates(t, verify.OpenShiftResources.Routes, ctx.TmplData),
		ConfigMaps:             renderTemplates(t, verify.OpenShiftResources.ConfigMaps, ctx.TmplData),
		Secrets:                renderTemplates(t, verify.OpenShiftResources.Secrets, ctx.TmplData),
		PersistentVolumeClaims: renderTemplates(t, verify.OpenShiftResources.PersistentVolumeClaims, ctx.TmplData),
		ServiceAccounts:        renderTemplates(t, verify.OpenShiftResources.ServiceAccounts, ctx.TmplData),
		RoleBindings:           renderTemplates(t, verify.OpenShiftResources.RoleBindings, ctx.TmplData),
	}
	utils.CheckResources(resources, t)
}

func renderTemplates(t *testing.T, tpls []string, tmplData TemplateData) []string {
	rendered := []string{}
	for _, tpl := range tpls {
		rendered = append(rendered, renderTemplate(t, tpl, tmplData))
	}
	return rendered
}

func renderTemplate(t *testing.T, tpl string, tmplData TemplateData) string {
	var attachmentBuffer bytes.Buffer
	tmpl, err := template.New("attachment").Parse(tpl)
	if err != nil {
		t.Fatalf("Error parsing template: %s", err)
	}
	tmplErr := tmpl.Execute(&attachmentBuffer, tmplData)
	if tmplErr != nil {
		t.Fatalf("Error rendering template: %s", tmplErr)
	}
	return attachmentBuffer.String()
}
