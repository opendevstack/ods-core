package create_projects

import (
    "fmt"
    projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
    "gotest.tools/assert"
    meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/tools/clientcmd"
    "os"
    "os/exec"
    "path"
    "path/filepath"
    "runtime"
    "testing"
)

func homeDir() string {
    if h := os.Getenv("HOME"); h != "" {
        return h
    }
    return os.Getenv("USERPROFILE") // windows
}

func TestCreateProjectWithoutProjectId(t *testing.T) {
    _, filename, _, _ := runtime.Caller(0)
    dir := path.Join(path.Dir(filename), "..", "..")
    cmd := exec.Command("sh", fmt.Sprintf("%s/create-projects/create-projects.sh", dir))
    out, err := cmd.CombinedOutput()
    if err == nil {
        t.Errorf("Execution of `create-project.sh` must fail if no PROJECT_ID is set: %s", out)
    }
}

func TestCreateProject(t *testing.T) {
    _, filename, _, _ := runtime.Caller(0)
    dir := path.Join(path.Dir(filename), "..", "..")
    cmd := exec.Command("sh", fmt.Sprintf("%s/create-projects/create-projects.sh", dir))
    cmd.Env = append(os.Environ(), "PROJECT_ID=unitt")
    out, err := cmd.CombinedOutput()
    if err != nil {
        t.Errorf("Execution of `create-project.sh` failed: %s\n%s", err.Error(), out)
    }
    config, err := clientcmd.BuildConfigFromFlags("", filepath.Join(homeDir(), ".kube", "config"))
    if err != nil {
        t.Errorf("Cannot load cluster configuration: %s", err.Error())
    }
    client, err := projectClientV1.NewForConfig(config)
    if err != nil {
        t.Errorf("Cannot initialize Project Client: %s", err.Error())
    }
    projects, err := client.Projects().List(meta_v1.ListOptions{})
    if err != nil {
        t.Errorf("Cannot list projects: %s", err.Error())
    }

    foundCd := false
    foundTest := false
    foundDev := false

    for _, project := range projects.Items {
        switch project.Name {
        case "unitt-cd":
            foundCd = true
        case "unitt-test":
            foundTest = true
        case "unitt-dev":
            foundDev = true
        default:

        }
    }

    assert.Equal(t, true, foundCd, "CD Project not found")
    assert.Equal(t, true, foundDev, "Test Project not found")
    assert.Equal(t, true, foundTest, "Dev Project not found")

}
