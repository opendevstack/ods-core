package utils

import (
	"fmt"

	v1 "k8s.io/api/core/v1"
)

func FindConfigMap(configMaps *v1.ConfigMapList, configMapName string) error {
	for _, configMap := range configMaps.Items {
		if configMapName == configMap.Name {
			return nil
		}
	}

	return fmt.Errorf("ConfigMap '%s' not found.", configMapName)
}
