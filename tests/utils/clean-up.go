package utils

import (
	"fmt"
	"path"
	"runtime"
	"time"

	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func RemoveProject(projectName string) error {
	config, err := GetOCClient()
	if err != nil {
		return err
	}
	client, err := projectClientV1.NewForConfig(config)
	if err != nil {
		return err
	}
	project, err := client.Projects().Get(projectName, metav1.GetOptions{})
	if err != nil || project == nil {
		return nil
	}

	stdout, stderr, err := RemoveProjectWait(projectName)
	if err != nil {
		fmt.Printf("Could not delete project %s, %s, %s - err:%s\n", projectName, stdout, stderr, err)
	} else {
		fmt.Printf("project %s deleted - %s\n", projectName, stdout)
	}
	return nil
}

func RemoveBuildConfigs(projectName string, buildConfigName string) error {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "deploy")

	_, _, err := RunCommandWithWorkDir("oc", []string{
		"-n", projectName,
		"delete",
		"bc", buildConfigName,
	}, dir, []string{})
	if err != nil {
		return err
	}
	// we need time here - as jenkins needs to sync.
	time.Sleep(20 * time.Second)
	return nil
}

func RemoveProjectWait(projectName string) (string, string, error) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "deploy")

	stdout, stderr, err := RunCommandWithWorkDir("oc", []string{
		"delete", "project", projectName,
		"--wait=true", "--now=true",
	}, dir, []string{})
	if err != nil {
		return stdout, stderr, err
	}

	return stdout, stderr, nil
}

func RemoveAllTestOCProjects() error {

	err := RemoveProject(PROJECT_NAME_TEST)
	if err != nil {
		return err
	}
	err = RemoveProject(PROJECT_NAME_DEV)
	if err != nil {
		return err
	}
	err = RemoveProject(PROJECT_NAME_CD)
	if err != nil {
		return err
	}
	time.Sleep(20 * time.Second)

	return nil
}

func RemoveAllOpenshiftNamespacesForProject(project string) error {

	err := RemoveProject(fmt.Sprintf("%s-test", project))
	if err != nil {
		return err
	}
	err = RemoveProject(fmt.Sprintf("%s-dev", project))
	if err != nil {
		return err
	}
	err = RemoveProject(fmt.Sprintf("%s-cd", project))
	if err != nil {
		return err
	}
	time.Sleep(20 * time.Second)

	return nil
}
