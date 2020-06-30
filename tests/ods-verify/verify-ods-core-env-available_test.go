package ods_verify

import (
	"testing"

	"github.com/opendevstack/ods-core/tests/validate"
)

func TestVerifyOdsCoreEnvAvailable(t *testing.T) {
	validate.OdsNamespaceVariableOrFail(t)
}
