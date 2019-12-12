package create_projects

import (
	"github.com/opendevstack/ods-core/tests/utils"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"path/filepath"
	"testing"
)

func RemoveAllOCProjects(t *testing.T) {

	home, err := os.UserHomeDir()
	if err != nil {
		t.Fatalf("Cannot find home directory: %s", err)
	}
	config, err := clientcmd.BuildConfigFromFlags("", filepath.Join(home, ".kube", "config"))
	if err != nil {
		t.Fatalf("Cannot load cluster configuration: %s", err)
	}
	client, err := projectClientV1.NewForConfig(config)
	if err != nil {
		t.Fatalf("Cannot initialize Project Client: %s", err)
	}

	_ = client.Projects().Delete(utils.PROJECT_NAME_CD, &metav1.DeleteOptions{})
	_ = client.Projects().Delete(utils.PROJECT_NAME_TEST, &metav1.DeleteOptions{})
	_ = client.Projects().Delete(utils.PROJECT_NAME_DEV, &metav1.DeleteOptions{})

	for {
		project, err := client.Projects().Get(utils.PROJECT_NAME_DEV, metav1.GetOptions{})
		if err != nil || project == nil {
			break
		}
	}
}
