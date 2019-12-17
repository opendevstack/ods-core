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
    stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{})
    if err == nil {
        t.Fatalf(
            "Execution of `create-project.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
            stdout,
            stderr)
    }
}

func TestCreateProject(t *testing.T) {
    _ = utils.RemoveAllTestOCProjects()
    stdout, stderr, err := utils.RunScriptFromBaseDir("create-projects/create-projects.sh", []string{}, utils.PROJECT_ENV_VAR)
    if err != nil {
        t.Fatalf(
            "Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
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

    if err = utils.FindProject(projects, utils.PROJECT_NAME_CD); err != nil {
        t.Fatal(err)
    }
    if err = utils.FindProject(projects, utils.PROJECT_NAME_TEST); err != nil {
        t.Fatal(err)
    }
    if err = utils.FindProject(projects, utils.PROJECT_NAME_DEV); err != nil {
        t.Fatal(err)
    }

    rbacV1Client, err := rbacv1client.NewForConfig(config)
    if err != nil {
        t.Fatalf("Cannot initialize RBAC Client: %s", err)
    }
    roleBindings, _ := rbacV1Client.RoleBindings(utils.PROJECT_NAME_CD).List(metav1.ListOptions{})

    if err = utils.FindRoleBinding(roleBindings, "jenkins", "ServiceAccount", utils.PROJECT_NAME_CD, "edit"); err != nil {
        t.Fatal(err)
    }
    if err = utils.FindRoleBinding(roleBindings, "default", "ServiceAccount", utils.PROJECT_NAME_CD, "edit"); err != nil {
        t.Fatal(err)
    }

    if err = utils.FindRoleBinding(roleBindings, fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_DEV), "Group", "", "system:image-puller"); err != nil {
        t.Fatal(err)
    }

    if err = utils.FindRoleBinding(roleBindings, fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_TEST), "Group", "", "system:image-puller"); err != nil {
        t.Fatal(err)
    }

    roleBindings, _ = rbacV1Client.RoleBindings(utils.PROJECT_NAME_DEV).List(metav1.ListOptions{})
    if err = utils.FindRoleBinding(roleBindings, "default", "ServiceAccount", utils.PROJECT_NAME_DEV, "system:image-builder"); err != nil {
        t.Fatal(err)
    }

    if err = utils.FindRoleBinding(roleBindings, fmt.Sprintf("system:serviceaccounts:%s", utils.PROJECT_NAME_TEST), "Group", "", "system:image-puller"); err != nil {
        t.Fatal(err)
    }

    if err = utils.FindRoleBinding(roleBindings, "jenkins", "ServiceAccount", utils.PROJECT_NAME_CD, "admin"); err != nil {
        t.Fatal(err)
    }

    roleBindings, _ = rbacV1Client.RoleBindings(utils.PROJECT_NAME_TEST).List(metav1.ListOptions{})
    if err = utils.FindRoleBinding(roleBindings, "default", "ServiceAccount", utils.PROJECT_NAME_TEST, "system:image-builder"); err != nil {
        t.Fatal(err)
    }

    if err = utils.FindRoleBinding(roleBindings, "jenkins", "ServiceAccount", utils.PROJECT_NAME_CD, "admin"); err != nil {
        t.Fatal(err)
    }

    t.Log("WARNING: Seeding special and default permission groups is not tested yet!")

}
