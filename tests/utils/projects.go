package utils

import (
	"fmt"
	v1 "github.com/openshift/api/project/v1"
)

func FindProject(projects *v1.ProjectList, projectName string) error {
	for _, project := range projects.Items {
		if project.Name == projectName {
			return nil
		}
	}
	return fmt.Errorf("Project '%s' not found", projectName)
}
