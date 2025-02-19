package main

import (
	"bytes"
	"crypto/sha1"
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
	"sync"
	"text/template"
	"time"
)

const (
	namespaceFile                  = "/var/run/secrets/kubernetes.io/serviceaccount/namespace"
	tokenFile                      = "/var/run/secrets/kubernetes.io/serviceaccount/token"
	caCert                         = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
	buildAPIBasePath               = "/apis/build.openshift.io/v1"
	pipelineConfigFilename         = "pipeline.json.tmpl"
	repoBaseEnvVar                 = "REPO_BASE"
	triggerSecretEnvVar            = "TRIGGER_SECRET"
	triggerSecretDefault           = "secret101"
	jenkinsfilePathDefault         = "Jenkinsfile"
	protectedBranchesEnvVar        = "PROTECTED_BRANCHES"
	protectedBranchesDefault       = "master,develop,production,staging,release/"
	acceptedEventsEnvVar           = "ACCEPTED_EVENTS"
	acceptedEventsDefault          = "repo:refs_changed,pr:declined,pr:merged,pr:deleted"
	openShiftAPIHostEnvVar         = "OPENSHIFT_API_HOST"
	openShiftAPIHostDefault        = "openshift.default.svc.cluster.local"
	allowedExternalProjectsEnvVar  = "ALLOWED_EXTERNAL_PROJECTS"
	allowedExternalProjectsDefault = "opendevstack"
	allowedChangeRefTypesEnvVar    = "ALLOWED_CHANGE_REF_TYPES"
	allowedChangeRefTypesDefault   = "BRANCH"
	namespaceSuffix                = "-cd"
	letterBytes                    = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
)

// EnvPair represents an environment variable
type EnvPair struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

// Event is the internal representation of a BitBucket event described in
// https://confluence.atlassian.com/bitbucketserver0511/using-bitbucket-server/managing-webhooks-in-bitbucket-server/event-payload
type Event struct {
	Kind      string
	Namespace string
	Repo      string
	Component string
	Branch    string
	Pipeline  string
	RequestID string
	Env       []EnvPair
}

// BuildConfigData represents the data to be rendered into the BuildConfig template.
type BuildConfigData struct {
	Name            string
	TriggerSecret   string
	GitURI          string
	Branch          string
	JenkinsfilePath string
	Env             string
	ResourceVersion string
}

// buildConfig represents the relevant fields of an OpenShift BuildConfig, see
// https://docs.openshift.com/container-platform/3.11/rest_api/apis-build.openshift.io/v1.BuildConfig.html#object-schema.
type buildConfig struct {
	Metadata struct {
		ResourceVersion string `json:"resourceVersion"`
	} `json:"metadata"`
	Spec struct {
		Source struct {
			Git struct {
				Ref string `json:"ref"`
			} `json:"git"`
		} `json:"source"`
		Strategy struct {
			JenkinsPipelineStrategy struct {
				JenkinsfilePath string `json:"jenkinsfilePath"`
			} `json:"jenkinsPipelineStrategy"`
		} `json:"strategy"`
		Triggers struct {
			Generic struct {
				Secret string `json:"triggerSecret"`
			} `json:"generic"`
		} `json:"triggers"`
	} `json:"spec"`
}

// Client makes requests, e.g. to create and delete pipelines, or to forward
// event payloads.
type Client interface {
	Forward(e *Event, triggerSecret string) (int, []byte, error)
	GetPipeline(e *Event) (bool, []byte, error)
	CreateOrUpdatePipeline(exists bool, tmpl *template.Template, e *Event, data BuildConfigData) (int, error)
	DeletePipeline(e *Event) error
	CheckJenkinsAvailability(e *Event)
	CheckDocGenAvailability(e *Event)
}

type ocClient struct {
	HTTPClient          *http.Client
	OpenShiftAPIBaseURL string
	Token               string
}

// Server represents this service, and is a global.
type Server struct {
	Client                  Client
	Namespace               string
	Project                 string
	TriggerSecret           string
	ProtectedBranches       []string
	AcceptedEvents          []string
	AllowedExternalProjects []string
	AllowedChangeRefTypes   []string
	RepoBase                string
}

func init() {
	rand.Seed(time.Now().UnixNano())
}

func main() {
	log.Println("Booting")

	repoBase := os.Getenv(repoBaseEnvVar)
	if len(repoBase) == 0 {
		log.Fatalln(repoBaseEnvVar, "must be set")
	}

	var protectedBranches []string
	envProtectedBranches := os.Getenv(protectedBranchesEnvVar)
	if len(envProtectedBranches) == 0 {
		protectedBranches = strings.Split(protectedBranchesDefault, ",")
		log.Println(
			"INFO:",
			protectedBranchesEnvVar,
			"not set, using default value:",
			protectedBranchesDefault,
		)
	} else {
		protectedBranches = strings.Split(envProtectedBranches, ",")
	}

	var acceptedEvents []string
	envAcceptedEvents := os.Getenv(acceptedEventsEnvVar)
	if len(envAcceptedEvents) == 0 {
		acceptedEvents = strings.Split(acceptedEventsDefault, ",")
		log.Println(
			"INFO:",
			acceptedEventsEnvVar,
			"not set, using default value:",
			acceptedEventsDefault,
		)
	} else {
		acceptedEvents = strings.Split(envAcceptedEvents, ",")
	}

	triggerSecret := os.Getenv(triggerSecretEnvVar)
	if len(triggerSecret) == 0 {
		triggerSecret = triggerSecretDefault
		log.Println(
			"WARN:",
			triggerSecretEnvVar,
			"not set, using default value:",
			triggerSecretDefault,
		)
	}

	openShiftAPIHost := os.Getenv(openShiftAPIHostEnvVar)
	if len(openShiftAPIHost) == 0 {
		openShiftAPIHost = openShiftAPIHostDefault
		log.Println(
			"INFO:",
			openShiftAPIHostEnvVar,
			"not set, using default value:",
			openShiftAPIHostDefault,
		)
	}

	var allowedExternalProjects []string
	envAllowedExternalProjects := strings.ToLower(os.Getenv(allowedExternalProjectsEnvVar))
	if len(envAllowedExternalProjects) == 0 {
		allowedExternalProjects = strings.Split(allowedExternalProjectsDefault, ",")
		log.Println(
			"INFO:",
			allowedExternalProjectsEnvVar,
			"not set, using default value:",
			allowedExternalProjectsDefault,
		)
	} else {
		allowedExternalProjects = strings.Split(envAllowedExternalProjects, ",")
		for i := range allowedExternalProjects {
			allowedExternalProjects[i] = strings.TrimSpace(allowedExternalProjects[i])
		}
	}

	var allowedChangeRefTypes []string
	envAllowedChangeRefTypes := strings.ToLower(os.Getenv(allowedChangeRefTypesEnvVar))
	if len(allowedChangeRefTypes) == 0 {
		allowedChangeRefTypes = strings.Split(allowedChangeRefTypesDefault, ",")
		log.Println(
			"INFO:",
			allowedChangeRefTypesEnvVar,
			"not set, using default value:",
			allowedChangeRefTypesDefault,
		)
	} else {
		allowedChangeRefTypes = strings.Split(envAllowedChangeRefTypes, ",")
		for i := range allowedChangeRefTypes {
			allowedChangeRefTypes[i] = strings.TrimSpace(allowedChangeRefTypes[i])
		}
	}

	client, err := newClient(openShiftAPIHost, triggerSecret)
	if err != nil {
		log.Fatalln(err)
	}

	namespace, err := getFileContent(namespaceFile)
	if err != nil {
		log.Fatalln(err)
	}

	project := strings.TrimSuffix(namespace, namespaceSuffix)

	server := &Server{
		Client:                  client,
		Namespace:               namespace,
		Project:                 project,
		TriggerSecret:           triggerSecret,
		ProtectedBranches:       protectedBranches,
		AcceptedEvents:          acceptedEvents,
		AllowedExternalProjects: allowedExternalProjects,
		AllowedChangeRefTypes:   allowedChangeRefTypes,
		RepoBase:                repoBase,
	}

	log.Println("Ready to accept requests")

	mux := http.NewServeMux()
	mux.Handle("/", server.HandleRoot())
	log.Fatal(http.ListenAndServe(":8080", mux))
}

// HandleRoot handles all requests to this service.
func (s *Server) HandleRoot() http.HandlerFunc {
	type repository struct {
		Project struct {
			Key string `json:"key"`
		} `json:"project"`
		Slug string `json:"slug"`
	}
	type requestBitbucket struct {
		EventKey   string     `json:"eventKey"`
		Repository repository `json:"repository"`
		Changes    []struct {
			Type string `json:"type"`
			Ref  struct {
				DisplayID string `json:"displayId"`
				Type      string `json:"type"`
			} `json:"ref"`
		} `json:"changes"`
		PullRequest *struct {
			FromRef struct {
				Repository repository `json:"repository"`
				DisplayID  string     `json:"displayId"`
			} `json:"fromRef"`
		} `json:"pullRequest"`
	}

	type requestBuild struct {
		Branch     string    `json:"branch"`
		Repository string    `json:"repository"`
		Env        []EnvPair `json:"env"`
		Project    string    `json:"project"`
	}

	var (
		init sync.Once
		tmpl *template.Template
		err  error
	)
	return func(w http.ResponseWriter, r *http.Request) {
		requestID := randStringBytes(6)
		log.Println(requestID, "-----")

		init.Do(func() {
			tmpl, err = template.ParseFiles(pipelineConfigFilename)
		})
		if err != nil {
			log.Println(requestID, err.Error())
			http.Error(w, "Could not parse pipeline config template", http.StatusInternalServerError)
			return
		}

		queryValues := r.URL.Query()
		triggerSecretParam := queryValues.Get("trigger_secret")
		if triggerSecretParam != s.TriggerSecret {
			log.Println(requestID, "trigger_secret param not given / not matching")
			http.Error(w, "Not authorized", http.StatusUnauthorized)
			return
		}

		jenkinsfilePath := jenkinsfilePathDefault
		jenkinsfilePathParam := queryValues.Get("jenkinsfile_path")
		if jenkinsfilePathParam != "" {
			jenkinsfilePath = jenkinsfilePathParam
		}

		componentParam := queryValues.Get("component")

		var project string
		var event *Event

		if strings.HasPrefix(r.URL.Path, "/build") {
			req := &requestBuild{}
			err := json.NewDecoder(r.Body).Decode(req)
			if err != nil {
				msg := fmt.Sprintf("Cannot parse JSON: %s", err)
				log.Println(requestID, msg)
				http.Error(w, msg, http.StatusBadRequest)
				return
			}

			project, err = s.readProjectParam(req.Project, requestID)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}

			component := componentParam
			if component == "" {
				component = extractComponent(req.Repository, project)
			}
			pipeline := makePipelineName(project, component, req.Branch)

			event = &Event{
				Kind:      "forward",
				Namespace: s.Namespace,
				Repo:      req.Repository,
				Component: component,
				Branch:    req.Branch,
				Pipeline:  pipeline,
				RequestID: requestID,
				Env:       req.Env,
			}

		} else if r.URL.Path == "/" {

			req := &requestBitbucket{}
			err := json.NewDecoder(r.Body).Decode(req)
			if err != nil {
				msg := fmt.Sprintf("Cannot parse JSON: %s", err)
				log.Println(requestID, msg)
				http.Error(w, msg, http.StatusBadRequest)
				return
			}

			var repo string
			var kind string
			var branch string
			component := componentParam

			project, err = s.readProjectParam(req.Repository.Project.Key, requestID)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}

			// When Bitbucket tests the connection, event is empty, so we skip
			// the request and return "OK".
			if len(req.EventKey) == 0 {
				log.Println(requestID, "Skipping request with unspecified event")
				return
			}

			if !includes(s.AcceptedEvents, req.EventKey) {
				log.Println(requestID, fmt.Sprintf(
					"Skipping event %s as %s does not include it",
					req.EventKey,
					acceptedEventsEnvVar,
				))
				return
			}

			// Skip requests with where the ref id is starting with "refs/notes/"
			// Reference 1: https://community.atlassian.com/t5/Bitbucket-questions/disable-quot-git-notes-add-quot-behaviour-for-semantic-release/qaq-p/1837322
			// Reference 2: https://github.com/semantic-release/semantic-release/discussions/2017#discussioncomment-995308
			if len(req.Changes) > 0 && strings.Contains(req.Changes[0].Ref.DisplayID, "refs/notes/") {
				log.Println(requestID, "Skipping request with refs/notes/ prefix in ref id")
				// Return 200 OK to Bitbucket to avoid retries
				http.Error(w, "OK", http.StatusOK)
				return
			}

			if req.EventKey == "repo:refs_changed" {
				repo = req.Repository.Slug
				if component == "" {
					component = extractComponent(repo, project)
				}
				branch = req.Changes[0].Ref.DisplayID
				if req.Changes[0].Type == "DELETE" {
					kind = "delete"
				} else {
					kind = "forward"
				}
				if !includes(s.AllowedChangeRefTypes, req.Changes[0].Ref.Type) {
					log.Println(requestID, fmt.Sprintf(
						"Skipping change ref type %s as %s does not include it",
						req.Changes[0].Ref.Type,
						allowedChangeRefTypesEnvVar,
					))
					return
				}
			} else if req.EventKey == "pr:opened" || req.EventKey == "pr:merged" || req.EventKey == "pr:declined" || req.EventKey == "pr:deleted" {
				repo = req.PullRequest.FromRef.Repository.Slug
				if component == "" {
					component = extractComponent(repo, project)
				}
				branch = req.PullRequest.FromRef.DisplayID
				if req.EventKey == "pr:opened" {
					kind = "forward"
				} else {
					kind = "delete"
				}
			}

			pipeline := makePipelineName(project, component, branch)

			event = &Event{
				Kind:      kind,
				Namespace: s.Namespace,
				Repo:      repo,
				Component: component,
				Branch:    branch,
				Pipeline:  pipeline,
				RequestID: requestID,
			}
		} else {
			http.NotFound(w, r)
			return
		}

		log.Println(requestID, event)

		if !event.IsValid() {
			msg := "Invalid input"
			log.Println(requestID, msg)
			http.Error(w, msg, http.StatusBadRequest)
			return
		}

		if event.Kind == "forward" {
			gitURI := fmt.Sprintf(
				"%s/%s/%s.git",
				s.RepoBase,
				project,
				event.Repo,
			)
			env, marshalErr := json.Marshal(event.Env)
			if marshalErr != nil {
				log.Println(requestID, fmt.Sprintf("Cannot convert envs to JSON: %s", marshalErr))
				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
				return
			}

			bcExists, bcBody, getErr := s.Client.GetPipeline(event)
			if getErr != nil {
				msg := "Could not check for existing pipeline"
				log.Println(requestID, fmt.Sprintf("%s: %s", msg, getErr))
				http.Error(w, msg, http.StatusInternalServerError)
				return
			}

			updatePipeline := false
			resourceVersion := "0"
			// Check if we need to update an existing pipeline
			if bcExists {
				bc := buildConfig{}
				unmarshalErr := json.Unmarshal(bcBody, &bc)
				if unmarshalErr != nil {
					msg := "Could not read existing pipeline"
					log.Println(requestID, fmt.Sprintf("%s: %s", msg, unmarshalErr))
					http.Error(w, msg, http.StatusInternalServerError)
					return
				}
				if bc.Spec.Source.Git.Ref != event.Branch {
					log.Println(requestID, fmt.Sprintf(
						"Current branch %s differs from requested branch %s", bc.Spec.Source.Git.Ref, event.Branch,
					))
					updatePipeline = true
					resourceVersion = bc.Metadata.ResourceVersion
				}
				if bc.Spec.Strategy.JenkinsPipelineStrategy.JenkinsfilePath != jenkinsfilePath {
					log.Println(requestID, fmt.Sprintf(
						"Current jenkinsfilePath %s differs from requested jenkinsfilePath %s",
						bc.Spec.Strategy.JenkinsPipelineStrategy.JenkinsfilePath,
						jenkinsfilePath,
					))
					updatePipeline = true
					resourceVersion = bc.Metadata.ResourceVersion
				}
				if bc.Spec.Triggers.Generic.Secret == "" {
					log.Println(requestID, fmt.Sprintf(
						"Trigger secret does not exists, updating pipeline",
					))
					updatePipeline = true
					resourceVersion = bc.Metadata.ResourceVersion
				}
			}

			buildConfigData := BuildConfigData{
				Name:            event.Pipeline,
				TriggerSecret:   s.TriggerSecret,
				GitURI:          gitURI,
				Branch:          event.Branch,
				JenkinsfilePath: jenkinsfilePath,
				Env:             string(env),
				ResourceVersion: resourceVersion,
			}

			// create or update
			if !bcExists || updatePipeline {
				createStatusCode, createErr := s.Client.CreateOrUpdatePipeline(bcExists, tmpl, event, buildConfigData)
				if createErr != nil {
					msg := "Could not create/update pipeline"
					log.Println(requestID, fmt.Sprintf("%s [%d]: %s", msg, createStatusCode, createErr))
					http.Error(w, msg, createStatusCode)
					return
				}
			}
			forwardStatusCode, forwardBody, forwardErr := s.Client.Forward(event, s.TriggerSecret)
			if forwardErr != nil {
				log.Println(requestID, forwardErr)
				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
				return
			}
			if forwardStatusCode < 200 || forwardStatusCode >= 300 {
				msg := "Could not trigger pipeline"
				log.Println(requestID, fmt.Sprintf("%s [%d]: %s", msg, forwardStatusCode, forwardBody))
				http.Error(w, msg, forwardStatusCode)
				return
			}
			_, writeErr := w.Write(forwardBody)
			if writeErr != nil {
				log.Println(requestID, fmt.Sprintf("Could not write response: %s", writeErr))
				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
				return
			}

		} else if event.Kind == "delete" {
			protected := isProtectedBranch(s.ProtectedBranches, event.Branch)
			if protected {
				log.Println(
					requestID,
					event.Branch,
					"is protected - its pipeline will not be deleted",
				)
				return
			}
			err := s.Client.DeletePipeline(event)
			if err != nil {
				log.Println(requestID, err)
				return
			}
		} else {
			log.Println(requestID, "Unrecognized event")
		}
	}
}

func (s *Server) readProjectParam(projectParam string, requestID string) (string, error) {
	projectParam = strings.ToLower(projectParam)
	if len(projectParam) > 0 {
		if s.Project != projectParam && !includes(s.AllowedExternalProjects, projectParam) {
			err := errors.New("Cannot proxy for given project")
			log.Println(requestID, fmt.Sprintf("%s: %s is not in %s=%s", err, projectParam, allowedExternalProjectsEnvVar, s.AllowedExternalProjects))
			return "", err
		}
		return projectParam, nil
	}
	return strings.ToLower(s.Project), nil
}

// Forward forwards a webhook event payload to the correct pipeline.
func (c *ocClient) Forward(e *Event, triggerSecret string) (int, []byte, error) {
	url := fmt.Sprintf(
		"%s/namespaces/%s/buildconfigs/%s/webhooks/%s/generic",
		c.OpenShiftAPIBaseURL,
		e.Namespace,
		e.Pipeline,
		triggerSecret,
	)

	c.CheckJenkinsAvailability(e)
	c.CheckDocGenAvailability(e)

	log.Println(e.RequestID, "Forwarding to", url)

	p := struct {
		Env []EnvPair `json:"env"`
	}{
		Env: e.Env,
	}
	b := new(bytes.Buffer)
	err := json.NewEncoder(b).Encode(p)
	if err != nil {
		return 500, nil, fmt.Errorf("Could not encode payload: %s", err)
	}

	req, _ := http.NewRequest("POST", url, b)
	res, err := c.do(req)
	if err != nil {
		return 500, nil, fmt.Errorf("Got error %s", err)
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	return res.StatusCode, body, err
}

// CreateOrUpdatePipeline ensures that the pipeline which corresponds to the
// received event exists in OpenShift.
// It returns any errors, the status code and the response body
func (c *ocClient) CreateOrUpdatePipeline(exists bool, tmpl *template.Template, e *Event, data BuildConfigData) (int, error) {
	jsonBuffer, err := getBuildConfig(tmpl, data)
	if err != nil {
		return 500, err
	}

	url := fmt.Sprintf(
		"%s/namespaces/%s/buildconfigs",
		c.OpenShiftAPIBaseURL,
		e.Namespace,
	)
	verb := "POST"
	if exists {
		verb = "PUT"
		url = fmt.Sprintf("%s/%s", url, data.Name)
	}
	req, _ := http.NewRequest(verb, url, jsonBuffer)
	res, err := c.do(req)
	if err != nil {
		return 500, fmt.Errorf("could not make OpenShift request: %s", err)
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return 500, fmt.Errorf("could not read OpenShift response body: %s", err)
	}

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return res.StatusCode, fmt.Errorf("unexpected return code for %s %s: %s", verb, url, body)
	}

	log.Println(e.RequestID, "Created pipeline", e.Pipeline)

	return res.StatusCode, nil
}

// DeletePipeline removes the pipeline corresponding to the event from
// OpenShift.
func (c *ocClient) DeletePipeline(e *Event) error {
	url := fmt.Sprintf(
		"%s/namespaces/%s/buildconfigs/%s?propagationPolicy=Foreground",
		c.OpenShiftAPIBaseURL,
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
		return fmt.Errorf("could not make OpenShift request: %s", err)
	}
	defer res.Body.Close()

	body, _ := ioutil.ReadAll(res.Body)

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return errors.New(string(body))
	}

	log.Println(e.RequestID, "Deleted pipeline", e.Pipeline)

	return nil
}

// Check that Jenkins is up in case the service is idle in OpenShift.
func (c *ocClient) CheckJenkinsAvailability(e *Event) {
	url := fmt.Sprintf(
		"http://jenkins.%s.svc.cluster.local",
		e.Namespace,
	)
	req, _ := http.NewRequest(
		"GET",
		url,
		nil,
	)

	res, err := c.do(req)

	if err != nil {
		log.Println(e.RequestID, "Jenkins not reachable, if idled it will scale up in namespace", e.Namespace)
	} else {
		if res.StatusCode == 200 {
			log.Println(e.RequestID, "Jenkins available in namespace", e.Namespace)
		} else {
			log.Println(e.RequestID, "Jenkins not available, status code is", res.StatusCode)
		}
	}
}

// Check that DocGen is up in case the service is idle in OpenShift.
func (c *ocClient) CheckDocGenAvailability(e *Event) {
	url := fmt.Sprintf(
		"http://docgen.%s:8080",
		e.Namespace,
	)
	req, _ := http.NewRequest(
		"GET",
		url,
		nil,
	)

	res, err := c.do(req)

	if err != nil {
		log.Println(e.RequestID, "DocGen not reachable, if idled it will scale up in namespace", e.Namespace)
	} else {
		if res.StatusCode == 200 {
			log.Println(e.RequestID, "DocGen available in namespace", e.Namespace)
		} else {
			log.Println(e.RequestID, "DocGen not available, status code is", res.StatusCode)
		}
	}
}

// GetPipeline determines whether the pipeline corresponding to the given
// event already exists.
func (c *ocClient) GetPipeline(e *Event) (bool, []byte, error) {
	url := fmt.Sprintf(
		"%s/namespaces/%s/buildconfigs/%s",
		c.OpenShiftAPIBaseURL,
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
		return false, nil, fmt.Errorf("could not make OpenShift request: %s", err)
	}
	defer res.Body.Close()

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return false, nil, nil
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return false, nil, fmt.Errorf("could not read OpenShift response: %s", err)
	}

	return true, body, nil
}

// do executes the request.
func (c *ocClient) do(req *http.Request) (*http.Response, error) {
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.Token)
	return c.HTTPClient.Do(req)
}

// IsValid performs basic snaity checks for event values.
func (e *Event) IsValid() bool {
	// Only forward and delete are recognized right now.
	if e.Kind != "forward" && e.Kind != "delete" {
		return false
	}
	// Pipeline consists of at least one char component, a dash and one char branch.
	if len(e.Pipeline) < 3 {
		return false
	}
	return len(e.Namespace) > 0 && len(e.Repo) > 0 && len(e.Component) > 0 && len(e.Branch) > 0
}

func (e *Event) String() string {
	return fmt.Sprintf(
		"kind=%s, namespace=%s, repo=%s, component=%s, branch=%s, pipeline=%s",
		e.Kind,
		e.Namespace,
		e.Repo,
		e.Component,
		e.Branch,
		e.Pipeline,
	)
}

func newClient(openShiftAPIHost string, triggerSecret string) (*ocClient, error) {
	token, err := getFileContent(tokenFile)
	if err != nil {
		return nil, fmt.Errorf("Could not get token: %s", err)
	}

	secureClient, err := getSecureClient()
	if err != nil {
		return nil, fmt.Errorf("Could not get client: %s", err)
	}

	baseURL := fmt.Sprintf(
		"https://%s%s",
		openShiftAPIHost,
		buildAPIBasePath,
	)

	return &ocClient{
		HTTPClient:          secureClient,
		OpenShiftAPIBaseURL: baseURL,
		Token:               token,
	}, nil
}

func getBuildConfig(tmpl *template.Template, data BuildConfigData) (*bytes.Buffer, error) {
	b := bytes.NewBuffer([]byte{})
	err := tmpl.Execute(b, data)
	if err != nil {
		return nil, fmt.Errorf("Could not fill template %s", pipelineConfigFilename)
	}
	return b, nil
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
	// Deprecated.
	// The Config.NameToCertificate field, which only supports associating a
	// single certificate with a give name, is now deprecated and should be
	// left as nil. https://go.dev/pkg/crypto/tls/
	// tlsConfig.BuildNameToCertificate()
	transport := &http.Transport{TLSClientConfig: tlsConfig}
	return &http.Client{Transport: transport, Timeout: 10 * time.Second}, nil
}

func getFileContent(filename string) (string, error) {
	content, err := ioutil.ReadFile(filename)
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

// makePipelineName generates the name of the pipeline based on given project,
// component and branch. It basically concatenates component and branch, but
// if the branch contains a ticket ID (KEY-123), then only this ID is appended
// to the component.
// According to the Kubernetes label rules, a maximum of 63 characters is
// allowed, see https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set.
// Therefore, the name might be truncated. As this could cause potential clashes
// between similar named branches, we put a short part of the branch hash value
// into the name name to make this very unlikely.
func makePipelineName(project string, component string, branch string) string {
	pipeline := strings.ToLower(component) + "-"
	// Extract ticket ID from branch name if present
	lowercaseBranch := strings.ToLower(branch)
	lowercaseProject := strings.ToLower(project)
	ticketRegex := regexp.MustCompile(".*" + lowercaseProject + "-([0-9]+)")
	matches := ticketRegex.FindStringSubmatch(lowercaseBranch)
	if len(matches) > 0 {
		pipeline = pipeline + matches[1]
	} else {
		// Cut all non-alphanumeric characters
		safeCharsRegex := regexp.MustCompile("[^-a-zA-Z0-9]+")
		pipeline = pipeline + safeCharsRegex.ReplaceAllString(
			strings.Replace(lowercaseBranch, "/", "-", -1),
			"",
		)
	}
	// Enforce maximum length - and if truncation needs to happen,
	// ensure uniqueness of pipeline name as much as possible.
	if len(pipeline) > 63 {
		shortenedPipeline := pipeline[0:55]
		h := sha1.New()
		_, err := h.Write([]byte(pipeline))
		if err != nil {
			return shortenedPipeline
		}
		bs := h.Sum(nil)
		s := fmt.Sprintf("%x", bs)
		pipeline = fmt.Sprintf("%s-%s", shortenedPipeline, s[0:7])
	}
	return pipeline
}

func isProtectedBranch(protectedBranches []string, branch string) bool {
	for _, b := range protectedBranches {
		if b == "*" {
			return true
		}
		if strings.HasSuffix(b, "/") && strings.HasPrefix(branch, b) {
			return true
		}
		if b == branch {
			return true
		}
	}
	return false
}

// extractComponent returns the component part of the given repository.
// The component is equal to the repository without any project prefix.
func extractComponent(repository, project string) string {
	return strings.TrimPrefix(strings.ToLower(repository), strings.ToLower(project+"-"))
}

// includes checks if needle is in haystack
func includes(haystack []string, needle string) bool {
	for _, name := range haystack {
		if name == needle {
			return true
		}
	}
	return false
}
