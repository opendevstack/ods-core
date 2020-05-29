package utils

import (
	"bufio"
	"os"
	"path"
	"runtime"
	"strings"
)

func ReadConfiguration() (map[string]string, error) {

	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "..", "ods-configuration", "ods-core.env")

	file, err := os.Open(dir)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	values := map[string]string{}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			values[parts[0]] = parts[1]
		}
	}

	return values, nil
}
