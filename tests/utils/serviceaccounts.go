package utils

import (
	"fmt"

	v1 "k8s.io/api/core/v1"
)

func FindServiceAccount(serviceAccounts *v1.ServiceAccountList, serviceAccountName string) error {
	for _, serviceAccount := range serviceAccounts.Items {
		if serviceAccountName == serviceAccount.Name {
			return nil
		}
	}

	return fmt.Errorf("ServiceAccount '%s' not found.", serviceAccountName)
}
