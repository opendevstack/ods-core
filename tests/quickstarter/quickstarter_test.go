package quickstarter

import (
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"testing"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
	"github.com/opendevstack/ods-core/tests/quickstarter/reporting"
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
	// Initialize the logger
	logger.Init()
	log := logger.GetLogger()

	log.Infof("🚀 Starting Quickstarter Test Framework\n")

	// Ensure cleanup of port-forwards even on panic or interrupt
	defer steps.CleanupAllPortForwards()

	// Setup signal handler for graceful shutdown (Ctrl+C)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigChan
		logger.Interrupt()
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
		logger.Error(fmt.Sprintf("Failed to get working directory: %v", err))
		return
	}
	quickstarterPaths = utils.RemoveExcludedQuickstarters(t, dir, quickstarterPaths)

	config, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatal(err)
	}

	logger.Section("Test Paths")
	logger.List(fmt.Sprintf("Found %d quickstarter(s) to test:", len(quickstarterPaths)))
	for _, quickstarterPath := range quickstarterPaths {
		logger.List(quickstarterPath)
	}

	for _, quickstarterPath := range quickstarterPaths {
		testdataPath := fmt.Sprintf("%s/testdata", quickstarterPath)
		quickstarterRepo := filepath.Base(filepath.Dir(quickstarterPath))
		quickstarterName := filepath.Base(quickstarterPath)

		logger.Section(fmt.Sprintf("Testing Quickstarter: %s", quickstarterName))

		// Run each quickstarter test in a subtest to avoid exiting early
		// when t.Fatal is used.
		t.Run(quickstarterName, func(t *testing.T) {
			t.Parallel()
			// Ensure port-forwards are cleaned up after each subtest
			defer steps.CleanupAllPortForwards()

			s, err := readSteps(testdataPath)
			if err != nil {
				t.Fatal(err)
			}

			// Create test report for this quickstarter
			report := reporting.NewTestReport(quickstarterName)
			defer func() {
				report.Finalize()
				log := logger.GetLogger()
				log.Infof("\n%s\n", report.String())

				// Optionally export reports (can be controlled via env var)
				if os.Getenv("EXPORT_TEST_REPORTS") == "true" {
					reportFile := filepath.Join(testdataPath, fmt.Sprintf("test-report-%s.json", quickstarterName))
					if err := reporting.ExportJSON(report, reportFile); err != nil {
						log.Warnf("Failed to export JSON report: %v", err)
					}
				}
			}()

			// Create shared template data outside the loop so it persists across steps
			// This allows steps like expose-service to store data for later steps to use
			tmplData := steps.CreateTemplateData(config, s.ComponentID, "", utils.PROJECT_NAME)

			logger.SubSection(fmt.Sprintf("Component: %s", s.ComponentID))
			logger.List(fmt.Sprintf("Total steps to execute: %d", len(s.Steps)))

			for i, step := range s.Steps {
				// Step might overwrite component ID
				if len(step.ComponentID) == 0 {
					step.ComponentID = s.ComponentID
				}

				// Check if step should be skipped
				if steps.ShouldSkipStep(t, &step, tmplData) {
					logger.Info(fmt.Sprintf("⊘ Skipping step %d: %s (skip=%v, skipIf=%q)", i+1, step.Type, step.Skip, step.SkipIf))
					continue
				}

				logger.Step(
					i+1,
					len(s.Steps),
					step.Type,
					step.Description,
				)

				report.RecordStepStart(i, step.Type, step.Description)

				repoName := fmt.Sprintf("%s-%s", strings.ToLower(utils.PROJECT_NAME), step.ComponentID)

				// Execute the appropriate step based on type with error handling
				var stepErr error
				executor := steps.NewStepExecutor(testdataPath, tmplData)

				// Get the handler from the registry
				handler, err := steps.DefaultRegistry().Get(step.Type)
				if err != nil {
					t.Fatalf("Step %d failed: %v", i+1, err)
				}

				// Build execution parameters
				params := &steps.ExecutionParams{
					TestdataPath:     testdataPath,
					TmplData:         tmplData,
					RepoName:         repoName,
					QuickstarterRepo: quickstarterRepo,
					QuickstarterName: quickstarterName,
					Config:           config,
					ProjectName:      utils.PROJECT_NAME,
				}

				// Execute the step with hooks
				stepErr = executor.ExecuteWithHooks(t, &step, func() error {
					return handler.Execute(t, &step, params)
				})

				if stepErr != nil {
					report.RecordStepEnd(i, "failed", stepErr, nil)
					t.Fatalf("Step %d failed: %v", i+1, stepErr)
				} else {
					report.RecordStepEnd(i, "passed", nil, nil)
					logger.StepSuccess(step.Type)
				}
			}

			logger.Success(fmt.Sprintf("All steps completed for quickstarter %s", quickstarterName))
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
