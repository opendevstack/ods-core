package steps

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/opendevstack/ods-core/tests/quickstarter/diagnostics"
	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
)

// StepExecutor handles step execution with lifecycle hooks and retry logic.
type StepExecutor struct {
	testdataPath string
	tmplData     TemplateData
	diagnostics  *diagnostics.DiagnosticsCollector
}

// NewStepExecutor creates a new step executor.
func NewStepExecutor(testdataPath string, tmplData TemplateData) *StepExecutor {
	return &StepExecutor{
		testdataPath: testdataPath,
		tmplData:     tmplData,
		diagnostics:  diagnostics.NewDiagnosticsCollector(nil),
	}
}

// ExecuteWithHooks executes a step with before/after hooks.
func (se *StepExecutor) ExecuteWithHooks(
	t *testing.T,
	step *TestStep,
	handler func() error,
) error {
	log := logger.GetLogger()

	// Execute beforeStep hook if specified
	if step.BeforeStep != "" {
		log.Infof("Executing beforeStep hook: %s", step.BeforeStep)
		if err := se.executeHook(t, step.BeforeStep); err != nil {
			return fmt.Errorf("beforeStep hook failed: %w", err)
		}
	}

	// Execute the main step with retry logic
	err := se.executeWithRetry(t, step, handler)

	// Execute afterStep hook regardless of success/failure
	if step.AfterStep != "" {
		log.Infof("Executing afterStep hook: %s", step.AfterStep)
		if hookErr := se.executeHook(t, step.AfterStep); hookErr != nil {
			log.Warnf("afterStep hook failed: %v", hookErr)
			// Don't override main error, but log the hook failure
			if err == nil {
				err = hookErr
			}
		}
	}

	return err
}

// executeWithRetry executes a step with retry logic.
func (se *StepExecutor) executeWithRetry(
	t *testing.T,
	step *TestStep,
	handler func() error,
) error {
	log := logger.GetLogger()

	// Determine retry configuration
	retryConfig := step.Retry
	if retryConfig == nil {
		retryConfig = &StepRetryConfig{Attempts: 0}
	}

	maxAttempts := retryConfig.Attempts + 1 // +1 for the initial attempt
	if maxAttempts < 1 {
		maxAttempts = 1
	}

	var lastErr error
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		if attempt > 1 {
			log.Infof("Retry attempt %d/%d", attempt, maxAttempts)
		}

		lastErr = handler()

		// If successful, return
		if lastErr == nil {
			return nil
		}

		// Check if we should retry
		if attempt < maxAttempts {
			// Check if error is transient (if configured)
			if retryConfig.OnlyTransient && !diagnostics.IsTransientError(lastErr) {
				log.Warnf("Error is not transient, skipping retries: %v", lastErr)
				return lastErr
			}

			// Calculate delay
			delay := 2 * time.Second // default delay
			if retryConfig.Delay != "" {
				parsedDelay, err := time.ParseDuration(retryConfig.Delay)
				if err == nil {
					delay = parsedDelay
				}
			}

			log.Infof("Waiting %v before next attempt", delay)
			time.Sleep(delay)
		}
	}

	return lastErr
}

// executeHook executes a hook script.
func (se *StepExecutor) executeHook(t *testing.T, hookFile string) error {
	hookPath := filepath.Join(se.testdataPath, hookFile)

	// Check if hook file exists
	if _, err := os.Stat(hookPath); os.IsNotExist(err) {
		return fmt.Errorf("hook file not found: %s", hookPath)
	}

	// Execute the hook script
	cmd := exec.Command("bash", hookPath)

	// Set up environment with template data
	env := os.Environ()
	for key, value := range se.tmplData {
		if strVal, ok := value.(string); ok {
			env = append(env, fmt.Sprintf("%s=%s", key, strVal))
		}
	}
	cmd.Env = env

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("hook execution failed: %w", err)
	}

	return nil
}

// ShouldSkipStep determines if a step should be skipped.
func ShouldSkipStep(t *testing.T, step *TestStep, tmplData TemplateData) bool {
	if step.Skip {
		return true
	}

	// Evaluate skipIf condition
	if step.SkipIf != "" {
		rendered := renderTemplate(t, step.SkipIf, tmplData)
		// Simple evaluation: treat non-empty string as true
		if rendered != "" && rendered != "false" && rendered != "0" {
			return true
		}
	}

	return false
}
