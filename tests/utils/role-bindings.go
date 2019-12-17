package utils

import (
	v1 "k8s.io/api/rbac/v1"
)

func FindRoleBinding(roleBindings *v1.RoleBindingList, subjectName string, subjectType string, subjectNamespace string, roleName string) bool {
	for _, roleBinding := range roleBindings.Items {
		for _, subject := range roleBinding.Subjects {
			if subject.Name == subjectName && subject.Namespace == subjectNamespace && roleBinding.RoleRef.Name == roleName && subject.Kind == subjectType {
				return true
			}
		}
	}
	return false
}

func FindClusterRoleBinding(roleBindings *v1.ClusterRoleBindingList, subjectName string, subjectType string, subjectNamespace string, roleName string) bool {
	for _, roleBinding := range roleBindings.Items {
		for _, subject := range roleBinding.Subjects {
			if subject.Name == subjectName && subject.Namespace == subjectNamespace && roleBinding.RoleRef.Name == roleName && subject.Kind == subjectType {
				return true
			}
		}
	}
	return false
}
