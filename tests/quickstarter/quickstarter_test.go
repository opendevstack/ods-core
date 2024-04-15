package quickstarter

import (
	"bytes"
	b64 "encoding/base64"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"text/template"

	"github.com/opendevstack/ods-core/tests/utils"
)

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

				if step.Type == "upload" {
					executeStepUpload(t, step, testdataPath, tmplData, repoName, config)
					continue
				}

				if step.Type == "run" {
					executeStepRun(t, step, testdataPath)
					continue
				}

				if step.Type == "provision" {
					executeProvision(t, step, testdataPath, tmplData, repoName, quickstarterRepo, quickstarterName, config)
					continue
				}

				if step.Type == "build" {
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
	// cleanup and create bb resources for this test
	err := recreateBitbucketRepo(config, utils.PROJECT_NAME, repoName)
	if err != nil {
		t.Fatal(err)
	}
	err = deleteOpenShiftResources(utils.PROJECT_NAME, step.ComponentID, utils.PROJECT_NAME_DEV)
	if err != nil {
		t.Fatal(err)
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
		err = deleteOpenShiftResources(utils.PROJECT_NAME, step.ComponentID, utils.PROJECT_NAME_DEV)
	})

	// Checks if it was overrided including a repository name in the same project like 'repo/quickstarter'.
	var repository string = quickstarterRepo
	var repositoryIndex int = strings.Index(step.ProvisionParams.Quickstarter, "/")
	if len(step.ProvisionParams.Quickstarter) > 0 && repositoryIndex != -1 {
		repository = step.ProvisionParams.Quickstarter[:repositoryIndex]
	}
	// If quickstarter is overwritten, use that value. Otherwise
	// we use the quickstarter under test.
	var jenkinsfile string = fmt.Sprintf("%s/Jenkinsfile", quickstarterName)
	if len(step.ProvisionParams.Quickstarter) > 0 {
		jenkinsfile = fmt.Sprintf("%s/Jenkinsfile", step.ProvisionParams.Quickstarter)
	}
	if len(step.ProvisionParams.Quickstarter) > 0 && repositoryIndex != -1 {
		jenkinsfile = fmt.Sprintf("%s/Jenkinsfile", step.ProvisionParams.Quickstarter[repositoryIndex+1:])
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
	branch := "master"
	if len(step.BuildParams.Branch) > 0 {
		branch = renderTemplate(t, step.BuildParams.Branch, tmplData)
	}
	request := utils.RequestBuild{
		Repository: repoName,
		Branch:     branch,
		Project:    utils.PROJECT_NAME,
		Env:        step.BuildParams.Env,
	}
	jenkinsfile := "Jenkinsfile"
	pipelineName := step.BuildParams.Pipeline
	verify := step.BuildParams.Verify

	buildName, err := utils.RunJenkinsPipeline(jenkinsfile, request, pipelineName)
	if err != nil {
		t.Fatal(err)
	}
	verifyPipelineRun(t, step, verify, testdataPath, repoName, buildName, config)
}

func executeStepUpload(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData, repoName string, config map[string]string) {
	if step.UploadParams == nil || len(step.UploadParams.File) == 0 {
		t.Fatalf("Missing upload parameters.")
	}
	if len(step.UploadParams.Filename) == 0 {
		step.UploadParams.Filename = filepath.Base(step.UploadParams.File)
	}
	cdUserPassword, err := b64.StdEncoding.DecodeString(config["CD_USER_PWD_B64"])
	if err != nil {
		t.Fatalf("Execution of `upload-file-to-bitbucket.sh` failed: \nErr: %s\n", err)
	}

	fileToUpload := fmt.Sprintf("%s/%s", testdataPath, step.UploadParams.File)

	if step.UploadParams.Render {
		fmt.Printf("Rendering template to upload")
		tmpl, err := template.ParseFiles(fileToUpload)
		if err != nil {
			t.Fatalf("Failed to load file to upload: \nErr: %s\n", err)

		}
		outputFile, err := os.Create(fileToUpload)
		if err != nil {
			t.Fatalf("Error creating output file: \nErr: %s\n", err)

		}
		defer outputFile.Close()
		fmt.Printf("Execute render")
		err = tmpl.Execute(outputFile, tmplData)
		if err != nil {
			t.Fatalf("Failed to render file: \nErr: %s\n", err)
		}
	}
	var targetRepository string = repoName
	if len(step.UploadParams.Repository) > 0 {
		targetRepository = renderTemplate(t, step.UploadParams.Repository, tmplData)
	}
	stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/upload-file-to-bitbucket.sh", []string{
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
			"Execution of `upload-file-to-bitbucket.sh` failed: \nStdOut: %s\nStdErr: %s\nErr: %s\n",
			stdout,
			stderr,
			err)
	} else {
		fmt.Printf("Uploaded file %s to %s\n", step.UploadParams.File, config["BITBUCKET_URL"])
	}
}

func executeStepRun(t *testing.T, step TestStep, testdataPath string) {
	if step.RunParams == nil || len(step.RunParams.File) == 0 {
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
	files, err := ioutil.ReadDir(dir)
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
	sanitizedOdsGitRef := strings.Replace(config["ODS_GIT_REF"], "/", "_", -1)
	sanitizedOdsGitRef = strings.Replace(sanitizedOdsGitRef, "-", "_", -1)
	var buildNumber string
	if len(buildName) > 0 {
		buildParts := strings.Split(buildName, "-")
		buildNumber = buildParts[len(buildParts)-1]
	}
	aquaEnabled, _ := strconv.ParseBool(config["AQUA_ENABLED"])
	return TemplateData{
		ProjectID:           utils.PROJECT_NAME,
		ComponentID:         componentID,
		OdsNamespace:        config["ODS_NAMESPACE"],
		OdsGitRef:           config["ODS_GIT_REF"],
		OdsImageTag:         config["ODS_IMAGE_TAG"],
		OdsBitbucketProject: config["ODS_BITBUCKET_PROJECT"],
		SanitizedOdsGitRef:  sanitizedOdsGitRef,
		BuildNumber:         buildNumber,
		SonarQualityProfile: utils.GetEnv("SONAR_QUALITY_PROFILE", "Sonar way"),
		AquaEnabled:         aquaEnabled,
	}
}

// verifyPipelineRun checks that all expected values from the TestStepVerify
// definition are present.
func verifyPipelineRun(t *testing.T, step TestStep, verify *TestStepVerify, testdataPath string, repoName string, buildName string, config map[string]string) {
	if verify == nil {
		fmt.Println("Nothing to verify for", buildName)
		return
	}

	tmplData := templateData(config, step.ComponentID, buildName)

	if len(verify.JenkinsStages) > 0 {
		fmt.Printf("Verifying Jenkins stages of %s ...\n", buildName)
		stages, err := utils.RetrieveJenkinsBuildStagesForBuild(utils.PROJECT_NAME_CD, buildName)
		if err != nil {
			t.Fatal(err)
		}
		fmt.Printf("%s pipeline run for %s returned:\n%s", step.Type, step.ComponentID, stages)
		err = verifyGoldenFile(
			step.ComponentID,
			fmt.Sprintf("%s/%s", testdataPath, verify.JenkinsStages),
			stages,
			tmplData,
		)
		if err != nil {
			t.Fatal(err)
		}
	}

	if len(verify.SonarScan) > 0 {
		fmt.Printf("Verifying Sonar scan of %s ...\n", buildName)
		sonarscan, err := retrieveSonarScan(repoName, config)
		if err != nil {
			t.Fatal(err)
		}
		err = verifyGoldenFile(
			step.ComponentID,
			fmt.Sprintf("%s/%s", testdataPath, verify.SonarScan),
			sonarscan,
			tmplData,
		)
		if err != nil {
			t.Fatal(err)
		}
	}

	if len(verify.RunAttachments) > 0 {
		fmt.Printf("Verifying Jenkins run attachments of %s ...\n", buildName)
		artifactsToVerify := []string{}
		for _, a := range verify.RunAttachments {
			artifactsToVerify = append(
				artifactsToVerify,
				renderTemplate(t, a, tmplData),
			)
		}
		err := utils.VerifyJenkinsRunAttachments(utils.PROJECT_NAME_CD, buildName, artifactsToVerify)
		if err != nil {
			t.Fatal(err)
		}
	}

	if verify.TestResults > 0 {
		fmt.Printf("Verifying unit tests of %s ...\n", buildName)
		stdout, stderr, err := utils.RunScriptFromBaseDir("tests/scripts/print-jenkins-unittest-results.sh", []string{
			utils.PROJECT_NAME_CD,
			buildName,
		}, []string{})
		if err != nil {
			t.Fatalf("Could not find unit tests for build:%s\nstdout: %s\nstderr:%s\nerr: %s\n",
				buildName, stdout, stderr, err)
		}

		r := regexp.MustCompile("([0-9]+) tests")
		match := r.FindStringSubmatch(stdout)
		if match == nil {
			t.Fatalf("Could not find any unit tests for build:%s\nstdout: %s\nstderr:%s\nerr: %s\n",
				buildName, stdout, stderr, err)
		}
		foundTests, err := strconv.Atoi(match[1])
		if err != nil {
			t.Fatalf("Could not convert number of unit tests to int: %s", err)
		}
		if foundTests < verify.TestResults {
			t.Fatalf("Expected %d unit tests, but found only %d for build:%s\n",
				verify.TestResults, foundTests, buildName)
		}
	}

	if verify.OpenShiftResources != nil {
		var ocNamespace string
		if len(verify.OpenShiftResources.Namespace) > 0 {
			ocNamespace = renderTemplate(t, verify.OpenShiftResources.Namespace, tmplData)
		} else {
			ocNamespace = utils.PROJECT_NAME_DEV
		}
		fmt.Printf("Verifying OpenShift resources of %s in %s ...\n", step.ComponentID, ocNamespace)
		imageTags := []utils.ImageTag{}
		for _, it := range verify.OpenShiftResources.ImageTags {
			imageTags = append(
				imageTags,
				utils.ImageTag{
					Name: renderTemplate(t, it.Name, tmplData),
					Tag:  renderTemplate(t, it.Tag, tmplData),
				},
			)
		}
		resources := utils.Resources{
			Namespace:         ocNamespace,
			ImageTags:         imageTags,
			BuildConfigs:      renderTemplates(t, verify.OpenShiftResources.BuildConfigs, tmplData),
			DeploymentConfigs: renderTemplates(t, verify.OpenShiftResources.DeploymentConfigs, tmplData),
			Services:          renderTemplates(t, verify.OpenShiftResources.Services, tmplData),
			ImageStreams:      renderTemplates(t, verify.OpenShiftResources.ImageStreams, tmplData),
		}
		utils.CheckResources(resources, t)
	}
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
