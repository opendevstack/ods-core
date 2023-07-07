package quickstarter

import (
	"bytes"
	"fmt"
	"html/template"

	"github.com/google/go-cmp/cmp"
)

func verifyGoldenFile(componentID string, wantFile string, gotFile string, tmplData TemplateData) error {

	var want bytes.Buffer
	tmpl, err := template.ParseFiles(wantFile)
	if err != nil {
		return fmt.Errorf("Failed to load golden file to verify State: %w", err)
	}
	err = tmpl.Execute(&want, tmplData)
	if err != nil {
		return fmt.Errorf("Failed to render file to verify State: %w", err)
	}

	if diff := cmp.Diff(want.String(), gotFile); diff != "" {
		return fmt.Errorf("State mismatch for %s (-want +got):\n%s", componentID, diff)
	}

	return nil
}
