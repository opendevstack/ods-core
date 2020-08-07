package utils

import (
	"fmt"
	"strings"

	v1 "k8s.io/api/core/v1"
	v12 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

// FindServiceHasPods returns an error if no pod is assigned to given service
// or if at least one pod is not "Running"
// or at least one of its containers is not "ready".
func FindServiceHasPods(services *v1.ServiceList, serviceName string) error {
	pods, err := servicePodsEnsureOnePerSelector(services, serviceName)
	if err != nil {
		return err
	}
	for _, pod := range pods.Items {
		phase := pod.Status.Phase
		if phase != "Running" {
			return fmt.Errorf(
				"Pod %s of service %s is not running: phase=%s",
				pod.GetName(),
				serviceName,
				phase,
			)
		}
		for _, containerStatus := range pod.Status.ContainerStatuses {
			if !containerStatus.Ready {
				return fmt.Errorf(
					"Container %s of pod %s of service %s is not ready",
					containerStatus.Name,
					pod.GetName(),
					serviceName,
				)
			}
		}
	}
	return nil
}

func servicePodsEnsureOnePerSelector(services *v1.ServiceList, serviceName string) (*v1.PodList, error) {
	for _, service := range services.Items {
		if service.Name == serviceName {
			config, err := GetOCClient()
			clientset, err := kubernetes.NewForConfig(config)
			if err != nil {
				return nil, err
			}

			podClient := clientset.CoreV1().Pods(service.Namespace)
			selector := []string{}
			for key, value := range service.Spec.Selector {
				selector = append(selector, fmt.Sprintf("%s=%s", key, value))
			}
			pods, err := podClient.List(
				v12.ListOptions{
					LabelSelector: strings.Join(selector, ","),
				},
			)
			if err != nil {
				return nil, err
			}
			if len(pods.Items) == 0 {
				return nil, fmt.Errorf("Service %s has a selector '%s' which returns no pods", serviceName, strings.Join(selector, ","))
			}
			return pods.DeepCopy(), nil
		}
	}
	return nil, fmt.Errorf("Service '%s' not found.", serviceName)
}
