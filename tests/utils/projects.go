package utils

import (
	"fmt"

	v1 "github.com/openshift/api/project/v1"
	rbacv1 "k8s.io/api/rbac/v1"
)

func FindProject(projects *v1.ProjectList, projectName string) error {
	for _, project := range projects.Items {
		if project.Name == projectName {
			return nil
		}
	}
	return fmt.Errorf("Project '%s' not found", projectName)
}

func FindRoleBinding(roleBindings *rbacv1.RoleBindingList, subjectName, subjectType, namespace, roleName string) error {
	for _, roleBinding := range roleBindings.Items {
		for _, subject := range roleBinding.Subjects {
			if subject.Name == subjectName && subject.Kind == subjectType && roleBinding.RoleRef.Name == roleName {
				// For ClusterRoleBindings or in the case of Groups with no namespace, namespace can be empty
				if namespace == "" || subject.Namespace == namespace {
					return nil
				}
			}
		}
	}
	return fmt.Errorf("RoleBinding not found: subjectName=%s, subjectType=%s, namespace=%s, roleName=%s", subjectName, subjectType, namespace, roleName)
}
