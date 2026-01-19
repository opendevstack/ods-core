package steps

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/opendevstack/ods-core/tests/quickstarter/logger"
)

// CreateTemplateData creates the template data map for rendering templates
func CreateTemplateData(config map[string]string, componentID string, buildName string, projectName string) TemplateData {
	sanitizedOdsGitRef := strings.ReplaceAll(config["ODS_GIT_REF"], "/", "_")
	sanitizedOdsGitRef = strings.ReplaceAll(sanitizedOdsGitRef, "-", "_")
	var buildNumber string
	if len(buildName) > 0 {
		buildParts := strings.Split(buildName, "-")
		buildNumber = buildParts[len(buildParts)-1]
	}
	aquaEnabled, _ := strconv.ParseBool(config["AQUA_ENABLED"])

	// Initialize template data map with standard fields
	data := TemplateData{
		"ProjectID":           projectName,
		"ComponentID":         componentID,
		"OdsNamespace":        config["ODS_NAMESPACE"],
		"OdsGitRef":           config["ODS_GIT_REF"],
		"OdsImageTag":         config["ODS_IMAGE_TAG"],
		"OdsBitbucketProject": config["ODS_BITBUCKET_PROJECT"],
		"SanitizedOdsGitRef":  sanitizedOdsGitRef,
		"BuildNumber":         buildNumber,
		"SonarQualityProfile": getEnv("SONAR_QUALITY_PROFILE", "Sonar way"),
		"AquaEnabled":         aquaEnabled,
	}

	// Add all config map entries whose keys don't contain PASSWORD, PASS, or TOKEN
	for key, value := range config {
		keyUpper := strings.ToUpper(key)
		if !strings.Contains(keyUpper, "PASSWORD") && !strings.Contains(keyUpper, "PASS") && !strings.Contains(keyUpper, "TOKEN") {
			// Only add if not already present to avoid overwriting standard fields
			if _, exists := data[key]; !exists {
				data[key] = value
			}
		}
	}

	// Automatically load all environment variables with TMPL_ prefix
	// Example: TMPL_MyVariable becomes accessible as {{.MyVariable}}
	// We check known TMPL_ variables and also scan all environment variables
	tmplVars := []string{
		"TMPL_SonarQualityGate",
		"TMPL_SonarQualityProfile",
	}

	// First, add any explicitly known TMPL_ variables
	for _, tmplVar := range tmplVars {
		if value, ok := os.LookupEnv(tmplVar); ok {
			key := strings.TrimPrefix(tmplVar, "TMPL_")
			data[key] = value
			logger.Debug(fmt.Sprintf("Loading environment variable: %s -> %s = '%s'", tmplVar, key, value))
		}
	}

	// Also scan all environment variables for any other TMPL_ prefixed ones
	for _, env := range os.Environ() {
		if strings.HasPrefix(env, "TMPL_") {
			pair := strings.SplitN(env, "=", 2)
			if len(pair) == 2 {
				key := strings.TrimPrefix(pair[0], "TMPL_")
				// Only add if not already added above
				if _, exists := data[key]; !exists {
					data[key] = pair[1]
					logger.Debug(fmt.Sprintf("Loading environment variable: %s -> %s = '%s'", pair[0], key, pair[1]))
				}
			}
		}
	}

	return data
}

// getEnv gets an environment variable with a default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
