package quickstarter

import (
	"bytes"
	"encoding/json"
	"fmt"
	"html/template"

	"github.com/google/go-cmp/cmp"
)

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

	// Pretty print both JSONs before comparison
	var wantJSON, gotJSON bytes.Buffer
	var wantObj, gotObj interface{}
	if err := json.Unmarshal(want.Bytes(), &wantObj); err != nil {
		return fmt.Errorf("failed to unmarshal want json: %w", err)
	}
	if err := json.Unmarshal([]byte(gotFile), &gotObj); err != nil {
		return fmt.Errorf("failed to unmarshal got json: %w", err)
	}
	if err := json.Indent(&wantJSON, want.Bytes(), "", "  "); err != nil {
		return fmt.Errorf("failed to pretty print want json: %w", err)
	}
	if err := json.Indent(&gotJSON, []byte(gotFile), "", "  "); err != nil {
		return fmt.Errorf("failed to pretty print got json: %w", err)
	}

	if diff := cmp.Diff(wantJSON.String(), gotJSON.String()); diff != "" {
		return fmt.Errorf("state mismatch for %s (-want +got):\n%s", componentID, diff)
	}

	return nil
}
