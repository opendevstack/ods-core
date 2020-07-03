package utils

import (
	"fmt"
	v1 "github.com/openshift/api/build/v1"
)

func FindBuildConfig(buildConfigs *v1.BuildConfigList, buildConfigName string) error {
	for _, buildConfig := range buildConfigs.Items {

		if buildConfigName == buildConfig.Name {
			return nil
		}
	}

	return fmt.Errorf("Build config '%s' not found.", buildConfigName)
}
