package quickstarter

import (
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"testing"

	"github.com/opendevstack/ods-core/tests/quickstarter/steps"
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
	// Ensure cleanup of port-forwards even on panic or interrupt
	defer steps.CleanupAllPortForwards()

	// Setup signal handler for graceful shutdown (Ctrl+C)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigChan
		fmt.Printf("\n\n⚠️  Interrupt received, cleaning up...\n")
		steps.CleanupAllPortForwards()
		os.Exit(1)
	}()

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
				tmplData := steps.CreateTemplateData(config, step.ComponentID, "", utils.PROJECT_NAME)

				// Execute the appropriate step based on type
				switch step.Type {
				case steps.StepTypeUpload:
					steps.ExecuteUpload(t, step, testdataPath, tmplData, repoName, config, utils.PROJECT_NAME)
				case steps.StepTypeRun:
					steps.ExecuteRun(t, step, testdataPath, tmplData, utils.PROJECT_NAME)
				case steps.StepTypeProvision:
					steps.ExecuteProvision(t, step, testdataPath, tmplData, repoName, quickstarterRepo, quickstarterName, config, utils.PROJECT_NAME)
				case steps.StepTypeBuild:
					steps.ExecuteBuild(t, step, testdataPath, tmplData, repoName, config, utils.PROJECT_NAME)
				case steps.StepTypeHTTP:
					steps.ExecuteHTTP(t, step, testdataPath, tmplData)
				case steps.StepTypeWait:
					steps.ExecuteWait(t, step, testdataPath, tmplData, utils.PROJECT_NAME)
				case steps.StepTypeInspect:
					steps.ExecuteInspect(t, step, testdataPath, tmplData, utils.PROJECT_NAME)
				default:
					t.Fatalf("Unknown step type: %s", step.Type)
				}
			}

			fmt.Printf("\n\n\n\n")
			fmt.Printf("========== End test for Quickstarter %s\n", quickstarterName)
			fmt.Printf("\n\n")
		})

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
