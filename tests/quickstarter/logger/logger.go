package logger

import (
	"fmt"
	"os"

	"github.com/charmbracelet/log"
)

var logger *log.Logger

// Init initializes the logger with charmbracelet/log
func Init() {
	logger = log.New(os.Stderr)
	logger.SetLevel(log.DebugLevel)
	logger.SetReportCaller(false)
	logger.SetReportTimestamp(true)
}

// GetLogger returns the global logger instance
func GetLogger() *log.Logger {
	if logger == nil {
		Init()
	}
	return logger
}

// Section prints a prominent section header
func Section(title string) {
	if logger == nil {
		Init()
	}
	logger.Infof("\n%s═══════════════════════════════════════════════════════════════════════════════%s\n  %s%s%s\n%s═══════════════════════════════════════════════════════════════════════════════%s\n",
		"╔", "╗",
		"🚀 ", title, "",
		"╚", "╝")
}

// SubSection prints a sub-section header
func SubSection(title string) {
	if logger == nil {
		Init()
	}
	logger.Infof("\n%s─────────────────────────────────────────────────────────────────────────────────\n  %s%s\n%s─────────────────────────────────────────────────────────────────────────────────\n",
		"┌", "📋 ", title, "└")
}

// Step logs the start of a test step
func Step(stepNumber, totalSteps int, stepType, description string) {
	if logger == nil {
		Init()
	}
	logger.Infof("\n%s┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄%s\n  ▶️  Step %d/%d [%s]: %s\n%s┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄%s\n",
		"┌", "┐", stepNumber, totalSteps, stepType, description, "└", "┘")
}

// StepVerification logs a verification step
func StepVerification(description string) {
	if logger == nil {
		Init()
	}
	logger.Infof("\n%s┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄%s\n  🔍 Verifying: %s\n%s┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄%s\n",
		"┌", "┐", description, "└", "┘")
}

// StepSuccess logs successful step completion
func StepSuccess(stepType string) {
	if logger == nil {
		Init()
	}
	logger.Infof("✅ Step [%s] completed successfully", stepType)
}

// StepFailed logs failed step completion
func StepFailed(stepType string, err error) {
	if logger == nil {
		Init()
	}
	logger.Errorf("❌ Step [%s] failed: %v", stepType, err)
}

// Info logs informational messages
func Info(msg string, args ...interface{}) {
	if logger == nil {
		Init()
	}
	if len(args) > 0 {
		logger.Infof(msg, args...)
	} else {
		logger.Info(msg)
	}
}

// Debug logs debug messages
func Debug(msg string, args ...interface{}) {
	if logger == nil {
		Init()
	}
	if len(args) > 0 {
		logger.Debugf(msg, args...)
	} else {
		logger.Debug(msg)
	}
}

// Warn logs warning messages
func Warn(msg string, args ...interface{}) {
	if logger == nil {
		Init()
	}
	if len(args) > 0 {
		logger.Warnf(msg, args...)
	} else {
		logger.Warn(msg)
	}
}

// Error logs error messages
func Error(msg string, args ...interface{}) {
	if logger == nil {
		Init()
	}
	if len(args) > 0 {
		logger.Errorf(msg, args...)
	} else {
		logger.Error(msg)
	}
}

// Running logs an operation that is running
func Running(operation string) {
	if logger == nil {
		Init()
	}
	logger.Infof("⚙️  Running: %s", operation)
}

// Success logs a successful operation
func Success(operation string) {
	if logger == nil {
		Init()
	}
	logger.Infof("✅ Success: %s", operation)
}

// Failure logs a failed operation
func Failure(operation string, err error) {
	if logger == nil {
		Init()
	}
	logger.Errorf("❌ Failure: %s - %v", operation, err)
}

// Waiting logs a waiting operation
func Waiting(operation string) {
	if logger == nil {
		Init()
	}
	logger.Infof("⏳ Waiting: %s", operation)
}

// Completed logs a completed operation
func Completed(operation string) {
	if logger == nil {
		Init()
	}
	logger.Infof("✓ Completed: %s", operation)
}

// KeyValue logs key-value pairs for debugging
func KeyValue(key string, value interface{}) {
	if logger == nil {
		Init()
	}
	logger.Debugf("  🔹 %s: %v", key, value)
}

// List logs a list item
func List(item string) {
	if logger == nil {
		Init()
	}
	logger.Infof("  • %s", item)
}

// Separator prints a visual separator
func Separator() {
	if logger == nil {
		Init()
	}
	fmt.Println("─────────────────────────────────────────────────────────────────────────────────")
}

// TestSummary logs test summary information
func TestSummary(componentName string, totalSteps int, failedSteps int) {
	if logger == nil {
		Init()
	}
	status := "✅"
	if failedSteps > 0 {
		status = "❌"
	}
	logger.Infof("\n%s Test Summary for %s: %d/%d steps passed\n", status, componentName, totalSteps-failedSteps, totalSteps)
}

// Interrupt logs an interrupt signal
func Interrupt() {
	if logger == nil {
		Init()
	}
	logger.Warnf("⚠️  Interrupt received, cleaning up...")
}

// Exception logs an exception/panic condition
func Exception(msg string, err error) {
	if logger == nil {
		Init()
	}
	logger.Errorf("⚡ Exception: %s - %v", msg, err)
}
