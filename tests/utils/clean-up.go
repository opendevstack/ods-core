package utils

import (
	"fmt"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"path"
	"runtime"
	"time"
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

	err = client.Projects().Delete(projectName, &metav1.DeleteOptions{})
	if err != nil {
		return err
	}
	for {
		time.Sleep(500 * time.Millisecond)
		project, err = client.Projects().Get(projectName, metav1.GetOptions{})
		if err != nil || project == nil {
			break
		}
	}

	return nil
}

func RemoveBuildConfigs(projectName string, buildConfigName string) error {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "deploy")

	RunCommandWithWorkDir("oc", []string{
		"-n", projectName,
		"delete",
		"bc", buildConfigName,
	}, dir, []string{})
	// we need time here - as jenkins needs to sync.
	time.Sleep(20 * time.Second)
	return nil
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

	return nil
}
