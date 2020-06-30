package ods_verify

import (
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
	"github.com/opendevstack/ods-core/tests/validate"
)

func TestVerifyOdsNamespaceImages(t *testing.T) {
	odsNamespace := validate.OdsCoreEnvVariableOrFail(t, validate.ODS_NAMESPACE)
	validate.OdsProjectExistsOrFail(t, odsNamespace)

	odsImageTag := validate.OdsCoreEnvVariableOrFail(t, validate.ODS_IMAGE_TAG)

	resourcesInTest := utils.Resources{
		Namespace: odsNamespace,
		ImageTags: []utils.ImageTag{
			{Name: "jenkins-webhook-proxy", Tag: odsImageTag},
			{Name: "jenkins-master", Tag: odsImageTag},
			{Name: "jenkins-agent-base", Tag: odsImageTag},
			{Name: "jenkins-agent-golang", Tag: odsImageTag},
			{Name: "jenkins-agent-maven", Tag: odsImageTag},
			{Name: "jenkins-agent-nodejs10-angular", Tag: odsImageTag},
			{Name: "jenkins-agent-nodejs12", Tag: odsImageTag},
			{Name: "jenkins-agent-python", Tag: odsImageTag},
			{Name: "jenkins-agent-scala", Tag: odsImageTag},
			// TODO: ods-doc-gen-svc?
			{Name: "ods-provisioning-app", Tag: odsImageTag},
			{Name: "sonarqube", Tag: odsImageTag},
		},
		// TODO should we also test bc and dc's?
		BuildConfigs:      []string{},
		DeploymentConfigs: []string{},
		Services: []string{
			"webhook-proxy",
			"jenkins",
			"sonarqube",
			"nexus",
			"ods-provisioning-app",
			"sonarqube",
		},
		ImageStreams: []string{},
	}

	utils.CheckResources(resourcesInTest, t)

}
