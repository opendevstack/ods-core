package utils

import (
	"fmt"

	v1 "github.com/openshift/api/route/v1"
)

func FindRoute(routes *v1.RouteList, routeName string) error {
	for _, route := range routes.Items {
		if routeName == route.Name {
			return nil
		}
	}

	return fmt.Errorf("Route '%s' not found.", routeName)
}
