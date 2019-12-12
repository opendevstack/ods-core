package utils

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path"
	"runtime"
)

func RunCommandFromBaseDir(command string, envVars ...string) (string, string, error) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..")
	cmd := exec.Command("sh", fmt.Sprintf("%s/%s", dir, command))
	cmd.Env = append(os.Environ(), envVars...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return string(stdout.Bytes()), string(stderr.Bytes()), err
}
