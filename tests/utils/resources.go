package utils

import (
	coreUtils "github.com/opendevstack/ods-core/tests/utils"
	appsClientV1 "github.com/openshift/client-go/apps/clientset/versioned/typed/apps/v1"
	buildClientV1 "github.com/openshift/client-go/build/clientset/versioned/typed/build/v1"
	imageClientV1 "github.com/openshift/client-go/image/clientset/versioned/typed/image/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"log"
	"testing"
)

func CheckImageTags(namespace string, imageTags []ImageTag, config *rest.Config, t *testing.T) {
	if len(imageTags) == 0 {
		return
	}

	imageClient, err := imageClientV1.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	images, err := imageClient.ImageStreams(namespace).List(metav1.ListOptions{})

	for _, imageTag := range imageTags {
		if err = FindImageTag(images, imageTag); err != nil {
			t.Error(err)
		}
	}
}

func CheckImageStreams(namespace string, imageStreams []string, config *rest.Config, t *testing.T) {

	if len(imageStreams) == 0 {
		return
	}

	imageClient, err := imageClientV1.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	images, err := imageClient.ImageStreams(namespace).List(metav1.ListOptions{})

	for _, imageStream := range imageStreams {
		if err = FindImageStream(images, imageStream); err != nil {
			t.Error(err)
		}
	}
}

func CheckBuildConfigs(namespace string, buildConfigs []string, config *rest.Config, t *testing.T) {

	if len(buildConfigs) == 0 {
		return
	}

	buildClient, err := buildClientV1.NewForConfig(config)
	if err != nil {
		log.Fatal(err)
	}

	buildConfigList, err := buildClient.BuildConfigs(namespace).List(metav1.ListOptions{})
	if err != nil {
		log.Fatal(err)
	}

	for _, buildConfig := range buildConfigs {
		if err = FindBuildConfig(buildConfigList, buildConfig); err != nil {
			t.Error(err)
		}
	}
}

func CheckDeploymentConfigs(namespace string, deploymentConfigs []string, config *rest.Config, t *testing.T) {

	if len(deploymentConfigs) == 0 {
		return
	}

	appsClient, err := appsClientV1.NewForConfig(config)
	if err != nil {
		log.Fatal(err)
	}

	deploymentsConfigs, err := appsClient.DeploymentConfigs(namespace).List(metav1.ListOptions{})
	if err != nil {
		log.Fatal(err)
	}

	for _, deploymentsConfig := range deploymentConfigs {
		if err = FindDeploymentConfig(deploymentsConfigs, deploymentsConfig); err != nil {
			t.Error(err)
		}
	}
}

func CheckServices(namespace string, services []string, config *rest.Config, t *testing.T) {

	if len(services) == 0 {
		return
	}

	clientset, err := kubernetes.NewForConfig(config)

	if err != nil {
		t.Fatal(err)
	}

	serviceClient := clientset.CoreV1().Services(namespace)
	serviceList, err := serviceClient.List(metav1.ListOptions{})

	for _, service := range services {
		if err = FindService(serviceList, service); err != nil {
			t.Error(err)
		}
	}
}

func CheckResources(resources Resources, t *testing.T) {

	config, err := coreUtils.GetOCClient()
	if err != nil {
		t.Fatal(err)
	}

	CheckImageStreams(resources.Namespace, resources.ImageStreams, config, t)
	CheckImageTags(resources.Namespace, resources.ImageTags, config, t)
	CheckBuildConfigs(resources.Namespace, resources.BuildConfigs, config, t)
	CheckDeploymentConfigs(resources.Namespace, resources.DeploymentConfigs, config, t)
	CheckServices(resources.Namespace, resources.Services, config, t)

}
