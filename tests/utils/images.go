package utils

import (
    "fmt"
    v1 "github.com/openshift/api/image/v1"
)

func FindImageTag(imageStreamList *v1.ImageStreamList, imageName string, tagName string) error {
    for _, imageStream := range imageStreamList.Items {
        if imageStream.Name != imageName {
            continue
        }
        for _, tag := range imageStream.Status.Tags {
            if tag.Tag == tagName {
                return nil
            }
        }
    }
    return fmt.Errorf("Image tag '%s:%s' not found.", imageName, tagName)
}
