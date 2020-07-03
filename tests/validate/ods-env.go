package validate

import (
	"strings"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
)

const ODS_NAMESPACE = "ODS_NAMESPACE"
const ODS_IMAGE_TAG = "ODS_IMAGE_TAG"

// OdsCoreEnvVariableOrFail reads ODS_NAMESPACE variable form ods-core.env or fails
func OdsCoreEnvVariableOrFail(t *testing.T, name string) string {
	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatalf("Could not read ods-core.env: %s", err)
	}
	odsVariable, ok := values[name]
	if !ok {
		t.Fatalf("Variable %s is not defined in ods-core.env", name)
	}
	if len(odsVariable) == 0 {
		t.Fatalf("%s has zero length defined in ods-core.env", name)
	}
	odsVariable = strings.TrimSpace(odsVariable)
	if len(odsVariable) == 0 {
		t.Fatalf("Trimmed %s value has zero length defined in ods-core.env", name)
	}
	// There may also be a Validation method in the openshift API but I could not locate it:
	// See https://github.com/openshift/origin/pull/2351
	// Are there additional name restrictions we impose?
	return odsVariable
}
