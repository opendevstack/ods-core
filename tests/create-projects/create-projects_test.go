package create_projects

import (
	"fmt"
	"github.com/opendevstack/ods-core/tests/utils"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	rbacv1client "k8s.io/client-go/kubernetes/typed/rbac/v1"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"path/filepath"
	"testing"
)

func TestCreateProjectWithoutProjectId(t *testing.T) {
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{})
	if err == nil {
		t.Fatalf(
			"Execution of `create-project.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateProject(t *testing.T) {
	RemoveAllOCProjects(t)
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{}, utils.PROJECT_ENV_VAR)
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
		t.Fatal("CD Project not found")
	}
	if !foundTest {
		t.Fatal("Test Project not found")
	}
	if !foundDev {
		t.Fatal("Dev Project not found")
	}

	rbacV1Client, err := rbacv1client.NewForConfig(config)
	if err != nil {
		t.Fatalf("Cannot initialize RBAC Client: %s", err)
	}
	roleBindings, _ := rbacV1Client.RoleBindings(utils.PROJECT_NAME_CD).List(metav1.ListOptions{})

	if !utils.FindRoleBinding(roleBindings, "jenkins", "ServiceAccount", utils.PROJECT_NAME_CD, "edit") {
		t.Fatal("Service Account 'jenkins' does not have the role 'edit' in CD project")
	}
	if !utils.FindRoleBinding(roleBindings, "default", "ServiceAccount", utils.PROJECT_NAME_CD, "edit") {
		t.Fatal("Service Account 'default' does not have the role 'edit' in CD project")
	}

	if !utils.FindRoleBinding(roleBindings, fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_DEV), "Group", "", "system:image-puller") {
		t.Fatal("Service Account 'default' does not have the role 'edit' in CD project")
	}

	if !utils.FindRoleBinding(roleBindings, fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_TEST), "Group", "", "system:image-puller") {
		t.Fatal("Service Account 'default' does not have the role 'edit' in CD project")
	}

	roleBindings, _ = rbacV1Client.RoleBindings(utils.PROJECT_NAME_DEV).List(metav1.ListOptions{})
	if !utils.FindRoleBinding(roleBindings, "default", "ServiceAccount", utils.PROJECT_NAME_DEV, "system:image-builder") {
		t.Fatal("Service Account 'default' does not have the role 'system:image-builder' in DEV project")
	}

	if !utils.FindRoleBinding(roleBindings, fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_TEST), "Group", "", "system:image-puller") {
		t.Fatal("Service Account 'default' does not have the role 'edit' in CD project")
	}

	if !utils.FindRoleBinding(roleBindings, "jenkins", "ServiceAccount", utils.PROJECT_NAME_CD, "admin") {
		t.Fatal("Service Account 'jenkins' does not have the role 'edit' in CD project")
	}

	roleBindings, _ = rbacV1Client.RoleBindings(utils.PROJECT_NAME_TEST).List(metav1.ListOptions{})
	if !utils.FindRoleBinding(roleBindings, "default", "ServiceAccount", utils.PROJECT_NAME_TEST, "system:image-builder") {
		t.Fatal("Service Account 'default' does not have the role 'system:image-builder' in TEST project")
	}

	if !utils.FindRoleBinding(roleBindings, "jenkins", "ServiceAccount", utils.PROJECT_NAME_CD, "admin") {
		t.Fatal("Service Account 'jenkins' does not have the role 'edit' in CD project")
	}

	t.Log("WARNING: Seeding special and default permission groups is not tested yet!")

}
