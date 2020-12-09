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
			{Name: "jenkins-agent-nodejs12", Tag: odsImageTag},
			{Name: "jenkins-agent-python", Tag: odsImageTag},
			{Name: "jenkins-agent-scala", Tag: odsImageTag},
			{Name: "ods-doc-gen-svc", Tag: odsImageTag},
			{Name: "ods-provisioning-app", Tag: odsImageTag},
			{Name: "sonarqube", Tag: odsImageTag},
		},
		BuildConfigs:      []string{},
		DeploymentConfigs: []string{},
		Services:          []string{}, // tested in its own test.
		ImageStreams:      []string{},
	}

	utils.CheckResources(resourcesInTest, t)

}
