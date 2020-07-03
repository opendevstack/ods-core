package utils

import (
	"fmt"

	v1 "github.com/openshift/api/image/v1"
)

func FindImageTag(imageStreamList *v1.ImageStreamList, imageTag ImageTag) error {
	for _, imageStream := range imageStreamList.Items {
		if imageStream.Name != imageTag.Name {
			continue
		}
		for _, tag := range imageStream.Status.Tags {
			if tag.Tag == imageTag.Tag {
				return nil
			}
		}
	}
	return fmt.Errorf("Image tag '%s:%s' not found.", imageTag.Name, imageTag.Tag)
}

func FindImageStream(imageStreamList *v1.ImageStreamList, imageStreamName string) error {
	for _, imageStream := range imageStreamList.Items {
		if imageStream.Name == imageStreamName {
			return nil
		}
	}
	return fmt.Errorf("Image stream '%s' not found.", imageStreamName)
}
