package utils

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
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
	HandleFileErr(err, sourcePath)
	defer CloseFile(sourceFile)

	destFile, err := os.Create(destPath)
	HandleFileErr(err, destPath)
	err = os.Chmod(destPath, 0644)
	HandleFileErr(err, destPath)
	defer CloseFile(destFile)

	length, err := io.Copy(destFile, sourceFile)
	if err != nil {
		log.Fatalf("Could not copy %s to %s: %v\n", sourcePath, destPath, err)
	}
	log.Printf("copied %d bytes from %s to %s.\n", length, sourcePath, destPath)
}

func TarZip(sourcePath, destPath string) error {
	// check that sourcePath exists
	if _, err := os.Stat(sourcePath); err != nil {
		return fmt.Errorf("tar error: %v\n", err.Error())
	}
	log.Printf("tar %s to %s.\n", sourcePath, destPath)

	tarfile, err := os.Create(destPath)
	if err != nil {
		return err
	}

	gzipWriter := gzip.NewWriter(tarfile)
	defer gzipWriter.Close()

	tarWriter := tar.NewWriter(gzipWriter)
	defer tarWriter.Close()

	fileInfo, err := os.Stat(sourcePath)
	if !fileInfo.Mode().IsRegular() {
		return nil
	}
	header, err := tar.FileInfoHeader(fileInfo, fileInfo.Name())
	if err != nil {
		return err
	}
	log.Printf("Writing header %v\n", header)

	if err := tarWriter.WriteHeader(header); err != nil {
		return err
	}

	file, err := os.Open(sourcePath)
	if err != nil {
		return err
	}

	if length, err := io.Copy(tarWriter, file); err != nil {
		return err
	} else {
		log.Printf("Wrote %d bytes to tar ball.\n", length)
	}
	file.Close()

	return nil
}

func HandleFileErr(err error, fileName string) {
	if err != nil {
		log.Fatalf("Could not process file %s: %v\n", fileName, err)
	}
}

func CloseFile(file *os.File) {
	log.Printf("closing file %v\n", file)
	err := file.Close()

	if err != nil {
		log.Fatalf("error: %v\n", err)
	}
}

func RunCommand(command string, args []string, envVars []string) (string, error) {
	cmd := exec.Command(command, args...)
	cmd.Env = append(os.Environ(), envVars...)
	log.Printf("Running command %s\n", command)
	var stdBuffer bytes.Buffer
	// add real time command output
	multiWriter := io.MultiWriter(os.Stdout, &stdBuffer)

	cmd.Stdout = multiWriter
	cmd.Stderr = multiWriter
	err := cmd.Run()

	return stdBuffer.String(), err
}

func RunCommandInBackground(command string, args []string, envVars []string) {
	cmd := exec.Command(command, args...)
	cmd.Env = append(os.Environ(), envVars...)
	if err := cmd.Start(); err != nil {
		log.Fatalf("error: %v\n", err)
	}
}
