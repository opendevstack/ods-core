package ods_verify

import (
	"testing"

	validate "github.com/opendevstack/ods-core/tests/validate"
)

func TestVerifyOdsNamespaceImages(t *testing.T) {
	odsNamespace := validate.OdsNamespaceVariableOrFail(t)
	validate.OdsProjectExistsOrFail(t, odsNamespace)
}
