package utils

import (
	"fmt"

	v1 "k8s.io/api/core/v1"
)

func FindSecret(secrets *v1.SecretList, secretName string) error {
	for _, secret := range secrets.Items {
		if secretName == secret.Name {
			return nil
		}
	}

	return fmt.Errorf("Secret '%s' not found.", secretName)
}
