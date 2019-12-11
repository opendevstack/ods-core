package create_projects

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"runtime"
	"testing"
)

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
}
