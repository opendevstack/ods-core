package reporting

import (
	"encoding/json"
	"fmt"
	"os"
)

// JUnitTestSuite represents a JUnit test suite
type JUnitTestSuite struct {
	Name     string          `xml:"name,attr"`
	Tests    int             `xml:"tests,attr"`
	Failures int             `xml:"failures,attr"`
	Skipped  int             `xml:"skipped,attr"`
	Time     string          `xml:"time,attr"`
	TestCase []JUnitTestCase `xml:"testcase"`
}

// JUnitTestCase represents a single test case in JUnit format
type JUnitTestCase struct {
	Name      string        `xml:"name,attr"`
	ClassName string        `xml:"classname,attr"`
	Time      string        `xml:"time,attr"`
	Failure   *JUnitFailure `xml:"failure,omitempty"`
	Skipped   *JUnitSkipped `xml:"skipped,omitempty"`
	StdErr    string        `xml:"system-err,omitempty"`
}

// JUnitFailure represents a test failure in JUnit format
type JUnitFailure struct {
	Message string `xml:"message,attr"`
	Text    string `xml:",chardata"`
}

// JUnitSkipped represents a skipped test in JUnit format
type JUnitSkipped struct {
	Message string `xml:"message,attr"`
}

// ExportJUnitXML exports the test report in JUnit XML format (simplified JSON-based approach).
// For full XML compatibility, consider using a dedicated XML library.
func ExportJUnitXML(report *TestReport, outputPath string) error {
	suite := JUnitTestSuite{
		Name:     report.QuickstarterID,
		Tests:    report.Summary.TotalSteps,
		Failures: report.Summary.FailedSteps,
		Skipped:  report.Summary.SkippedSteps,
		Time:     fmt.Sprintf("%.2f", report.TotalDuration.Seconds()),
	}

	for _, step := range report.Steps {
		tc := JUnitTestCase{
			Name:      step.Type,
			ClassName: fmt.Sprintf("%s.%s", report.QuickstarterID, step.Description),
			Time:      fmt.Sprintf("%.2f", step.Duration.Seconds()),
		}

		if step.Status == "failed" && step.Error != "" {
			tc.Failure = &JUnitFailure{
				Message: step.Error,
				Text:    step.Error,
			}
		} else if step.Status == "skipped" {
			tc.Skipped = &JUnitSkipped{
				Message: "Step skipped",
			}
		}

		suite.TestCase = append(suite.TestCase, tc)
	}

	// Export as JSON for now (can be converted to XML later if needed)
	data, err := json.MarshalIndent(suite, "", "  ")
	if err != nil {
		return err
	}

	if err := os.WriteFile(outputPath, data, 0644); err != nil {
		return fmt.Errorf("failed to write JUnit report: %w", err)
	}

	return nil
}

// ExportJSON exports the test report as JSON.
func ExportJSON(report *TestReport, outputPath string) error {
	data, err := report.ToJSON()
	if err != nil {
		return err
	}

	if err := os.WriteFile(outputPath, data, 0644); err != nil {
		return fmt.Errorf("failed to write JSON report: %w", err)
	}

	return nil
}
