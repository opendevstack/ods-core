package utils

import (
	"fmt"
	coreUtils "github.com/opendevstack/ods-core/tests/utils"
	v1 "k8s.io/api/core/v1"
	v12 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"strings"
)

func FindService(services *v1.ServiceList, serviceName string) error {
	for _, service := range services.Items {
		if service.Name == serviceName {

			config, err := coreUtils.GetOCClient()
			clientset, err := kubernetes.NewForConfig(config)

			if err != nil {
				return err
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
				return err
			}
			if len(pods.Items) == 0 {
				return fmt.Errorf("Service %s has a selector '%s' which returns no pods", serviceName, strings.Join(selector, ","))
			}

			return nil
		}

	}

	return fmt.Errorf("Service '%s' not found.", serviceName)
}
