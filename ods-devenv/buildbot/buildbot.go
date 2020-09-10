package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/opendevstack/ods-core/ods-devenv/buildbot/utils"
)

func main() {
	fmt.Printf("Verifying build at %s.\n", time.Now().Format("2006-01-02T150405"))
	config, _ := utils.ReadPackerRunControl()
	logPath := config["log_path"] + "/current"
	log.Println("logpath is " + logPath)

	logFile, _ := os.Open(logPath)
	log.Println("Scanning logfile " + logPath)
	buildSuccessIndicator := "amazon-ebs: Installation completed."
	scanner := bufio.NewScanner(logFile)
	buildSuccess := false
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, buildSuccessIndicator) {
			buildSuccess = true
			break
		}
	}
	if buildSuccess {
		// write success svg to webserver dir
		log.Println("build success")
	} else {
		// write failure svg to webserver dir
		log.Println("build failure")
	}
}
