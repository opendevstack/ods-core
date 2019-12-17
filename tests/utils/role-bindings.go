package utils

import (
    "fmt"
    v1 "k8s.io/api/rbac/v1"
)

func FindRoleBinding(roleBindings *v1.RoleBindingList, subjectName string, subjectType string, subjectNamespace string, roleName string) error {
	for _, roleBinding := range roleBindings.Items {
		for _, subject := range roleBinding.Subjects {
			if subject.Name == subjectName && subject.Namespace == subjectNamespace && roleBinding.RoleRef.Name == roleName && subject.Kind == subjectType {
				return nil
			}
		}
	}
	return fmt.Errorf("Subject '%s' of kind '%d' in namespace '%s' does not have the role '%s'", subjectName, subjectType, subjectNamespace, roleName)
}

func FindClusterRoleBinding(roleBindings *v1.ClusterRoleBindingList, subjectName string, subjectType string, subjectNamespace string, roleName string) error {
	for _, roleBinding := range roleBindings.Items {
		for _, subject := range roleBinding.Subjects {
			if subject.Name == subjectName && subject.Namespace == subjectNamespace && roleBinding.RoleRef.Name == roleName && subject.Kind == subjectType {
				return nil
			}
		}
	}
    return fmt.Errorf("Subject '%s' of kind '%d' in namespace '%s' does not have the cluster role '%s'", subjectName, subjectType, subjectNamespace, roleName)
}
