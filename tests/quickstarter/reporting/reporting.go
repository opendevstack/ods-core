package reporting

import (
	"encoding/json"
	"fmt"
	"sync"
	"time"
)

// TestReport contains aggregated test execution metrics.
type TestReport struct {
	StartTime      time.Time     `json:"startTime"`
	EndTime        time.Time     `json:"endTime"`
	TotalDuration  time.Duration `json:"totalDuration"`
	QuickstarterID string        `json:"quickstarterID"`
	Steps          []StepReport  `json:"steps"`
	Summary        TestSummary   `json:"summary"`
	mu             sync.RWMutex  `json:"-"`
}

// StepReport contains execution metrics for a single test step.
type StepReport struct {
	Index       int                    `json:"index"`
	Type        string                 `json:"type"`
	Description string                 `json:"description"`
	StartTime   time.Time              `json:"startTime"`
	EndTime     time.Time              `json:"endTime"`
	Duration    time.Duration          `json:"duration"`
	Status      string                 `json:"status"` // "passed", "failed", "skipped"
	Error       string                 `json:"error,omitempty"`
	Context     map[string]interface{} `json:"context,omitempty"` // Pod logs, events, etc. on failure
}

// TestSummary provides overall test execution statistics.
type TestSummary struct {
	TotalSteps      int           `json:"totalSteps"`
	PassedSteps     int           `json:"passedSteps"`
	FailedSteps     int           `json:"failedSteps"`
	SkippedSteps    int           `json:"skippedSteps"`
	SuccessRate     float64       `json:"successRate"`
	AverageDuration time.Duration `json:"averageDuration"`
}

// NewTestReport creates a new test report for a quickstarter.
func NewTestReport(quickstarterID string) *TestReport {
	return &TestReport{
		StartTime:      time.Now(),
		QuickstarterID: quickstarterID,
		Steps:          []StepReport{},
	}
}

// RecordStepStart records the start of a step execution.
func (tr *TestReport) RecordStepStart(index int, stepType, description string) {
	tr.mu.Lock()
	defer tr.mu.Unlock()

	step := StepReport{
		Index:       index,
		Type:        stepType,
		Description: description,
		StartTime:   time.Now(),
		Status:      "running",
	}
	tr.Steps = append(tr.Steps, step)
}

// RecordStepEnd records the completion of a step execution.
func (tr *TestReport) RecordStepEnd(index int, status string, err error, context map[string]interface{}) {
	tr.mu.Lock()
	defer tr.mu.Unlock()

	if index >= len(tr.Steps) {
		return
	}

	tr.Steps[index].EndTime = time.Now()
	tr.Steps[index].Duration = tr.Steps[index].EndTime.Sub(tr.Steps[index].StartTime)
	tr.Steps[index].Status = status
	if err != nil {
		tr.Steps[index].Error = err.Error()
	}
	if context != nil {
		tr.Steps[index].Context = context
	}
}

// Finalize calculates the summary statistics and marks the report as complete.
func (tr *TestReport) Finalize() {
	tr.mu.Lock()
	defer tr.mu.Unlock()

	tr.EndTime = time.Now()
	tr.TotalDuration = tr.EndTime.Sub(tr.StartTime)

	summary := TestSummary{
		TotalSteps: len(tr.Steps),
	}

	totalDuration := time.Duration(0)

	for _, step := range tr.Steps {
		switch step.Status {
		case "passed":
			summary.PassedSteps++
		case "failed":
			summary.FailedSteps++
		case "skipped":
			summary.SkippedSteps++
		}
		totalDuration += step.Duration
	}

	if summary.TotalSteps > 0 {
		summary.SuccessRate = float64(summary.PassedSteps) / float64(summary.TotalSteps) * 100
		summary.AverageDuration = totalDuration / time.Duration(summary.TotalSteps)
	}

	tr.Summary = summary
}

// ToJSON serializes the report to JSON.
func (tr *TestReport) ToJSON() ([]byte, error) {
	return json.MarshalIndent(tr, "", "  ")
}

// String returns a human-readable summary of the test report.
func (tr *TestReport) String() string {
	s := tr.Summary
	return fmt.Sprintf(
		"Test Report: %s\n"+
			"  Total Steps:     %d\n"+
			"  Passed:          %d\n"+
			"  Failed:          %d\n"+
			"  Skipped:         %d\n"+
			"  Success Rate:    %.2f%%\n"+
			"  Total Duration:  %s\n"+
			"  Avg Per Step:    %s",
		tr.QuickstarterID,
		s.TotalSteps,
		s.PassedSteps,
		s.FailedSteps,
		s.SkippedSteps,
		s.SuccessRate,
		tr.TotalDuration,
		s.AverageDuration,
	)
}
