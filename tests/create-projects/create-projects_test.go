package create_projects

import (
	"bytes"
	"fmt"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"runtime"
	"testing"
)

func TestCreateProjectWithoutProjectId(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..")

	cmd := exec.Command("sh", fmt.Sprintf("%s/create-projects/create-projects.sh", dir))
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err == nil {
		t.Fatalf(
			"Execution of `create-project.sh` must fail if no PROJECT_ID is set: \nStdOut: %s\nStdErr: %s",
			string(stdout.Bytes()),
			string(stderr.Bytes()))
	}
}

func TestCreateProject(t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..")
	cmd := exec.Command("sh", fmt.Sprintf("%s/create-projects/create-projects.sh", dir))
	cmd.Env = append(os.Environ(), "PROJECT_ID=unitt")
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		t.Fatalf(
			"Execution of `create-project.sh` failed: \nStdOut: %s\nStdErr: %s",
			string(stdout.Bytes()),
			string(stderr.Bytes()))
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
		case "unitt-cd":
			foundCd = true
		case "unitt-test":
			foundTest = true
		case "unitt-dev":
			foundDev = true
		default:

		}
	}
	if !foundCd {
		t.Error("CD Project not found")
	}
	if !foundTest {
		t.Error("Test Project not found")
	}
	if !foundDev {
		t.Error("Dev Project not found")
	}
}
