package validate

import (
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
	v1 "github.com/openshift/api/project/v1"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// OdsProjectExistsOrFail checks that project exists or fails
func OdsProjectExistsOrFail(t *testing.T, project string) *v1.Project {
	config, err := utils.GetOCClient()
	if err != nil {
		t.Fatalf("Error creating OC config: %s", err)
	}
	client, err := projectClientV1.NewForConfig(config)
	if err != nil {
		t.Fatalf("Error creating Project client: %s", err)
	}
	v1Project, err := client.Projects().Get(project, metav1.GetOptions{})
	if err != nil {
		t.Fatalf("Cannot get project %s: %s", project, err)
	}
	return v1Project
}
