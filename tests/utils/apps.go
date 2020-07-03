package utils

import (
	"fmt"
	v1 "github.com/openshift/api/apps/v1"
)

func FindDeploymentConfig(depoymentConfigs *v1.DeploymentConfigList, depoymentConfigName string) error {
	for _, deploymentConfig := range depoymentConfigs.Items {

		if depoymentConfigName == deploymentConfig.Name {
			return nil
		}
	}

	return fmt.Errorf("Deployment config '%s' not found.", depoymentConfigName)
}
