package steps

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"testing"
	"text/template"
	"time"

	"github.com/tidwall/gjson"
)

// ExecuteHTTP handles the http step type for testing HTTP endpoints.
func ExecuteHTTP(t *testing.T, step TestStep, testdataPath string, tmplData TemplateData) {
	if step.HTTPParams == nil {
		t.Fatal("Missing HTTP parameters")
	}

	params := step.HTTPParams

	// Resolve URL using smart resolution (route -> in-cluster -> port-forward)
	url := ResolveServiceURL(t, params.URL, tmplData)

	// Default method to GET
	method := params.Method
	if method == "" {
		method = "GET"
	}

	// Default timeout to 30 seconds
	timeout := params.Timeout
	if timeout == 0 {
		timeout = 30
	}

	// Default retry attempts
	retryAttempts := 1
	retryDelay := 0 * time.Second
	if params.Retry != nil {
		retryAttempts = params.Retry.Attempts
		if retryAttempts == 0 {
			retryAttempts = 1
		}
		if params.Retry.Delay != "" {
			var err error
			retryDelay, err = time.ParseDuration(params.Retry.Delay)
			if err != nil {
				t.Fatalf("Invalid retry delay duration: %s", params.Retry.Delay)
			}
		}
	}

	fmt.Printf("Testing HTTP endpoint: %s %s\n", method, url)

	var lastErr error
	var resp *http.Response
	var body []byte

	// Retry logic
	for attempt := 1; attempt <= retryAttempts; attempt++ {
		if attempt > 1 {
			fmt.Printf("Retry attempt %d/%d after %v\n", attempt, retryAttempts, retryDelay)
			time.Sleep(retryDelay)
		}

		var err error
		resp, body, err = executeHTTPRequest(method, url, params, tmplData, timeout)
		if err != nil {
			lastErr = err
			continue
		}

		// Check status code
		if params.ExpectedStatus > 0 && resp.StatusCode != params.ExpectedStatus {
			lastErr = fmt.Errorf("expected status %d, got %d", params.ExpectedStatus, resp.StatusCode)
			continue
		}

		// All checks passed
		lastErr = nil
		break
	}

	if lastErr != nil {
		t.Fatalf("HTTP request failed after %d attempts: %v", retryAttempts, lastErr)
	}

	fmt.Printf("HTTP request successful: %d %s\n", resp.StatusCode, http.StatusText(resp.StatusCode))

	// Verify expected body if provided
	if params.ExpectedBody != "" {
		goldenFile := fmt.Sprintf("%s/%s", testdataPath, params.ExpectedBody)
		if err := verifyJSONGoldenFile(step.ComponentID, goldenFile, string(body), tmplData); err != nil {
			t.Fatalf("Response body mismatch: %v", err)
		}
		fmt.Printf("Response body matches golden file\n")
	}

	// Run assertions
	if len(params.Assertions) > 0 {
		if err := verifyHTTPAssertions(params.Assertions, body, tmplData, t); err != nil {
			t.Fatalf("Assertion failed: %v", err)
		}
		fmt.Printf("All %d assertions passed\n", len(params.Assertions))
	}
}

// executeHTTPRequest performs the actual HTTP request
func executeHTTPRequest(method, url string, params *TestStepHTTPParams, tmplData TemplateData, timeout int) (*http.Response, []byte, error) {
	// Create request body if provided
	var bodyReader io.Reader
	if params.Body != "" {
		renderedBody := renderTemplateHTTP(nil, params.Body, tmplData)
		bodyReader = strings.NewReader(renderedBody)
	}

	// Create request
	req, err := http.NewRequest(method, url, bodyReader)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Add headers
	for key, value := range params.Headers {
		renderedValue := renderTemplateHTTP(nil, value, tmplData)
		req.Header.Set(key, renderedValue)
	}

	// Create client with timeout
	client := &http.Client{
		Timeout: time.Duration(timeout) * time.Second,
	}

	// Execute request
	resp, err := client.Do(req)
	if err != nil {
		return nil, nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return resp, nil, fmt.Errorf("failed to read response body: %w", err)
	}

	return resp, body, nil
}

// verifyHTTPAssertions verifies JSONPath-based assertions
func verifyHTTPAssertions(assertions []HTTPAssertion, body []byte, tmplData TemplateData, t *testing.T) error {
	bodyStr := string(body)

	// Try to parse as JSON for JSON assertions
	var isJSON bool
	var jsonData interface{}
	if err := json.Unmarshal(body, &jsonData); err == nil {
		isJSON = true
	}

	for i, assertion := range assertions {
		// Handle Equals assertion
		if assertion.Equals != nil {
			if !isJSON {
				return fmt.Errorf("assertion %d: cannot use JSONPath on non-JSON response", i)
			}
			result := gjson.Get(bodyStr, assertion.Path)
			if !result.Exists() {
				return fmt.Errorf("assertion %d: path %s does not exist", i, assertion.Path)
			}

			expectedStr := fmt.Sprintf("%v", assertion.Equals)
			actualStr := result.String()
			if expectedStr != actualStr {
				return fmt.Errorf("assertion %d: path %s expected %v, got %v", i, assertion.Path, assertion.Equals, result.Value())
			}
		}

		// Handle Exists assertion
		if assertion.Exists != nil {
			if !isJSON {
				return fmt.Errorf("assertion %d: cannot use JSONPath on non-JSON response", i)
			}
			result := gjson.Get(bodyStr, assertion.Path)
			exists := result.Exists()
			if *assertion.Exists != exists {
				return fmt.Errorf("assertion %d: path %s existence check failed (expected %v, got %v)", i, assertion.Path, *assertion.Exists, exists)
			}
		}

		// Handle Contains assertion
		if assertion.Contains != "" {
			if isJSON && assertion.Path != "" {
				result := gjson.Get(bodyStr, assertion.Path)
				if !result.Exists() {
					return fmt.Errorf("assertion %d: path %s does not exist", i, assertion.Path)
				}
				if !strings.Contains(result.String(), assertion.Contains) {
					return fmt.Errorf("assertion %d: path %s does not contain %q", i, assertion.Path, assertion.Contains)
				}
			} else {
				if !strings.Contains(bodyStr, assertion.Contains) {
					return fmt.Errorf("assertion %d: response does not contain %q", i, assertion.Contains)
				}
			}
		}

		// Handle Matches (regex) assertion
		if assertion.Matches != "" {
			var target string
			if isJSON && assertion.Path != "" {
				result := gjson.Get(bodyStr, assertion.Path)
				if !result.Exists() {
					return fmt.Errorf("assertion %d: path %s does not exist", i, assertion.Path)
				}
				target = result.String()
			} else {
				target = bodyStr
			}

			matched, err := regexp.MatchString(assertion.Matches, target)
			if err != nil {
				return fmt.Errorf("assertion %d: invalid regex %q: %w", i, assertion.Matches, err)
			}
			if !matched {
				return fmt.Errorf("assertion %d: value does not match regex %q", i, assertion.Matches)
			}
		}
	}

	return nil
}

// renderTemplateHTTP is a helper that allows nil *testing.T for non-test contexts
func renderTemplateHTTP(t *testing.T, tpl string, tmplData TemplateData) string {
	// If template is empty, return as-is
	if tpl == "" {
		return tpl
	}

	// If no template markers, return as-is
	if !strings.Contains(tpl, "{{") {
		return tpl
	}

	var buffer bytes.Buffer
	tmpl, err := template.New("inline").Parse(tpl)
	if err != nil {
		if t != nil {
			t.Fatalf("Error parsing template: %s", err)
		}
		panic(fmt.Sprintf("Error parsing template: %s", err))
	}
	tmplErr := tmpl.Execute(&buffer, tmplData)
	if tmplErr != nil {
		if t != nil {
			t.Fatalf("Error rendering template: %s", tmplErr)
		}
		panic(fmt.Sprintf("Error rendering template: %s", tmplErr))
	}
	return buffer.String()
}
