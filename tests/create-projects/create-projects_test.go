package create_projects

import (
	"fmt"
	"github.com/opendevstack/ods-core/tests/utils"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	rbacv1client "k8s.io/client-go/kubernetes/typed/rbac/v1"
	"testing"
)

func TestCreateProjectWithoutProjectId(t *testing.T) {
	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{}, []string{})
	if err == nil {
		t.Fatalf(
			"Execution of `create-project.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}

func TestCreateProject(t *testing.T) {
	err := utils.RemoveAllTestOCProjects()
	if err != nil {
		t.Fatal("Unable to remove test projects")
	}

	stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{}, []string{utils.PROJECT_ENV_VAR})
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
	CheckProjectSetup(t)

}

func CheckProjectSetup(t *testing.T) {
	config, err := utils.GetOCClient()
	if err != nil {
		t.Fatalf("Error creating OC config: %s", err)
	}
	client, err := projectClientV1.NewForConfig(config)
	if err != nil {
		t.Fatalf("Error creating Project client: %s", err)
	}
	projects, err := client.Projects().List(metav1.ListOptions{})
	if err != nil {
		t.Fatalf("Cannot list projects: %s", err)
	}
	expectedProjects := []string{utils.PROJECT_NAME_CD, utils.PROJECT_NAME_TEST, utils.PROJECT_NAME_DEV}
	for _, expectedProject := range expectedProjects {
		if err = utils.FindProject(projects, expectedProject); err != nil {
			t.Fatal(err)
		}
	}
	rbacV1Client, err := rbacv1client.NewForConfig(config)
	if err != nil {
		t.Fatalf("Cannot initialize RBAC Client: %s", err)
	}
	roleBindings, _ := rbacV1Client.RoleBindings(utils.PROJECT_NAME_CD).List(metav1.ListOptions{})
	expectedRoleBindings := []utils.RoleBinding{
		{
			SubjectName: "jenkins",
			SubjectType: "ServiceAccount",
			Namespace:   utils.PROJECT_NAME_CD,
			RoleName:    "edit",
		},
		{
			SubjectName: fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_DEV),
			SubjectType: "Group",
			Namespace:   "",
			RoleName:    "system:image-puller",
		},
		{
			SubjectName: fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_TEST),
			SubjectType: "Group",
			Namespace:   "",
			RoleName:    "system:image-puller",
		},
	}
	for _, expectedRoleBinding := range expectedRoleBindings {
		if err = utils.FindRoleBinding(roleBindings, expectedRoleBinding.SubjectName, expectedRoleBinding.SubjectType, expectedRoleBinding.Namespace, expectedRoleBinding.RoleName); err != nil {
			t.Error(err)
		}
	}
	roleBindings, _ = rbacV1Client.RoleBindings(utils.PROJECT_NAME_DEV).List(metav1.ListOptions{})
	expectedRoleBindings = []utils.RoleBinding{
		{
			SubjectName: "default",
			SubjectType: "ServiceAccount",
			Namespace:   utils.PROJECT_NAME_DEV,
			RoleName:    "system:image-builder",
		}, {
			SubjectName: fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_TEST),
			SubjectType: "Group",
			Namespace:   "",
			RoleName:    "system:image-puller",
		}, {
			SubjectName: "jenkins",
			SubjectType: "ServiceAccount",
			Namespace:   utils.PROJECT_NAME_CD,
			RoleName:    "admin",
		},
	}
	for _, expectedRoleBinding := range expectedRoleBindings {
		if err = utils.FindRoleBinding(roleBindings, expectedRoleBinding.SubjectName, expectedRoleBinding.SubjectType, expectedRoleBinding.Namespace, expectedRoleBinding.RoleName); err != nil {
			t.Error(err)
		}
	}
	roleBindings, _ = rbacV1Client.RoleBindings(utils.PROJECT_NAME_TEST).List(metav1.ListOptions{})
	expectedRoleBindings = []utils.RoleBinding{
		{
			SubjectName: "default",
			SubjectType: "ServiceAccount",
			Namespace:   utils.PROJECT_NAME_TEST,
			RoleName:    "system:image-builder",
		}, {
			SubjectName: "jenkins",
			SubjectType: "ServiceAccount",
			Namespace:   utils.PROJECT_NAME_CD,
			RoleName:    "admin",
		},
	}
	for _, expectedRoleBinding := range expectedRoleBindings {
		if err = utils.FindRoleBinding(roleBindings, expectedRoleBinding.SubjectName, expectedRoleBinding.SubjectType, expectedRoleBinding.Namespace, expectedRoleBinding.RoleName); err != nil {
			t.Error(err)
		}
	}
	fmt.Printf("WARNING: Seeding special and default permission groups is not tested yet!")
}
