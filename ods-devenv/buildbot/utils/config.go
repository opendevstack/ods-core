/*
 * utilities for the ods-devenv buildbot.
 */
package utils

import (
	"bufio"
	"log"
	"os"
	"os/user"
	"strings"
)

func ReadPackerRunControl() (map[string]string, error) {
	log.Println("try to read $HOME/.packerrc")
	user, err := user.Current()
	if err != nil {
		return nil, err
	}
	log.Println("user HOME is " + user.HomeDir)

	file, err := os.Open(user.HomeDir + "/.packerrc")
	defer closeFile(file)

	return ReadFileToMap(file)
}

// Read the build config from .packerrc
func ReadFileToMap(file *os.File) (map[string]string, error) {
	config := make(map[string]string)

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			config[parts[0]] = parts[1]
		}
	}

	return config, nil
}

func closeFile(file *os.File) {
	log.Printf("closing file %v\n", file)
	err := file.Close()

	if err != nil {
		log.Fatalf("error: %v\n", err)
	}
}
