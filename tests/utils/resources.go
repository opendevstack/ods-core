package utils

import (
	"testing"

	appsClientV1 "github.com/openshift/client-go/apps/clientset/versioned/typed/apps/v1"
	buildClientV1 "github.com/openshift/client-go/build/clientset/versioned/typed/build/v1"
	imageClientV1 "github.com/openshift/client-go/image/clientset/versioned/typed/image/v1"
	routeClientV1 "github.com/openshift/client-go/route/clientset/versioned/typed/route/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
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
	if err != nil {
		t.Error(err)
	}

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
	if err != nil {
		t.Error(err)
	}

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
		t.Error(err)
	}

	buildConfigList, err := buildClient.BuildConfigs(namespace).List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
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
		t.Error(err)
	}

	deploymentsConfigs, err := appsClient.DeploymentConfigs(namespace).List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
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
	if err != nil {
		t.Error(err)
	}

	for _, service := range services {
		if err = FindServiceHasPods(serviceList, service); err != nil {
			t.Error(err)
		}
	}
}

func CheckResources(resources Resources, t *testing.T) {

	config, err := GetOCClient()
	if err != nil {
		t.Fatal(err)
	}

	CheckImageStreams(resources.Namespace, resources.ImageStreams, config, t)
	CheckImageTags(resources.Namespace, resources.ImageTags, config, t)
	CheckBuildConfigs(resources.Namespace, resources.BuildConfigs, config, t)
	CheckDeploymentConfigs(resources.Namespace, resources.DeploymentConfigs, config, t)
	CheckServices(resources.Namespace, resources.Services, config, t)
	CheckRoutes(resources.Namespace, resources.Routes, config, t)
	CheckConfigMaps(resources.Namespace, resources.ConfigMaps, config, t)
	CheckSecrets(resources.Namespace, resources.Secrets, config, t)
	CheckPersistentVolumeClaims(resources.Namespace, resources.PersistentVolumeClaims, config, t)
	CheckServiceAccounts(resources.Namespace, resources.ServiceAccounts, config, t)
	CheckRoleBindings(resources.Namespace, resources.RoleBindings, config, t)

}

func CheckRoutes(namespace string, routes []string, config *rest.Config, t *testing.T) {

	if len(routes) == 0 {
		return
	}

	routeClient, err := routeClientV1.NewForConfig(config)
	if err != nil {
		t.Error(err)
	}

	routeList, err := routeClient.Routes(namespace).List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
	}

	for _, route := range routes {
		if err = FindRoute(routeList, route); err != nil {
			t.Error(err)
		}
	}
}

func CheckConfigMaps(namespace string, configMaps []string, config *rest.Config, t *testing.T) {

	if len(configMaps) == 0 {
		return
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	configMapClient := clientset.CoreV1().ConfigMaps(namespace)
	configMapList, err := configMapClient.List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
	}

	for _, configMap := range configMaps {
		if err = FindConfigMap(configMapList, configMap); err != nil {
			t.Error(err)
		}
	}
}

func CheckSecrets(namespace string, secrets []string, config *rest.Config, t *testing.T) {

	if len(secrets) == 0 {
		return
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	secretClient := clientset.CoreV1().Secrets(namespace)
	secretList, err := secretClient.List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
	}

	for _, secret := range secrets {
		if err = FindSecret(secretList, secret); err != nil {
			t.Error(err)
		}
	}
}

func CheckPersistentVolumeClaims(namespace string, pvcs []string, config *rest.Config, t *testing.T) {

	if len(pvcs) == 0 {
		return
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	pvcClient := clientset.CoreV1().PersistentVolumeClaims(namespace)
	pvcList, err := pvcClient.List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
	}

	for _, pvc := range pvcs {
		if err = FindPersistentVolumeClaim(pvcList, pvc); err != nil {
			t.Error(err)
		}
	}
}

func CheckServiceAccounts(namespace string, serviceAccounts []string, config *rest.Config, t *testing.T) {

	if len(serviceAccounts) == 0 {
		return
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	serviceAccountClient := clientset.CoreV1().ServiceAccounts(namespace)
	serviceAccountList, err := serviceAccountClient.List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
	}

	for _, serviceAccount := range serviceAccounts {
		if err = FindServiceAccount(serviceAccountList, serviceAccount); err != nil {
			t.Error(err)
		}
	}
}

func CheckRoleBindings(namespace string, roleBindings []string, config *rest.Config, t *testing.T) {

	if len(roleBindings) == 0 {
		return
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	rbacClient := clientset.RbacV1()
	roleBindingList, err := rbacClient.RoleBindings(namespace).List(metav1.ListOptions{})
	if err != nil {
		t.Error(err)
	}

	for _, roleBinding := range roleBindings {
		if err = FindRoleBindingByName(roleBindingList, roleBinding); err != nil {
			t.Error(err)
		}
	}
}
