package ods_verify

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"path"
	"runtime"
	"strings"
	"testing"

	"github.com/opendevstack/ods-core/tests/utils"
	projectClientV1 "github.com/openshift/client-go/project/clientset/versioned/typed/project/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type provisionResponse struct {
	ProjectName        string
	WebhookProxySecret string
	ExecutionJobs      []provisionExecutionJob
}
type provisionExecutionJob struct {
	BuildName     string
	BuildURL      string
	BuildRun      string
	FullBuildName string
}

func TestVerifyOdsProjectProvisionThruProvisionApi(t *testing.T) {
	values, err := utils.ReadConfiguration()
	if err != nil {
		t.Fatal(err)
	}
	projectName := "ODSVERIFY"
	provAPI := &utils.ProvisionAPI{ProjectName: projectName, Config: values}

	// --- PROJECT ---
	err = provAPI.DeleteProject()
	if err != nil {
		t.Fatalf("Failed to delete project: %s", err)
	}
	res, err := provAPI.CreateProject()
	if err != nil {
		t.Fatalf("Failed to create project: %s", err)
	}

	provRes, err := extractProvisionResponse(strings.ToLower(values["ODS_NAMESPACE"]), res)
	if err != nil {
		t.Fatalf("Failed to extract prov response: %s", err)
	}
	if projectName != provRes.ProjectName {
		t.Fatalf("Project names don't match - expected: %s real: %s",
			projectName, provRes.ProjectName)
	}
	exJob := provRes.ExecutionJobs[0]

	stages, err := utils.RetrieveJenkinsBuildStagesForBuild(
		values["ODS_NAMESPACE"], exJob.FullBuildName,
	)
	if err != nil {
		t.Fatal(err)
	}
	fmt.Printf("Jenkins stages: \n'%s'\n", stages)
	err = utils.VerifyJenkinsStages(
		"golden/jenkins-stages-provision-project.json",
		stages,
	)
	if err != nil {
		t.Fatal(err)
	}

	CheckProjectsAreCreated(projectName, t)
	CheckJenkinsWithTailor(values, strings.ToLower(projectName), provRes.WebhookProxySecret, t)

	// --- COMPONENT ---
	res, err = provAPI.CreateComponent()
	if err != nil {
		t.Fatalf("Failed to create component: %s", err)
	}

	provRes, err = extractProvisionResponse(strings.ToLower(projectName+"-cd"), res)
	if err != nil {
		t.Fatalf("Failed to extract prov response: %s", err)
	}
	exJob = provRes.ExecutionJobs[0]

	stages, err = utils.RetrieveJenkinsBuildStagesForBuild(
		strings.ToLower(projectName+"-cd"), exJob.FullBuildName,
	)
	if err != nil {
		t.Fatal(err)
	}
	fmt.Printf("Jenkins stages: \n'%s'\n", stages)
	err = utils.VerifyJenkinsStages(
		"golden/jenkins-stages-provision-component.json",
		stages,
	)
	if err != nil {
		t.Fatal(err)
	}
	err = provAPI.DeleteComponent()
	if err != nil {
		t.Fatalf("Failed to delete component: %s", err)
	}
}

func extractProvisionResponse(jenkinsNamespace string, res []byte) (*provisionResponse, error) {
	provRes := &provisionResponse{ExecutionJobs: []provisionExecutionJob{}}
	var responseI map[string]interface{}
	err := json.Unmarshal(res, &responseI)
	if err != nil {
		return nil, fmt.Errorf("Could not parse json response: %s, err: %w",
			string(res), err)
	}

	provRes.ProjectName = responseI["projectName"].(string)
	provRes.WebhookProxySecret = responseI["webhookProxySecret"].(string)

	responseExecutionJobsArray := responseI["lastExecutionJobs"].([]interface{})
	for _, job := range responseExecutionJobsArray {
		responseExecutionJob := job.(map[string]interface{})

		// example: "odsverify-cd-ods-qs-plain-master"
		responseBuildName := responseExecutionJob["name"].(string)

		fmt.Printf("build name from jenkins: %s\n", responseBuildName)
		responseJenkinsBuildURL := responseExecutionJob["url"].(string)
		responseBuildRun := strings.SplitAfter(responseJenkinsBuildURL, responseBuildName+"/")[1]

		// example: "1"
		fmt.Printf("build run#: %s\n", responseBuildRun)

		// example: "ods-qs-plain-master"
		responseBuildClean := strings.Replace(responseBuildName,
			jenkinsNamespace+"-", "", 1)

		// example: "ods-qs-plain-master-1"
		fullBuildName := fmt.Sprintf("%s-%s", responseBuildClean, responseBuildRun)
		fmt.Printf("full buildName: %s\n", fullBuildName)

		ej := provisionExecutionJob{
			BuildName:     responseBuildName,
			BuildURL:      responseJenkinsBuildURL,
			BuildRun:      responseBuildRun,
			FullBuildName: fullBuildName,
		}
		provRes.ExecutionJobs = append(provRes.ExecutionJobs, ej)
	}
	return provRes, nil
}

func CheckProjectsAreCreated(projectName string, t *testing.T) {
	// check that all three projects were created
	expectedProjects := []string{
		fmt.Sprintf("%s-cd", strings.ToLower(projectName)),
		fmt.Sprintf("%s-dev", strings.ToLower(projectName)),
		fmt.Sprintf("%s-test", strings.ToLower(projectName)),
	}
	config, err := utils.GetOCClient()
	if err != nil {
		t.Fatalf("Error creating OC config: %s", err)
	}
	client, err := projectClientV1.NewForConfig(config)
	if err != nil {
		t.Fatalf("Error creating Project client: %s", err)
	}
	projects, err := client.Projects().List(metav1.ListOptions{})
	if err != nil {
		t.Fatalf("Cannot list projects: %s", err)
	}
	for _, expectedProject := range expectedProjects {
		if err = utils.FindProject(projects, expectedProject); err != nil {
			t.Fatal(err)
		}
	}
}

func CheckJenkinsWithTailor(values map[string]string, projectName string, webhookSecret string, t *testing.T) {
	_, filename, _, _ := runtime.Caller(0)
	dir := path.Join(path.Dir(filename), "..", "..", "jenkins", "ocp-config", "deploy")

	user := values["CD_USER_ID_B64"]
	secret := base64.StdEncoding.EncodeToString([]byte(webhookSecret))

	stdout, stderr, err := utils.RunCommandWithWorkDir("tailor", []string{
		"diff",
		"--reveal-secrets",
		"--exclude=rolebinding",
		"-n",
		fmt.Sprintf("%s-cd", projectName),
		fmt.Sprintf("--param=PROJECT=%s", projectName),
		fmt.Sprintf("--param=CD_USER_ID_B64=%s", user),
		"--selector", "template=ods-jenkins-template",
		fmt.Sprintf("--param=%s", fmt.Sprintf("PIPELINE_TRIGGER_SECRET_B64=%s", secret))}, dir, []string{})
	if err != nil {
		t.Fatalf(
			"Execution of tailor failed: \nStdOut: %s\nStdErr: %s",
			stdout,
			stderr)
	}
}
