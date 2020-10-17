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

const CONFIG_FILE_NAME = ".buildbotrc"

func ReadBuildBotRunControl() (map[string]string, error) {
	user, err := user.Current()
	if err != nil {
		return nil, err
	}

	buildBotrcPath := user.HomeDir + "/" + CONFIG_FILE_NAME
	log.Printf("Reading buildbot runcontrol from %s\n", buildBotrcPath)
	file, err := os.Open(buildBotrcPath)
	HandleFileErr(err, buildBotrcPath)
	defer CloseFile(file)

	return ReadFileToMap(file)
}

// Read buildbotrc from CONFIG_FILE_NAME
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
