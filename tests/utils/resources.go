package utils

import (
	"testing"

	appsClientV1 "github.com/openshift/client-go/apps/clientset/versioned/typed/apps/v1"
	buildClientV1 "github.com/openshift/client-go/build/clientset/versioned/typed/build/v1"
	imageClientV1 "github.com/openshift/client-go/image/clientset/versioned/typed/image/v1"
	routeClientV1 "github.com/openshift/client-go/route/clientset/versioned/typed/route/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	unstructured "k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/client-go/dynamic"
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

func CheckServices(namespace string, services []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, services, dyn, schema.GroupVersionResource{Group: "", Version: "v1", Resource: "services"}, nil, t)
}

func CheckResources(resources Resources, t *testing.T) {

	config, err := GetOCClient()
	if err != nil {
		t.Fatal(err)
	}

	dyn, err := dynamic.NewForConfig(config)
	if err != nil {
		t.Fatal(err)
	}

	CheckImageStreams(resources.Namespace, resources.ImageStreams, config, t)
	CheckImageTags(resources.Namespace, resources.ImageTags, config, t)
	CheckBuildConfigs(resources.Namespace, resources.BuildConfigs, config, t)
	CheckDeploymentConfigs(resources.Namespace, resources.DeploymentConfigs, config, t)
	CheckDeployments(resources.Namespace, resources.Deployments, dyn, t)
	CheckStatefulSets(resources.Namespace, resources.StatefulSets, dyn, t)
	CheckDaemonSets(resources.Namespace, resources.DaemonSets, dyn, t)
	CheckReplicaSets(resources.Namespace, resources.ReplicaSets, dyn, t)
	CheckServices(resources.Namespace, resources.Services, dyn, t)
	CheckRoutes(resources.Namespace, resources.Routes, config, t)
	CheckIngresses(resources.Namespace, resources.Ingresses, dyn, t)
	CheckConfigMaps(resources.Namespace, resources.ConfigMaps, dyn, t)
	CheckSecrets(resources.Namespace, resources.Secrets, dyn, t)
	CheckPersistentVolumeClaims(resources.Namespace, resources.PersistentVolumeClaims, dyn, t)
	CheckServiceAccounts(resources.Namespace, resources.ServiceAccounts, dyn, t)
	CheckRoles(resources.Namespace, resources.Roles, dyn, t)
	CheckRoleBindings(resources.Namespace, resources.RoleBindings, dyn, t)
	CheckNetworkPolicies(resources.Namespace, resources.NetworkPolicies, dyn, t)
	CheckJobs(resources.Namespace, resources.Jobs, dyn, t)
	CheckCronJobs(resources.Namespace, resources.CronJobs, dyn, t)
	CheckPods(resources.Namespace, resources.Pods, dyn, t)
	CheckHorizontalPodAutoscalers(resources.Namespace, resources.HorizontalPodAutoscalers, dyn, t)

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

func CheckConfigMaps(namespace string, configMaps []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, configMaps, dyn, schema.GroupVersionResource{Group: "", Version: "v1", Resource: "configmaps"}, nil, t)
}

func CheckSecrets(namespace string, secrets []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, secrets, dyn, schema.GroupVersionResource{Group: "", Version: "v1", Resource: "secrets"}, nil, t)
}

func CheckPersistentVolumeClaims(namespace string, pvcs []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, pvcs, dyn, schema.GroupVersionResource{Group: "", Version: "v1", Resource: "persistentvolumeclaims"}, nil, t)
}

func CheckServiceAccounts(namespace string, serviceAccounts []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, serviceAccounts, dyn, schema.GroupVersionResource{Group: "", Version: "v1", Resource: "serviceaccounts"}, nil, t)
}

func CheckRoleBindings(namespace string, roleBindings []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, roleBindings, dyn, schema.GroupVersionResource{Group: "rbac.authorization.k8s.io", Version: "v1", Resource: "rolebindings"}, nil, t)
}

func CheckCronJobs(namespace string, cronJobs []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(
		namespace,
		cronJobs,
		dyn,
		schema.GroupVersionResource{Group: "batch", Version: "v1", Resource: "cronjobs"},
		[]schema.GroupVersionResource{{Group: "batch", Version: "v1beta1", Resource: "cronjobs"}},
		t,
	)
}

func CheckDeployments(namespace string, deployments []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, deployments, dyn, schema.GroupVersionResource{Group: "apps", Version: "v1", Resource: "deployments"}, nil, t)
}

func CheckStatefulSets(namespace string, statefulSets []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, statefulSets, dyn, schema.GroupVersionResource{Group: "apps", Version: "v1", Resource: "statefulsets"}, nil, t)
}

func CheckDaemonSets(namespace string, daemonSets []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, daemonSets, dyn, schema.GroupVersionResource{Group: "apps", Version: "v1", Resource: "daemonsets"}, nil, t)
}

func CheckReplicaSets(namespace string, replicaSets []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, replicaSets, dyn, schema.GroupVersionResource{Group: "apps", Version: "v1", Resource: "replicasets"}, nil, t)
}

func CheckIngresses(namespace string, ingresses []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(
		namespace,
		ingresses,
		dyn,
		schema.GroupVersionResource{Group: "networking.k8s.io", Version: "v1", Resource: "ingresses"},
		[]schema.GroupVersionResource{
			{Group: "networking.k8s.io", Version: "v1beta1", Resource: "ingresses"},
			{Group: "extensions", Version: "v1beta1", Resource: "ingresses"},
		},
		t,
	)
}

func CheckRoles(namespace string, roles []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, roles, dyn, schema.GroupVersionResource{Group: "rbac.authorization.k8s.io", Version: "v1", Resource: "roles"}, nil, t)
}

func CheckNetworkPolicies(namespace string, networkPolicies []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, networkPolicies, dyn, schema.GroupVersionResource{Group: "networking.k8s.io", Version: "v1", Resource: "networkpolicies"}, nil, t)
}

func CheckJobs(namespace string, jobs []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, jobs, dyn, schema.GroupVersionResource{Group: "batch", Version: "v1", Resource: "jobs"}, nil, t)
}

func CheckPods(namespace string, pods []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, pods, dyn, schema.GroupVersionResource{Group: "", Version: "v1", Resource: "pods"}, nil, t)
}

func CheckHorizontalPodAutoscalers(namespace string, hpas []string, dyn dynamic.Interface, t *testing.T) {
	checkResourceNamesDynamic(namespace, hpas, dyn, schema.GroupVersionResource{Group: "autoscaling", Version: "v1", Resource: "horizontalpodautoscalers"}, nil, t)
}

func checkResourceNamesDynamic(namespace string, expected []string, dyn dynamic.Interface, primary schema.GroupVersionResource, fallbacks []schema.GroupVersionResource, t *testing.T) {
	if len(expected) == 0 {
		return
	}

	candidates := append([]schema.GroupVersionResource{primary}, fallbacks...)

	var used schema.GroupVersionResource
	var list *unstructured.UnstructuredList
	var err error

	for _, gvr := range candidates {
		used = gvr
		list, err = dyn.Resource(gvr).Namespace(namespace).List(metav1.ListOptions{})
		if err == nil {
			break
		}
	}

	if err != nil {
		t.Errorf("Failed to list %s in %s: %v", primary.Resource, namespace, err)
		return
	}

	t.Logf("Checking namespace %s for %s, found %d total", namespace, used.Resource, len(list.Items))
	names := make(map[string]struct{}, len(list.Items))
	for i := range list.Items {
		name := list.Items[i].GetName()
		names[name] = struct{}{}
		t.Logf("Found %s: %s", used.Resource, name)
	}

	for _, resourceName := range expected {
		if _, ok := names[resourceName]; !ok {
			t.Errorf("%s '%s' not found in namespace %s", used.Resource, resourceName, namespace)
		}
	}
}
