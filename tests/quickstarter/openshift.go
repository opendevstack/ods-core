package quickstarter

import (
	"bytes"
	"fmt"
	"os/exec"
)

func deleteOpenShiftResources(projectID string, componentID string, namespace string) error {
	fmt.Printf("-- starting cleanup for component: %s\n", componentID)
	label := fmt.Sprintf("app=%s-%s", projectID, componentID)
	fmt.Printf("-- delete resources labelled with: %s\n", label)
	stdout, stderr, err := runOcCmd([]string{
		"-n", namespace,
		"delete", "all", "-l", label,
	})
	if err != nil {
		return fmt.Errorf(
			"Could not delete all resources labelled with %s: \nStdOut: %s\nStdErr: %s\n\nErr: %w",
			label,
			stdout,
			stderr,
			err,
		)
	}

	fmt.Printf("-- cleaned up resources with label: %s\n", label)
	return nil
}

func runOcCmd(args []string) (string, string, error) {
	cmd := exec.Command("oc", args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return stdout.String(), stderr.String(), err
}
