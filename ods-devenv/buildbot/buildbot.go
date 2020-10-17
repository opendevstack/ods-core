package main

import (
	"bufio"
	"log"
	"os"
	"strings"
	"time"

	"github.com/opendevstack/ods-core/ods-devenv/buildbot/utils"
)

const usecase_buildAmi = "runAmiBuild"
const usecase_checkBuild = "checkAmiBuild"
const amiBuildExecutable = "runAmiBuild.sh"

func main() {

	cliArgs := os.Args[1:]
	if len(cliArgs) != 1 {
		log.Fatalf("Please specify which use case to execute: %s or %s\n", usecase_buildAmi, usecase_checkBuild)
	}

	if cliArgs[0] == usecase_buildAmi {
		log.Printf("Running %s\n", usecase_buildAmi)
		runAmiBuild()
	} else if cliArgs[0] == usecase_checkBuild {
		log.Printf("Running %s\n", usecase_checkBuild)
		checkAmiBuild()
	} else {
		log.Printf("Please specify valid usecase")
	}
}

func runAmiBuild() {
	configMap, err := utils.ReadBuildBotRunControl()
	if err != nil || configMap == nil {
		log.Fatalf("Could not load runtime configuration: %v\n", err)
	}
	buildArgs := getBuildArgsFromRunControl(configMap)
	branches := strings.Split(configMap["branch"], ",")

	stdout, _, err := utils.RunCommand("command", []string{"-v", amiBuildExecutable}, []string{})
	if err != nil || configMap == nil {
		log.Fatalf("Could not find AMI buildscript '%s' on path - Please copy it to the build user's path\n", amiBuildExecutable)
	}
	amiBuildScriptPath := strings.TrimSpace(stdout)

	for _, branch := range branches {
		log.Printf("Building branch %s using script %s\n", branch, amiBuildScriptPath)
		utils.RunCommandInBackground(amiBuildExecutable, append(buildArgs, "--target_git_ref", branch), []string{})
	}
}

func getBuildArgsFromRunControl(configMap map[string]string) []string {
	buildArgs := []string{}
	for key, value := range configMap {
		buildArgs = append(buildArgs, "--"+key, value)
	}
	return buildArgs
}

func checkAmiBuild() {
	configMap, err := utils.ReadBuildBotRunControl()
	if err != nil || configMap == nil {
		log.Fatalf("Could not load runtime configuration: %v\n", err)
	}
	branches := strings.Split(configMap["branch"], ",")

	for _, branch := range branches {
		log.Printf("Verify build for branch %s at %s.\n", branch, time.Now().Format("2006-01-02T150405"))
		checkAmiBuildForBranch(branch, configMap)
	}
}

func checkAmiBuildForBranch(branch string, configMap map[string]string) {
	branchPathSegement := strings.Replace(branch, "/", "_", -1)
	logPath := configMap["log_path"] + "/current_" + branchPathSegement + ".log"
	log.Println("logpath is " + logPath)

	logFile, err := os.Open(logPath)
	if err != nil {
		log.Fatalf("Could not open current log file: %v\n", err)
	}
	defer utils.CloseFile(logFile)

	log.Println("Scanning logfile " + logPath)
	amiBuildSuccessIndicator := "Installation completed."
	provappSuccessIndicator := "PASS: TestVerifyOdsProjectProvisionThruProvisionApi"
	quickstarterTestSuccessIndicator := "--- PASS: TestQuickstarter ("
	scanner := bufio.NewScanner(logFile)
	amiBuildSuccess := false
	provappTestSuccess := false
	quickstarterTestSuccess := false
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, amiBuildSuccessIndicator) {
			amiBuildSuccess = true
		} else if strings.Contains(line, provappSuccessIndicator) {
			provappTestSuccess = true
		} else if strings.Contains(line, quickstarterTestSuccessIndicator) {
			quickstarterTestSuccess = true
		}
	}

	// process build result
	buildResultPath := configMap["build_result_path"]
	// zip log file and copy it to download location
	err = utils.TarZip(logPath, configMap["build_result_path"]+"/current_log_"+branchPathSegement+".tar.gz")
	if err != nil {
		log.Fatalf("Could not tar log file: %v\n", err)
	}

	if amiBuildSuccess {
		// write success svg to webserver dir
		log.Println("build success")
		utils.Copy(buildResultPath+"/success.svg", buildResultPath+"/buildStatus_"+branchPathSegement+".svg")
	} else {
		// write failure svg to webserver dir
		log.Println("build failure")
		utils.Copy(buildResultPath+"/failure.svg", buildResultPath+"/buildStatus_"+branchPathSegement+".svg")
	}
	_, _, err = utils.RunCommand("sed", []string{"-i", "s|__branchname__|" + branch + "|", buildResultPath + "/buildStatus_" + branchPathSegement + ".svg"}, []string{})
	if err != nil {
		log.Fatalf("Could not rewrite branch name in build status svg for branch %s.\n", branch)
	}

	if provappTestSuccess {
		log.Println("provapp tests PASS")
		utils.Copy(buildResultPath+"/success.svg", buildResultPath+"/provapptestsoutcome_"+branchPathSegement+".svg")
	} else {
		log.Println("provapp tests FAIL")
		utils.Copy(buildResultPath+"/failure.svg", buildResultPath+"/provapptestsoutcome_"+branchPathSegement+".svg")
	}
	_, _, err = utils.RunCommand("sed", []string{"-i", "s|__branchname__|" + branch + "|", buildResultPath + "/provapptestsoutcome_" + branchPathSegement + ".svg"}, []string{})
	if err != nil {
		log.Fatalf("Could not rewrite branch name in prov-app build status svg for branch %s.\n", branch)
	}

	if quickstarterTestSuccess {
		log.Println("quickstarter tests PASS")
		utils.Copy(buildResultPath+"/success.svg", buildResultPath+"/quickstartertestsoutcome_"+branchPathSegement+".svg")
	} else {
		log.Println("quickstarter tests FAIL")
		utils.Copy(buildResultPath+"/failure.svg", buildResultPath+"/quickstartertestsoutcome_"+branchPathSegement+".svg")
	}
	_, _, err = utils.RunCommand("sed", []string{"-i", "s|__branchname__|" + branch + "|", buildResultPath + "/quickstartertestsoutcome_" + branchPathSegement + ".svg"}, []string{})
	if err != nil {
		log.Fatalf("Could not rewrite branch name in quickstarters build status svg for branch %s.\n", branch)
	}
}
