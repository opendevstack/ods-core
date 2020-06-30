package validate

import (
	"strings"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

// OdsNamespaceVariableOrFail reads ODS_NAMESPACE variable form ods-core.env or fails
func OdsNamespaceVariableOrFail(t *testing.T) string {
	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatalf("Could not read ods-core.env: %s", err)
	}
	odsNamespace, ok := values["ODS_NAMESPACE"]
	if !ok {
		t.Fatalf("Variable ODS_NAMESPACE is not defined in ods-core.env")
	}
	if len(odsNamespace) == 0 {
		t.Fatalf("ODS_NAMESPACE has zero length defined in ods-core.env")
	}
	odsNamespace = strings.TrimSpace(odsNamespace)
	if len(odsNamespace) == 0 {
		t.Fatalf("Trimmed ODS_NAMESPACE value has zero length defined in ods-core.env")
	}
	// There may also be a Validation method in the openshift API but I could not locate it:
	// See https://github.com/openshift/origin/pull/2351
	// Are there additional name restrictions we impose?
	return odsNamespace
}
