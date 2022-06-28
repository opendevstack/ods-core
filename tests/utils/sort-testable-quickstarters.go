package utils

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"testing"
)

func SortTestableQuickstarters(t *testing.T, dir string, quickstarterPaths []string) []string {

	var filePath string = fmt.Sprintf("%s/../ods-core/tests/%s", dir, "quickStartersBuildPriority.txt")
	fmt.Printf("\n\nLooking for file quickStartersBuildPriority.txt ... %s\n", filePath)

	fmt.Printf("\n\nNot sorted quickStarters list:\n")
	for _, quickstarterPath := range quickstarterPaths {
		fmt.Printf("- %s\n", quickstarterPath)
	}
	fmt.Printf("\n\n")

	var sortedQuickStartersPaths []string

	file, err := os.Open(filePath)
	if err != nil {
		fmt.Println(err)
		t.Fatal(err)
	}
	defer file.Close()

	fmt.Println("\n\nQuickStarters that will be compiled first...")
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		var qsSubText = scanner.Text()
		fmt.Println(qsSubText)
		for _, quickstarterPath := range quickstarterPaths {
			if strings.Contains(quickstarterPath, qsSubText) {
				sortedQuickStartersPaths = append(sortedQuickStartersPaths, quickstarterPath)
			}
		}

	}

	if err := scanner.Err(); err != nil {
		fmt.Println(err)
		t.Fatal(err)
	}

	for _, quickStarterPath := range quickstarterPaths {
		var addQs = true
		for _, sortedQuickStarterPath := range sortedQuickStartersPaths {
			if strings.Contains(quickStarterPath, sortedQuickStarterPath) {
				addQs = false
			}
		}

		if addQs {
			sortedQuickStartersPaths = append(sortedQuickStartersPaths, quickStarterPath)
		}
	}

	return sortedQuickStartersPaths
}
