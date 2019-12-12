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

func TestCreateProjectWithoutProjectId(t *testing.T) {
	stdout, stderr, err := utils.RunCommandFromBaseDir("create-projects/create-projects.sh")
	if err == nil {
		t.Fatalf(
			"Execution of `create-project.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateProject(t *testing.T) {
	stdout, stderr, err := utils.RunCommandFromBaseDir("create-projects/create-projects.sh", utils.PROJECT_ENV_VAR)
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
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

	projects, err := client.Projects().List(metav1.ListOptions{})
	if err != nil {
		t.Fatalf("Cannot list projects: %s", err)
	}

	foundCd := false
	foundTest := false
	foundDev := false

	for _, project := range projects.Items {
		switch project.Name {
		case utils.PROJECT_NAME_CD:
			foundCd = true
		case utils.PROJECT_NAME_TEST:
			foundTest = true
		case utils.PROJECT_NAME_DEV:
			foundDev = true
		default:

		}
	}

	if !foundCd {
		t.Error("CD Project not found")
	} else {
		_ = client.Projects().Delete(utils.PROJECT_NAME_CD, &metav1.DeleteOptions{})
	}
	if !foundTest {
		t.Error("Test Project not found")
		_ = client.Projects().Delete(utils.PROJECT_NAME_TEST, &metav1.DeleteOptions{})
	}
	if !foundDev {
		t.Error("Dev Project not found")
		_ = client.Projects().Delete(utils.PROJECT_NAME_DEV, &metav1.DeleteOptions{})
	}
}
