package ods_verify

import (
	"testing"

	"github.com/opendevstack/ods-core/tests/validate"
)

func TestVerifyOdsCoreEnvAvailable(t *testing.T) {
	validate.OdsCoreEnvVariableOrFail(t, validate.ODS_NAMESPACE)
	validate.OdsCoreEnvVariableOrFail(t, validate.ODS_IMAGE_TAG)
}
