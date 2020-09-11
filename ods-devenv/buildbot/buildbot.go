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
	config, err := utils.ReadPackerRunControl()
	if err != nil || config == nil {
		log.Fatalf("Could not load runtime configuration: %v\n", err)
	}

	logPath := config["log_path"] + "/current"
	log.Println("logpath is " + logPath)

	logFile, err := os.Open(logPath)
	if err != nil {
		log.Fatalf("Could not open current log file: %v\n", err)
	}
	defer utils.CloseFile(logFile)

	log.Println("Scanning logfile " + logPath)
	buildSuccessIndicator := "Installation completed."
	scanner := bufio.NewScanner(logFile)
	buildSuccess := false
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, buildSuccessIndicator) {
			buildSuccess = true
			break
		}
	}

	// process build result
	buildResultPath := config["build_result_path"]
	// zip log file and copy it to download location
	err = utils.TarZip(config["log_path"]+"/currrent", config["build_result_path"]+"/current_log.tar.gz")
	if err != nil {
		log.Fatalf("Could not tar log file: %v\n", err)
	}

	if buildSuccess {
		// write success svg to webserver dir
		log.Println("build success")
		utils.Copy(buildResultPath+"/success.svg", buildResultPath+"/buildStatus.svg")
	} else {
		// write failure svg to webserver dir
		log.Println("build failure")
		utils.Copy(buildResultPath+"/failure.svg", buildResultPath+"/buildStatus.svg")
	}
}
