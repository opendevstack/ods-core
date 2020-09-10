package utils

import (
	"os"
	"os/user"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestReadPackerRC(t *testing.T) {
	// TODO use afero to create mock file system and prepare mock .packerrc file
	user, _ := user.Current()
	packerRcFile, _ := os.Open(user.HomeDir + "/.packerrc")
	defer packerRcFile.Close()
	config, _ := ReadFileToMap(packerRcFile)
	assert := assert.New(t)
	assert.Equal("/home/buildbot/logs", config["log_path"], "should be valid log dir path")
	assert.Equal("/home/buildbot/opendevstack/ods-core", config["build_path"], "should be valid build dir path")
	assert.Equal("master", config["branch"], "should be valid build branch")
}
