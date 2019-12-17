package utils

import v1 "github.com/openshift/api/project/v1"

func FindProject(projects *v1.ProjectList, projectName string) bool {
	for _, project := range projects.Items {
		if project.Name == projectName {
			return true
		}
	}
	return false
}
