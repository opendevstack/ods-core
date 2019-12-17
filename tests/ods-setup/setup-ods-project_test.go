package ods_setup

import (
	"fmt"
	"github.com/opendevstack/ods-core/tests/utils"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	rbacv1client "k8s.io/client-go/kubernetes/typed/rbac/v1"
	"testing"
)

func TestCreateOdsProject(t *testing.T) {
	namespace := "ods"
	_ = utils.RemoveProject(namespace)
	stdout, stderr, err := utils.RunScriptFromBaseDir("ods-setup/setup-ods-project.sh", []string{
		"--force",
		"--verbose",
		"--namespace",
		namespace,
	})
	if err == nil {
		t.Fatalf(
			"Execution of `setup-ods-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}

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

	if !utils.FindProject(projects, namespace) {
		t.Fatalf("'%s' Project not found", namespace)
	}
	rbacV1Client, err := rbacv1client.NewForConfig(config)
	if err != nil {
		t.Fatalf("Cannot initialize RBAC Client: %s", err)
	}

	roleBindings, _ := rbacV1Client.RoleBindings(namespace).List(metav1.ListOptions{})
	if !utils.FindRoleBinding(roleBindings, "system:authenticated", "Group", "", "system:image-puller") {
		t.Fatal("Service Account 'default' does not have the role 'system:image-builder' in TEST project")
	}

	if !utils.FindRoleBinding(roleBindings, "system:authenticated", "Group", "", "view") {
		t.Fatal("Service Account 'default' does not have the role 'system:image-builder' in TEST project")
	}

	if !utils.FindRoleBinding(roleBindings, "system:authenticated", "Group", "", "view") {
		t.Fatal("Service Account 'default' does not have the role 'system:image-builder' in TEST project")
	}

	clusterRoleBindings, _ := rbacV1Client.ClusterRoleBindings().List(metav1.ListOptions{})
	if !utils.FindClusterRoleBinding(clusterRoleBindings, fmt.Sprintf("system:serviceaccount:%s:deployment", namespace), "ServiceAccount", namespace, "cluster-admin") {
		t.Fatal("Service Account 'default' does not have the role 'system:image-builder' in TEST project")
	}

}

func TestCreateDefaultOdsProject(t *testing.T) {
	namespace := "cd"
	_ = utils.RemoveProject(namespace)
	stdout, stderr, err := utils.RunScriptFromBaseDir("ods-setup/setup-ods-project.sh", []string{
		"--force",
		"--verbose",
	})
	if err == nil {
		t.Fatalf(
			"Execution of `setup-ods-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}

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

	if !utils.FindProject(projects, namespace) {
		t.Fatalf("'%s' Project not found", namespace)
	}

}
