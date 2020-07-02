package ods_verify

import (
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
	"github.com/opendevstack/ods-core/tests/validate"
)

func TestVerifyOdsNamespaceServicesWithPodsRunning(t *testing.T) {
	odsNamespace := validate.OdsCoreEnvVariableOrFail(t, validate.ODS_NAMESPACE)
	validate.OdsProjectExistsOrFail(t, odsNamespace)

	resourcesInTest := utils.Resources{
		Namespace:         odsNamespace,
		ImageTags:         []utils.ImageTag{},
		BuildConfigs:      []string{},
		DeploymentConfigs: []string{},
		// The services test also checks there is at least one pod per selector and
		// that all pods found are in phase 'running'
		Services: []string{
			"webhook-proxy",
			"jenkins",
			"nexus",
			"ods-provisioning-app",
			"sonarqube",
		},
		ImageStreams: []string{},
	}

	utils.CheckResources(resourcesInTest, t)

}
