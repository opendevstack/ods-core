package main

import (
	"bytes"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

const (
	tokenFile                 = "/var/run/secrets/kubernetes.io/serviceaccount/token"
	caCert                    = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
	buildConfig               = "bc.json"
	repoBaseVariable          = "REPO_BASE"
	triggerSecretVariable     = "TRIGGER_SECRET"
	triggerSecretDefault      = "secret101"
	protectedBranchesVariable = "PROTECTED_BRANCHES"
	protectedBranchesDefault  = "master,develop,production,staging,release"
	letterBytes               = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
)

// Event is the internal representation of a BitBucket event described in
// https://confluence.atlassian.com/bitbucketserver0511/using-bitbucket-server/managing-webhooks-in-bitbucket-server/event-payload
type Event struct {
	Kind      string
	Project   string
	Namespace string
	Repo      string
	Component string
	Branch    string
	Pipeline  string
	RequestID string
}

// Client makes requests, e.g. to create and delete pipelines, or to forward
// event payloads.
type Client struct {
	SecureClient *http.Client
	SimpleClient *http.Client
	Token        string
}

// Server represents this service, and is a global.
type Server struct {
	Client            *Client
	TriggerSecret     string
	ProtectedBranches []string
	RepoBase          string
}

var server *Server

func init() {
	rand.Seed(time.Now().UnixNano())
}

func main() {
	log.Println("Booted")

	repoBase := os.Getenv(repoBaseVariable)
	if len(repoBase) == 0 {
		log.Fatalln(repoBaseVariable, "must be set")
	}

	var protectedBranches []string
	envProtectedBranches := os.Getenv(protectedBranchesVariable)
	if len(envProtectedBranches) == 0 {
		protectedBranches = strings.Split(protectedBranchesDefault, ",")
		log.Println("WARN:", protectedBranchesVariable, "not set, using default value")
	} else {
		protectedBranches = strings.Split(envProtectedBranches, ",")
	}

	triggerSecret := os.Getenv(triggerSecretVariable)
	if len(triggerSecret) == 0 {
		triggerSecret = triggerSecretDefault
		log.Println("WARN:", triggerSecretVariable, "not set, using default value")
	}

	token, err := getToken()
	if err != nil {
		log.Fatalln("Could not get token:", err)
	}

	secureClient, err := getSecureClient()
	if err != nil {
		log.Fatalln("Could not get client:", err)
	}

	client := &Client{
		SecureClient: secureClient,
		SimpleClient: &http.Client{Timeout: 30 * time.Second},
		Token:        token,
	}

	server = &Server{
		Client:            client,
		TriggerSecret:     triggerSecret,
		ProtectedBranches: protectedBranches,
		RepoBase:          repoBase,
	}

	log.Println("Ready to accept requests")

	http.HandleFunc("/", server.HandleRoot())

	log.Fatal(http.ListenAndServe(":8080", nil))
}

// HandleRoot handles all requests to this service.
func (s *Server) HandleRoot() http.HandlerFunc {
	type repository struct {
		Project struct {
			Key string `json:"key"`
		} `json:"project"`
		Slug string `json:"slug"`
	}
	type request struct {
		EventKey   string     `json:"eventKey"`
		Repository repository `json:"repository"`
		Changes    []struct {
			Type string `json:"type"`
			Ref  struct {
				DisplayID string `json:"displayId"`
			} `json:"ref"`
		} `json:"changes"`
		PullRequest *struct {
			FromRef struct {
				Repository repository `json:"repository"`
				DisplayID  string     `json:"displayId"`
			} `json:"fromRef"`
		} `json:"pullRequest"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		requestID := randStringBytes(6)
		log.Println(requestID, "-----")

		req := &request{}
		json.NewDecoder(r.Body).Decode(req)

		var project string
		var repo string
		var component string
		var kind string
		var branch string

		if req.EventKey == "repo:refs_changed" {
			project = strings.ToLower(req.Repository.Project.Key)
			repo = req.Repository.Slug
			component = strings.Replace(repo, project+"-", "", -1)
			branch = req.Changes[0].Ref.DisplayID
			if req.Changes[0].Type == "DELETE" {
				kind = "delete"
			} else {
				kind = "forward"
			}
		} else if req.EventKey == "pr:merged" || req.EventKey == "pr:declined" {
			project = strings.ToLower(req.PullRequest.FromRef.Repository.Project.Key)
			repo = req.PullRequest.FromRef.Repository.Slug
			component = strings.Replace(repo, project+"-", "", -1)
			branch = req.PullRequest.FromRef.DisplayID
			kind = "delete"
		} else {
			log.Println(requestID, "Skipping unknown event", req.EventKey)
			return
		}
		namespace := project + "-cd"
		pipeline := component + "-"

		// Extract JIRA user story from branch name if present
		re := regexp.MustCompile(".*-([0-9]+)-.*")
		matches := re.FindStringSubmatch(branch)
		if len(matches) > 0 {
			pipeline = pipeline + matches[1]
		} else {
			pipeline = pipeline + strings.Replace(strings.ToLower(branch), "/", "-", -1)
		}

		event := &Event{
			Kind:      kind,
			Project:   project,
			Namespace: namespace,
			Repo:      repo,
			Component: component,
			Branch:    branch,
			Pipeline:  pipeline,
			RequestID: requestID,
		}
		log.Println(requestID, event)

		if event.Kind == "forward" {
			err := server.Client.CreatePipelineIfRequired(event)
			if err != nil {
				log.Println(requestID, err)
				return
			}
			err = server.Client.Forward(event)
			if err != nil {
				log.Println(requestID, err)
				return
			}
		} else if event.Kind == "delete" {
			for _, b := range s.ProtectedBranches {
				if b == event.Branch {
					log.Println(
						requestID,
						b,
						"is protected - its pipeline cannot be deleted",
					)
					return
				}
			}
			err := server.Client.DeletePipeline(event)
			if err != nil {
				log.Println(requestID, err)
				return
			}
		} else {
			log.Println(requestID, "Unrecognized event")
		}
	}
}

// Forward forwards a webhook event payload to the correct pipeline.
func (c *Client) Forward(e *Event) error {
	url := fmt.Sprintf(
		"https://api.bi-x.openshift.com:443/oapi/v1/namespaces/%s/buildconfigs/%s/webhooks/%s/generic",
		e.Namespace,
		e.Pipeline,
		server.TriggerSecret,
	)
	log.Println(e.RequestID, "Forwarding to", url)

	_, err := c.SimpleClient.Post(
		url,
		"application/json; charset=utf-8",
		new(bytes.Buffer),
	)
	if err != nil {
		return errors.New(fmt.Sprintf("Got error %s", err))
	}
	return nil
}

// CreatePipelineIfRequired ensures that the pipeline which corresponds to the
// received event exists in OpenShift.
func (c *Client) CreatePipelineIfRequired(e *Event) error {
	exists, err := c.checkPipeline(e)
	if err != nil {
		return err
	}

	if exists {
		return nil
	}

	jsonStr, err := getBuildConfig(e)
	if err != nil {
		return err
	}

	url := fmt.Sprintf(
		"https://openshift.default.svc.cluster.local/oapi/v1/namespaces/%s/buildconfigs",
		e.Namespace,
	)
	req, _ := http.NewRequest(
		"POST",
		url,
		bytes.NewBuffer(jsonStr),
	)
	res, err := c.do(req)
	if err != nil {
		msg := fmt.Sprintf("error: %s", err.Error())
		return errors.New(msg)
	}
	defer res.Body.Close()

	body, _ := ioutil.ReadAll(res.Body)

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return errors.New(string(body))
	}

	log.Println(e.RequestID, "Created pipeline", e.Pipeline)

	return nil
}

// DeletePipeline removes the pipeline corresponding to the event from
// OpenShift.
func (c *Client) DeletePipeline(e *Event) error {
	url := fmt.Sprintf(
		"https://openshift.default.svc.cluster.local/oapi/v1/namespaces/%s/buildconfigs/%s",
		e.Namespace,
		e.Pipeline,
	)
	req, _ := http.NewRequest(
		"DELETE",
		url,
		nil,
	)
	res, err := c.do(req)
	if err != nil {
		msg := fmt.Sprintf("error: %s", err.Error())
		return errors.New(msg)
	}
	defer res.Body.Close()

	body, _ := ioutil.ReadAll(res.Body)

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return errors.New(string(body))
	}

	log.Println(e.RequestID, "Deleted pipeline", e.Pipeline)

	return nil
}

func (c *Client) checkPipeline(e *Event) (bool, error) {
	url := fmt.Sprintf(
		"https://openshift.default.svc.cluster.local/oapi/v1/namespaces/%s/buildconfigs/%s",
		e.Namespace,
		e.Pipeline,
	)
	req, _ := http.NewRequest(
		"GET",
		url,
		nil,
	)
	res, err := c.do(req)
	if err != nil {
		msg := fmt.Sprintf("error: %s", err.Error())
		return false, errors.New(msg)
	}
	defer res.Body.Close()

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return false, nil
	}

	return true, nil
}

func (c *Client) do(req *http.Request) (*http.Response, error) {
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.Token)
	return c.SecureClient.Do(req)
}

func (e *Event) String() string {
	return fmt.Sprintf(
		"kind=%s, project=%s, namespace=%s, repo=%s, component=%s, branch=%s, pipeline=%s",
		e.Kind,
		e.Project,
		e.Namespace,
		e.Repo,
		e.Component,
		e.Branch,
		e.Pipeline,
	)
}

func getBuildConfig(e *Event) ([]byte, error) {
	configBytes, err := ioutil.ReadFile(buildConfig)
	if err != nil {
		return []byte{}, err
	}

	gitURITemplate := server.RepoBase + "/%s/%s.git"
	gitURI := fmt.Sprintf(
		gitURITemplate,
		e.Project,
		e.Repo,
	)

	configBytes = bytes.Replace(configBytes, []byte("NAME"), []byte(e.Pipeline), -1)
	configBytes = bytes.Replace(configBytes, []byte("TRIGGER_SECRET"), []byte(server.TriggerSecret), -1)
	configBytes = bytes.Replace(configBytes, []byte("GIT_URI"), []byte(gitURI), -1)
	configBytes = bytes.Replace(configBytes, []byte("BRANCH"), []byte(e.Branch), -1)

	return configBytes, nil
}

func getSecureClient() (*http.Client, error) {
	// Load CA cert
	caCert, err := ioutil.ReadFile(caCert)
	if err != nil {
		return nil, err
	}
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(caCert)

	// Setup HTTPS client
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{},
		RootCAs:      caCertPool,
	}
	tlsConfig.BuildNameToCertificate()
	transport := &http.Transport{TLSClientConfig: tlsConfig}
	return &http.Client{Transport: transport, Timeout: 10 * time.Second}, nil
}

func getToken() (string, error) {
	content, err := ioutil.ReadFile(tokenFile)
	if err != nil {
		return "", err
	}
	return string(content), nil
}

func randStringBytes(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}
