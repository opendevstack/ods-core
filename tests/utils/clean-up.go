package utils

import (
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"time"
)

func RemoveProject(projectName string) error {
	config, err := GetOCClient()
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
