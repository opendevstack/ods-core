package steps

import (
	"bytes"
	"encoding/json"
	"fmt"
	"html/template"

	"github.com/google/go-cmp/cmp"
)

// verifyJSONGoldenFile compares actual JSON output against a golden file template
func verifyJSONGoldenFile(componentID string, wantFile string, gotFile string, tmplData TemplateData) error {

	var want bytes.Buffer
	tmpl, err := template.ParseFiles(wantFile)
	if err != nil {
		return fmt.Errorf("failed to load golden file to verify state: %w", err)
	}
	err = tmpl.Execute(&want, tmplData)
	if err != nil {
		return fmt.Errorf("failed to render file to verify state: %w", err)
	}

	// Unmarshal both JSONs into objects
	var wantObj, gotObj interface{}
	if err := json.Unmarshal(want.Bytes(), &wantObj); err != nil {
		return fmt.Errorf("failed to unmarshal want json: %w", err)
	}
	if err := json.Unmarshal([]byte(gotFile), &gotObj); err != nil {
		return fmt.Errorf("failed to unmarshal got json: %w", err)
	}

	// Compare the actual objects, not the strings
	if diff := cmp.Diff(wantObj, gotObj); diff != "" {
		// Pretty print both for easier comparison
		wantJSON, _ := json.MarshalIndent(wantObj, "", "  ")
		gotJSON, _ := json.MarshalIndent(gotObj, "", "  ")

		return fmt.Errorf("state mismatch for %s\n\n=== EXPECTED ===\n%s\n\n=== ACTUAL ===\n%s\n\n=== DIFF (-want +got) ===\n%s",
			componentID, string(wantJSON), string(gotJSON), diff)
	}

	return nil
}
