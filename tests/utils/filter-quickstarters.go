package utils

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"testing"
)

func RemoveExcludedQuickstarters(t *testing.T, dir string, quickstarterPaths []string) []string {
	var quickstarterPathsFiltered []string
	var exclusionList []string

	var filePath string = fmt.Sprintf("%s/../%s", dir, "quickStartersExclusionList.txt")
	fmt.Printf("\n\nLooking for file quickStartersExclusionList.txt ... %s\n", filePath)

	_, err := os.Stat(filePath)

	if os.IsNotExist(err) {
		fmt.Printf("File %s does not exist, The list of Quickstarters is not filtered.\n", filePath)
		return quickstarterPaths
	}

	file, err := os.Open(filePath)
	if err != nil {
		fmt.Println(err)
		t.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		exclusionList = append(exclusionList, scanner.Text())
	}

	fmt.Printf("\n\nQuickStarters that will be excluded...\n%s", exclusionList)

	for _, quickstarterPath := range quickstarterPaths {
		if sliceContainsString(exclusionList, quickstarterPath) == -1 {
			quickstarterPathsFiltered = append(quickstarterPathsFiltered, quickstarterPath)
		}
	}

	return quickstarterPathsFiltered
}

func sliceContainsString(slice []string, str string) int {
	for pos, s := range slice {
		if strings.Contains(str, s) {
			return pos
		}
	}
	return -1
}
