package steps

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
)

// deleteOpenShiftResources deletes all OpenShift resources with the app label
func deleteOpenShiftResources(projectID string, componentID string, namespace string) error {
	// Check if resources should be kept
	if os.Getenv("KEEP_RESOURCES") == "true" {
		logger.Warn(fmt.Sprintf("KEEP_RESOURCES=true: Skipping cleanup for component: %s in namespace: %s", componentID, namespace))
		return nil
	}
	logger.Running(fmt.Sprintf("Cleanup for component: %s in namespace: %s", componentID, namespace))
	label := fmt.Sprintf("app=%s-%s", projectID, componentID)
	logger.Debug(fmt.Sprintf("Delete resources labelled with: %s", label))
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

	logger.Success(fmt.Sprintf("Cleaned up resources with label: %s", label))
	return nil
}

// deleteOpenShiftResourceByName deletes a specific OpenShift resource by name
func deleteOpenShiftResourceByName(resourceType string, resourceName string, namespace string) error {
	// Check if resources should be kept
	if os.Getenv("KEEP_RESOURCES") == "true" {
		logger.Warn(fmt.Sprintf("KEEP_RESOURCES=true: Skipping cleanup for resource: %s/%s in namespace: %s", resourceType, resourceName, namespace))
		return nil
	}
	logger.Running(fmt.Sprintf("Cleanup for resource: %s/%s in %s", resourceType, resourceName, namespace))
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

	logger.Success(fmt.Sprintf("Cleaned up resource: %s", resource))
	return nil
}

// deleteHelmRelease deletes a Helm release
func deleteHelmRelease(releaseName string, namespace string) error {
	// Check if resources should be kept
	if os.Getenv("KEEP_RESOURCES") == "true" {
		logger.Warn(fmt.Sprintf("KEEP_RESOURCES=true: Skipping cleanup for Helm release: %s in namespace: %s", releaseName, namespace))
		return nil
	}
	logger.Waiting(fmt.Sprintf("Checking for Helm release: %s in %s", releaseName, namespace))

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
		logger.Info(fmt.Sprintf("Helm release %s not found, skipping cleanup", releaseName))
		return nil
	}

	logger.Running(fmt.Sprintf("Cleanup for Helm release: %s", releaseName))

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

	logger.Success(fmt.Sprintf("Cleaned up Helm release: %s", releaseName))
	return nil
}

// runOcCmd executes an oc command
func runOcCmd(args []string) (string, string, error) {
	cmd := exec.Command("oc", args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return stdout.String(), stderr.String(), err
}

// runHelmCmd executes a helm command
func runHelmCmd(args []string) (string, string, error) {
	cmd := exec.Command("helm", args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return stdout.String(), stderr.String(), err
}
