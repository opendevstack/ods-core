package utils

import (
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"path/filepath"
)

func GetOCClient() (*rest.Config, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	config, err := clientcmd.BuildConfigFromFlags("", filepath.Join(home, ".kube", "config"))
	if err != nil {
		return nil, err
	}

	return config, nil
}
