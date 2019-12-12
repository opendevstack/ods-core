package utils

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path"
	"runtime"
)

func RunScriptFromBaseDir(command string, envVars ...string) (string, string, error) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..")
	return RunCommand("bash", []string{fmt.Sprintf("%s/%s", dir, command)}, envVars...)
}

func RunCommand(command string, args []string, envVars ...string) (string, string, error) {
	cmd := exec.Command(command, args...)
	cmd.Env = append(os.Environ(), envVars...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return string(stdout.Bytes()), string(stderr.Bytes()), err
}

func RunCommandWithWorkDir(command string, args []string, workDir string, envVars ...string) (string, string, error) {
	cmd := exec.Command(command, args...)
	cmd.Env = append(os.Environ(), envVars...)
	cmd.Dir = workDir
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return string(stdout.Bytes()), string(stderr.Bytes()), err
}
