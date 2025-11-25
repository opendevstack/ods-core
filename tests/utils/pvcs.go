package utils

import (
	"fmt"

	v1 "k8s.io/api/core/v1"
)

func FindPersistentVolumeClaim(pvcs *v1.PersistentVolumeClaimList, pvcName string) error {
	for _, pvc := range pvcs.Items {
		if pvcName == pvc.Name {
			return nil
		}
	}

	return fmt.Errorf("PersistentVolumeClaim '%s' not found.", pvcName)
}
