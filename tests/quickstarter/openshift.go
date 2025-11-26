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

func deleteOpenShiftResourceByName(resourceType string, resourceName string, namespace string) error {
	fmt.Printf("-- starting cleanup for resource: %s/%s in %s\n", resourceType, resourceName, namespace)
	resource := fmt.Sprintf("%s/%s", resourceType, resourceName)

	stdout, stderr, err := runOcCmd([]string{
		"-n", namespace,
		"delete", resource,
	})

	if err != nil {
		return fmt.Errorf(
			"Could not delete resource %s: \nStdOut: %s\nStdErr: %s\n\nErr: %w",
			resource,
			stdout,
			stderr,
			err,
		)
	}

	fmt.Printf("-- cleaned up resource: %s\n", resource)
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

func deleteHelmRelease(releaseName string, namespace string) error {
	fmt.Printf("-- checking for Helm release: %s in %s\n", releaseName, namespace)

	// Check if the release exists
	stdout, stderr, err := runHelmCmd([]string{
		"list",
		"-n", namespace,
		"-q",              // quiet output, just release names
		"-f", releaseName, // filter by release name
	})

	if err != nil {
		return fmt.Errorf(
			"Could not list Helm releases in %s: \nStdOut: %s\nStdErr: %s\n\nErr: %w",
			namespace,
			stdout,
			stderr,
			err,
		)
	}

	// If the release doesn't exist, skip cleanup
	if stdout == "" || len(bytes.TrimSpace([]byte(stdout))) == 0 {
		fmt.Printf("-- Helm release %s not found, skipping cleanup\n", releaseName)
		return nil
	}

	fmt.Printf("-- starting cleanup for Helm release: %s\n", releaseName)

	stdout, stderr, err = runHelmCmd([]string{
		"uninstall", releaseName,
		"-n", namespace,
	})

	if err != nil {
		return fmt.Errorf(
			"Could not delete Helm release %s: \nStdOut: %s\nStdErr: %s\n\nErr: %w",
			releaseName,
			stdout,
			stderr,
			err,
		)
	}

	fmt.Printf("-- cleaned up Helm release: %s\n", releaseName)
	return nil
}

func runHelmCmd(args []string) (string, string, error) {
	cmd := exec.Command("helm", args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return stdout.String(), stderr.String(), err
}
