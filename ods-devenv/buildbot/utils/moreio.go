package utils

import (
	"io"
	"log"
	"os"
)

func FileExists(filename string) bool {
	fileStat, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	} else {
		return !fileStat.IsDir()
	}
}

func Copy(sourcePath, destPath string) {
	sourceFile, err := os.Open(sourcePath)
	handleFileErr(err, sourcePath)
	defer CloseFile(sourceFile)

	destFile, err := os.Create(destPath)
	handleFileErr(err, destPath)
	err = os.Chmod(destPath, 0644)
	handleFileErr(err, destPath)
	defer CloseFile(destFile)

	length, err := io.Copy(destFile, sourceFile)
	if err != nil {
		log.Fatalf("Could not copy %s to %s: %v\n", sourcePath, destPath, err)
	}
	log.Printf("copied %d bytes from %s to %s.\n", length, sourcePath, destPath)
}

func handleFileErr(err error, fileName string) {
	if err != nil {
		log.Fatalf("Could not process file %s: %v\n", fileName, err)
	}
}
