package main

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"reflect"
	"strings"
	"testing"
	"text/template"
)

// SETUP
func TestMain(m *testing.M) {
	log.SetOutput(ioutil.Discard)
	os.Exit(m.Run())
}

func TestMakePipelineName(t *testing.T) {
	tests := map[string]struct {
		project   string
		component string
		branch    string
		expected  string
	}{
		"ticket ID with following text": {
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/PRJ-529-bar-6-baz",
			expected:  "comp-529",
		},
		"bare ticket id": {
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/PRJ-529",
			expected:  "comp-529",
		},
		"case insensitive comparison of project": {
			project:   "pRJ",
			component: "comp",
			branch:    "bugfix/Prj-529-bar-6-baz",
			expected:  "comp-529",
		},
		"case insensitive comparison of component": {
			// component appears in lowercase in pipeline
			project:   "PRJ",
			component: "ComP",
			branch:    "bugfix/PRJ-529-bar-6-baz",
			expected:  "comp-529",
		},
		"missing project in request": {
			project:   "",
			component: "comp",
			branch:    "bugfix/PRJ-529-bar-6-baz",
			expected:  "comp-6",
		},
		"missing project in branch": {
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/äü",
			expected:  "comp-bugfix-",
		},
		"multiple ticket ID candidates in branch": {
			// assert current behavior, but could be changed in the future.
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/PRJ-529-PRJ-777-bar-6-baz",
			expected:  "comp-777",
		},
		"multiple ticket ID candidates in branch with slashes": {
			// assert current behavior, but could be changed in the future.
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/PRJ-529/PRJ-777-bar-6-baz",
			expected:  "comp-777",
		},
		// Cases which leads to pipeline string of
		// {comp}-{sanitized(branch)}
		"project is a prefix or project in branch": {
			project:   "PR",
			component: "comp",
			branch:    "bugfix/PRJ-529-bar-6-baz",
			expected:  "comp-bugfix-prj-529-bar-6-baz",
		},
		"project in branch is a prefix of project": {
			project:   "PRJL",
			component: "comp",
			branch:    "bugfix/PRJ-529-bar-6-baz",
			expected:  "comp-bugfix-prj-529-bar-6-baz",
		},
		"missing '-' between project and number": {
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/PRJ529-bar-6-baz",
			expected:  "comp-bugfix-prj529-bar-6-baz",
		},
		"branch name is too long": {
			project:   "PRJ",
			component: "comp",
			branch:    "bugfix/some-arbitarily-long-branch-name-that-should-be-way-shorter",
			expected:  "comp-bugfix-some-arbitarily-long-branch-name-that-shoul-87136df",
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			pipeline := makePipelineName(tc.project, tc.component, tc.branch)
			if tc.expected != pipeline {
				t.Fatalf(
					"Expected '%s' but '%s' returned by makePipeline(project='%s', component='%s', branch='%s')",
					tc.expected,
					pipeline,
					tc.project,
					tc.component,
					tc.branch,
				)
			}
			if len(tc.expected) > 63 {
				t.Fatalf("'%s' is longer than 63 characters (%d) which is not allowed", tc.expected, len(tc.expected))
			}
		})
	}
}

func TestIsProtectedBranch(t *testing.T) {
	tests := []struct {
		protectedBranchs []string
		branch           string
		expected         bool
	}{
		{
			[]string{"master"},
			"develop",
			false,
		},
		{
			[]string{"master", "develop"},
			"develop",
			true,
		},
		{
			[]string{"*"},
			"develop",
			true,
		},
		{
			[]string{"master", "release/"},
			"release/v1",
			true,
		},
		{
			[]string{"master", "release/"},
			"release",
			false,
		},
		{
			[]string{"hotfix/"},
			"feature/v2",
			false,
		},
	}

	for _, tt := range tests {
		actual := isProtectedBranch(tt.protectedBranchs, tt.branch)
		if tt.expected != actual {
			t.Errorf(
				"Expected '%v' but '%v' returned by isProtectedBranch(protectedBranchs='%s', branch='%s')",
				tt.expected,
				actual,
				tt.protectedBranchs,
				tt.branch,
			)
		}
	}
}

type mockClient struct {
	Event *Event
}

func (c *mockClient) Forward(e *Event, triggerSecret string) (int, []byte, error) {
	c.Event = e
	return 200, nil, nil
}
func (c *mockClient) GetPipeline(e *Event) (bool, []byte, error) {
	c.Event = e
	return false, nil, nil
}
func (c *mockClient) CreateOrUpdatePipeline(exists bool, tmpl *template.Template, e *Event, data BuildConfigData) (int, error) {
	c.Event = e
	return 0, nil
}
func (c *mockClient) DeletePipeline(e *Event) error {
	c.Event = e
	return nil
}
func (c *mockClient) CheckAvailability(e *Event) {
	c.Event = e
}


func testServer() (*httptest.Server, *mockClient) {
	mc := &mockClient{}
	server := &Server{
		Client:                  mc,
		Namespace:               "bar-cd",
		Project:                 "bar",
		TriggerSecret:           "s3cr3t",
		ProtectedBranches:       []string{"baz"},
		AcceptedEvents:          []string{"repo:refs_changed", "pr:opened", "pr:declined", "pr:merged", "pr:deleted"},
		AllowedExternalProjects: []string{"opendevstack"},
		AllowedChangeRefTypes:   []string{"BRANCH"},
		RepoBase:                "https://domain.com",
	}
	return httptest.NewServer(server.HandleRoot()), mc
}

func TestHandleRootRequiresTriggerSecret(t *testing.T) {
	ts, mc := testServer()
	defer ts.Close()

	tests := map[string]struct {
		URL string
	}{
		"without trigger_secret param:":   {ts.URL},
		"with empty trigger_secret param": {ts.URL + "?trigger_secret="},
		"with wrong trigger_secret param": {ts.URL + "?trigger_secret=abc"},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			f, err := os.Open("testdata/fixtures/repo-refs-changed-payload.json")
			if err != nil {
				t.Error(err)
				return
			}
			res, err := http.Post(tc.URL, "application/json", f)
			if err != nil {
				t.Error(err)
				return
			}
			expected := http.StatusUnauthorized
			actual := res.StatusCode
			if expected != actual {
				t.Fatalf("Got status %v, want %v", actual, expected)
			}
			if mc.Event != nil {
				t.Fatalf("Event was %v, want nil", mc.Event)
			}
		})
	}

}

func TestHandleRootReadsRequests(t *testing.T) {
	ts, mc := testServer()
	defer ts.Close()

	// The expected events depend on the values in the payload files.
	tests := map[string]struct {
		payloadFile   string
		expectedEvent *Event
	}{
		"Refs changed": {
			payloadFile: "repo-refs-changed-payload.json",
			expectedEvent: &Event{
				Kind:      "forward",
				Namespace: "bar-cd",
				Repo:      "repository",
				Component: "repository",
				Branch:    "master",
				Pipeline:  "repository-master",
			},
		},
		"PR merged": {
			payloadFile: "pr-merged-payload.json",
			expectedEvent: &Event{
				Kind:      "delete",
				Namespace: "bar-cd",
				Repo:      "repository",
				Component: "repository",
				Branch:    "admin/file-1505781548644",
				Pipeline:  "repository-admin-file-1505781548644",
			},
		},
		"PR declined": {
			payloadFile: "pr-declined-payload.json",
			expectedEvent: &Event{
				Kind:      "delete",
				Namespace: "bar-cd",
				Repo:      "repository",
				Component: "repository",
				Branch:    "decline-me",
				Pipeline:  "repository-decline-me",
			},
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			f, err := os.Open("testdata/fixtures/" + tc.payloadFile)
			if err != nil {
				t.Fatal(err)
			}
			// Use secret defined in fake server.
			res, err := http.Post(ts.URL+"?trigger_secret=s3cr3t", "application/json", f)
			if err != nil {
				t.Fatal(err)
			}
			_, err = ioutil.ReadAll(res.Body)
			res.Body.Close()
			if err != nil {
				t.Fatal(err)
			}

			expected := http.StatusOK
			actual := res.StatusCode
			if expected != actual {
				t.Fatalf("Got status: %v, want: %v", actual, expected)
			}

			// RequestID cannot be known in advance, so set it now from actual value.
			if mc.Event == nil {
				t.Fatal("Event of mock client is not set")
			}
			tc.expectedEvent.RequestID = mc.Event.RequestID
			if !reflect.DeepEqual(tc.expectedEvent, mc.Event) {
				t.Fatalf("Got event: %v, want: %v", mc.Event, tc.expectedEvent)
			}
		})
	}
}

func TestSkipsPayloads(t *testing.T) {
	// The expected events depend on the values in the payload files.
	tests := map[string]struct {
		acceptedEvents []string
		payloadFile    string
		expectedLog    string
	}{
		"Tag pushed": {
			acceptedEvents: []string{"repo:refs_changed", "pr:opened", "pr:declined", "pr:merged", "pr:deleted"},
			payloadFile:    "repo-refs-changed-tag-payload.json",
			expectedLog:    "Skipping change ref type TAG as ALLOWED_CHANGE_REF_TYPES does not include it",
		},
		"Unknown event": {
			acceptedEvents: []string{"repo:refs_changed", "pr:opened", "pr:declined", "pr:merged", "pr:deleted"},
			payloadFile:    "unknown-event-payload.json",
			expectedLog:    "Skipping event foo:bar as ACCEPTED_EVENTS does not include it",
		},
		"Unaccepted event": {
			acceptedEvents: []string{"repo:refs_changed", "pr:declined", "pr:merged", "pr:deleted"},
			payloadFile:    "unaccepted-event-payload.json",
			expectedLog:    "Skipping event pr:opened as ACCEPTED_EVENTS does not include it",
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			mc := &mockClient{}
			server := &Server{
				Client:                  mc,
				Namespace:               "bar-cd",
				Project:                 "bar",
				TriggerSecret:           "s3cr3t",
				ProtectedBranches:       []string{"baz"},
				AcceptedEvents:          tc.acceptedEvents,
				AllowedExternalProjects: []string{"opendevstack"},
				AllowedChangeRefTypes:   []string{"BRANCH"},
				RepoBase:                "https://domain.com",
			}
			ts := httptest.NewServer(server.HandleRoot())
			defer ts.Close()

			f, err := os.Open("testdata/fixtures/" + tc.payloadFile)
			if err != nil {
				t.Fatal(err)
			}
			var buf bytes.Buffer
			log.SetOutput(&buf)
			defer func() {
				log.SetOutput(os.Stderr)
			}()
			// Use secret defined in fake server.
			res, err := http.Post(ts.URL+"?trigger_secret=s3cr3t", "application/json", f)
			if err != nil {
				t.Fatal(err)
			}
			_, err = ioutil.ReadAll(res.Body)
			res.Body.Close()
			if err != nil {
				t.Fatal(err)
			}

			want := http.StatusOK
			got := res.StatusCode
			if want != got {
				t.Fatalf("Got status: %d, want: %d", got, want)
			}

			gotLog := buf.String()
			if !strings.Contains(gotLog, tc.expectedLog) {
				t.Fatalf("Got log:\n%s\nwant:\n%s", gotLog, tc.expectedLog)
			}
		})
	}
}

func TestNamespaceRestriction(t *testing.T) {
	tests := map[string]struct {
		payloadFile             string
		project                 string
		allowedExternalProjects []string
		expectedPipeline        string
		expectedStatusCode      int
	}{
		"Prov App": {
			payloadFile:             "prov-app-changed-payload.json",
			project:                 "prov",
			allowedExternalProjects: []string{"opendevstack"},
			expectedPipeline:        "prov-app-pipeline.json",
			expectedStatusCode:      200,
		},
		"Other": {
			payloadFile:             "prov-app-changed-payload.json",
			project:                 "foo",
			allowedExternalProjects: []string{"baz"},
			expectedPipeline:        "",
			expectedStatusCode:      400,
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			var expectedOpenshiftPayload []byte
			var err error
			if len(tc.expectedPipeline) > 0 {
				expectedOpenshiftPayload, err = ioutil.ReadFile("testdata/golden/" + tc.expectedPipeline)
				if err != nil {
					t.Fatal(err)
				}
			}

			var actualOpenshiftPayload []byte
			// Create OpenShift stub: Returns 404 when asked for a pipeline,
			// and writes the body of the request to +actual+  when pipeline
			// is to be created.
			apiStub := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if strings.HasSuffix(r.URL.Path, "/buildconfigs") && r.Method == "POST" {
					actualOpenshiftPayload, _ = ioutil.ReadAll(r.Body)
				}
				if strings.Contains(r.URL.Path, "/buildconfigs/") && r.Method == "GET" {
					http.Error(w, "Not found", http.StatusNotFound)
					return
				}
				w.WriteHeader(200)
				_, err := w.Write([]byte(""))
				if err != nil {
					t.Fatal(err)
				}
			}))

			// Client pointing to the API stub created above
			c := &ocClient{
				HTTPClient:          &http.Client{},
				OpenShiftAPIBaseURL: apiStub.URL,
				Token:               "foo",
			}
			// Server using the special client
			fakeSecret := "s3cr3t"
			s := &Server{
				Client:                  c,
				Namespace:               tc.project + "-cd",
				Project:                 tc.project,
				TriggerSecret:           fakeSecret,
				ProtectedBranches:       []string{"baz"},
				AcceptedEvents:          []string{"repo:refs_changed", "pr:opened", "pr:declined", "pr:merged", "pr:deleted"},
				AllowedExternalProjects: tc.allowedExternalProjects,
				AllowedChangeRefTypes:   []string{"BRANCH"},
				RepoBase:                "https://domain.com",
			}
			ts := httptest.NewServer(s.HandleRoot())
			defer ts.Close()

			f, err := os.Open("testdata/fixtures/" + tc.payloadFile)
			if err != nil {
				t.Fatal(err)
			}
			res, err := http.Post(ts.URL+"?trigger_secret="+fakeSecret, "application/json", f)
			if err != nil {
				t.Fatal(err)
			}
			_, err = ioutil.ReadAll(res.Body)
			res.Body.Close()
			if err != nil {
				t.Fatal(err)
			}
			if res.StatusCode != tc.expectedStatusCode {
				t.Fatalf("Got response %d, want: %d", res.StatusCode, tc.expectedStatusCode)
			}

			if len(expectedOpenshiftPayload) > 0 && string(actualOpenshiftPayload) != string(expectedOpenshiftPayload) {
				t.Fatalf("Got request body: %s, want: %s", actualOpenshiftPayload, expectedOpenshiftPayload)
			}
		})
	}
}

func TestForward(t *testing.T) {
	tests := map[string]struct {
		expectedPayload            string // payload that the OpenShift stub expects to be called with
		openshiftResponse          string // payload that OpenShift stub returns to proxy
		openshiftStatusCode        int    // code that OpenShift stub returns to proxy
		expectedReturnedStatusCode int    // code that we expect to get from OpenShift stub
		event                      *Event
	}{
		"event without env": {
			expectedPayload:            "testdata/golden/forward-payload-without-env.json",
			openshiftResponse:          "testdata/fixtures/webhook-triggered-payload.json",
			openshiftStatusCode:        200,
			expectedReturnedStatusCode: 200,
			event: &Event{
				Kind:      "forward",
				Namespace: "bar-cd",
				Repo:      "repository",
				Component: "repository",
				Branch:    "master",
				Pipeline:  "repository-master",
				Env:       []EnvPair{},
			},
		},
		"event with env": {
			expectedPayload:            "testdata/golden/forward-payload-with-env.json",
			openshiftResponse:          "testdata/fixtures/webhook-triggered-payload.json",
			openshiftStatusCode:        200,
			expectedReturnedStatusCode: 200,
			event: &Event{
				Kind:      "forward",
				Namespace: "bar-cd",
				Repo:      "repository",
				Component: "repository",
				Branch:    "master",
				Pipeline:  "repository-master",
				Env: []EnvPair{
					EnvPair{
						Name:  "PROJECT_ID",
						Value: "foo",
					},
					EnvPair{
						Name:  "COMPONENT_ID",
						Value: "bar",
					},
				},
			},
		},
		"authentication issue": {
			expectedPayload:            "testdata/golden/forward-payload-without-env.json",
			openshiftResponse:          "",
			openshiftStatusCode:        401,
			expectedReturnedStatusCode: 401,
			event: &Event{
				Kind:      "forward",
				Namespace: "bar-cd",
				Repo:      "repository",
				Component: "repository",
				Branch:    "master",
				Pipeline:  "repository-master",
				Env:       []EnvPair{},
			},
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			var actualForwardPayload []byte
			expectedPayload, err := ioutil.ReadFile(tc.expectedPayload)
			if err != nil {
				t.Fatal(err)
			}
			// Sample response from OpenShift
			var expectedOpenshiftResponse []byte
			if len(tc.openshiftResponse) > 0 {
				r, err := ioutil.ReadFile(tc.openshiftResponse)
				if err != nil {
					t.Fatal(err)
				}
				expectedOpenshiftResponse = r
			}

			// Create a stub that returns the fixed response
			apiStub := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				actualForwardPayload, _ = ioutil.ReadAll(r.Body)
				w.WriteHeader(tc.openshiftStatusCode)
				_, err := w.Write(expectedOpenshiftResponse)
				if err != nil {
					t.Fatal(err)
				}
			}))

			// Client pointing to the API stub created above
			c := &ocClient{
				HTTPClient:          &http.Client{},
				OpenShiftAPIBaseURL: apiStub.URL,
				Token:               "foo",
			}

			// Ensure the response from OpenShift is forwarded as-is to the client
			actualOpenshiftStatusCode, actualOpenshiftResponse, err := c.Forward(tc.event, "s3cr3t")
			if err != nil {
				t.Fatal(err)
			}
			if string(actualForwardPayload) != string(expectedPayload) {
				t.Fatalf("Got payload: %s, want: %s", actualForwardPayload, expectedPayload)
			}
			if actualOpenshiftStatusCode != tc.expectedReturnedStatusCode {
				t.Fatalf("Got HTTP code: %d, want: %d", actualOpenshiftStatusCode, tc.expectedReturnedStatusCode)
			}
			if len(expectedOpenshiftResponse) > 0 {
				if string(actualOpenshiftResponse) != string(expectedOpenshiftResponse) {
					t.Fatalf("Got response: %s, want: %s", actualOpenshiftResponse, expectedOpenshiftResponse)
				}
			}
		})
	}
}

func TestBuildEndpoint(t *testing.T) {
	tests := map[string]struct {
		whpPath                   string
		whpPayload                string
		whpExpectedResponseStatus int
		whpExpectedResponseBody   string
		bcGetResponseBody         string // response when asked for the pipeline
		bcUpsertExpectedPayload   string // expected payload of request to POST/PUT pipeline
		bcUpsertResponseBody      string // response when pipeline is created/updated
		bcUpsertResponseStatus    int    // code when pipeline is created/updated
	}{
		"request without trigger secret": {
			whpPath:                   "/build",
			whpPayload:                "testdata/fixtures/build-payload.json",
			whpExpectedResponseStatus: 401,
			whpExpectedResponseBody:   "",
			bcGetResponseBody:         "",
			bcUpsertExpectedPayload:   "",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    0,
		},
		"valid payload": {
			whpPath:                   "/build?trigger_secret=s3cr3t",
			whpPayload:                "testdata/fixtures/build-payload.json",
			whpExpectedResponseStatus: 200,
			whpExpectedResponseBody:   "",
			bcGetResponseBody:         "",
			bcUpsertExpectedPayload:   "testdata/golden/build-pipeline.json",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    201,
		},
		"valid payload with param": {
			whpPath:                   "/build?component=baz&trigger_secret=s3cr3t",
			whpPayload:                "testdata/fixtures/build-payload.json",
			whpExpectedResponseStatus: 200,
			whpExpectedResponseBody:   "",
			bcGetResponseBody:         "",
			bcUpsertExpectedPayload:   "testdata/golden/build-component-pipeline.json",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    201,
		},
		"broken payload": {
			whpPath:                   "/build?trigger_secret=s3cr3t",
			whpPayload:                "testdata/fixtures/build-broken-payload.txt",
			whpExpectedResponseStatus: 400,
			whpExpectedResponseBody:   "Cannot parse JSON: invalid character '\"' after object key:value pair\n",
			bcGetResponseBody:         "",
			bcUpsertExpectedPayload:   "",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    0,
		},
		"invalid payload": {
			whpPath:                   "/build?trigger_secret=s3cr3t",
			whpPayload:                "testdata/fixtures/build-invalid-payload.json",
			whpExpectedResponseStatus: 400,
			whpExpectedResponseBody:   "Invalid input\n",
			bcGetResponseBody:         "",
			bcUpsertExpectedPayload:   "",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    0,
		},
		"accepted payload rejected by OpenShift": {
			whpPath:                   "/build?trigger_secret=s3cr3t",
			whpPayload:                "testdata/fixtures/build-rejected-payload.json",
			whpExpectedResponseStatus: 422,
			whpExpectedResponseBody:   "Could not create/update pipeline\n",
			bcGetResponseBody:         "",
			bcUpsertExpectedPayload:   "",
			bcUpsertResponseBody:      "testdata/fixtures/build-rejected-openshift-response.json",
			bcUpsertResponseStatus:    422,
		},
		"existing pipeline with different jenkinsfile path": {
			whpPath:                   "/build?trigger_secret=s3cr3t&jenkinsfile_path=bar/Jenkinsfile",
			whpPayload:                "testdata/fixtures/build-payload.json",
			whpExpectedResponseStatus: 200,
			whpExpectedResponseBody:   "",
			bcGetResponseBody:         "testdata/fixtures/build-pipeline-jenkinsfilepath.json",
			bcUpsertExpectedPayload:   "testdata/golden/build-pipeline-jenkinsfilepath.json",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    201,
		},
		"existing pipeline with different branch": {
			whpPath:                   "/build?trigger_secret=s3cr3t",
			whpPayload:                "testdata/fixtures/build-payload.json",
			whpExpectedResponseStatus: 200,
			whpExpectedResponseBody:   "",
			bcGetResponseBody:         "testdata/fixtures/build-pipeline-branch.json",
			bcUpsertExpectedPayload:   "testdata/golden/build-pipeline-branch.json",
			bcUpsertResponseBody:      "",
			bcUpsertResponseStatus:    201,
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			// Expected payload to create the BuildConfig
			expectedOpenshiftPayload := []byte{}
			if tc.bcUpsertExpectedPayload != "" {
				e, err := ioutil.ReadFile(tc.bcUpsertExpectedPayload)
				if err != nil {
					t.Fatal(err)
				}
				expectedOpenshiftPayload = e
			}

			openshiftResponseBody := []byte{}
			if tc.bcUpsertResponseBody != "" {
				or, err := ioutil.ReadFile(tc.bcUpsertResponseBody)
				if err != nil {
					t.Fatal(err)
				}
				openshiftResponseBody = or
			}

			var actualOpenshiftPayload []byte
			// Create OpenShift stub: Returns 404 when asked for a pipeline,
			// and writes the body of the request to +actual+  when pipeline
			// is to be created.
			apiStub := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if strings.HasSuffix(r.URL.Path, "/buildconfigs") && r.Method == "POST" {
					actualOpenshiftPayload, _ = ioutil.ReadAll(r.Body)
				}
				if strings.Contains(r.URL.Path, "/buildconfigs/") && r.Method == "PUT" {
					actualOpenshiftPayload, _ = ioutil.ReadAll(r.Body)
				}
				if strings.Contains(r.URL.Path, "/buildconfigs/") && r.Method == "GET" {
					if len(tc.bcGetResponseBody) == 0 {
						http.Error(w, "Not found", http.StatusNotFound)
						return
					}
					w.WriteHeader(200)
					grb, err := ioutil.ReadFile(tc.bcGetResponseBody)
					if err != nil {
						t.Fatal(err)
					}
					_, err = w.Write(grb)
					if err != nil {
						t.Fatal(err)
					}
					return
				}
				w.WriteHeader(tc.bcUpsertResponseStatus)
				_, err := w.Write(openshiftResponseBody)
				if err != nil {
					t.Fatal(err)
				}
			}))

			// Client pointing to the API stub created above
			c := &ocClient{
				HTTPClient:          &http.Client{},
				OpenShiftAPIBaseURL: apiStub.URL,
				Token:               "foo",
			}
			// Server using the special client
			s := &Server{
				Client:                  c,
				Namespace:               "bar-cd",
				Project:                 "bar",
				TriggerSecret:           "s3cr3t",
				ProtectedBranches:       []string{"baz"},
				AcceptedEvents:          []string{"repo:refs_changed", "pr:opened", "pr:declined", "pr:merged", "pr:deleted"},
				AllowedExternalProjects: []string{"opendevstack"},
				AllowedChangeRefTypes:   []string{"BRANCH"},
				RepoBase:                "https://domain.com",
			}
			server := httptest.NewServer(s.HandleRoot())

			// Make request to /build with payload
			f, err := os.Open(tc.whpPayload)
			if err != nil {
				t.Fatal(err)
			}
			res, err := http.Post(server.URL+tc.whpPath, "application/json", f)
			if err != nil {
				t.Fatal(err)
			}

			if res.StatusCode != tc.whpExpectedResponseStatus {
				t.Fatalf("Got response %d, want: %d", res.StatusCode, tc.whpExpectedResponseStatus)
			}

			if len(expectedOpenshiftPayload) > 0 && string(actualOpenshiftPayload) != string(expectedOpenshiftPayload) {
				t.Fatalf("Got request body: %s, want: %s", actualOpenshiftPayload, expectedOpenshiftPayload)
			}

			actualBody, err := ioutil.ReadAll(res.Body)
			if err != nil {
				t.Fatal(err)
			}
			if len(tc.whpExpectedResponseBody) > 0 && string(actualBody) != tc.whpExpectedResponseBody {
				t.Fatalf("Got response body: %s, want: %s", actualBody, tc.whpExpectedResponseBody)
			}
		})
	}
}

func TestNotFound(t *testing.T) {
	// Server using a mocked client
	s := &Server{
		Client:                  &mockClient{},
		Namespace:               "bar-cd",
		Project:                 "bar",
		TriggerSecret:           "s3cr3t",
		ProtectedBranches:       []string{"baz"},
		AcceptedEvents:          []string{"repo:refs_changed", "pr:opened", "pr:declined", "pr:merged", "pr:deleted"},
		AllowedExternalProjects: []string{"opendevstack"},
		AllowedChangeRefTypes:   []string{"BRANCH"},
		RepoBase:                "https://domain.com",
	}
	server := httptest.NewServer(s.HandleRoot())

	res, err := http.Post(server.URL+"/foo?trigger_secret=s3cr3t", "application/json", nil)
	if err != nil {
		t.Fatal(err)
	}

	if res.StatusCode != http.StatusNotFound {
		t.Fatalf("Got status %d, want: %d", res.StatusCode, http.StatusNotFound)
	}
}

func TestGetBuildConfig(t *testing.T) {
	tmpl, err := template.ParseFiles(pipelineConfigFilename)
	if err != nil {
		t.Error(err)
	}
	e := []EnvPair{EnvPair{Name: "FOO", Value: "bar"}}
	env, _ := json.Marshal(e)
	data := BuildConfigData{
		Name:            "repository-master",
		TriggerSecret:   "s3cr3t",
		GitURI:          "https://domain.com/proj/repository.git",
		Branch:          "master",
		JenkinsfilePath: "foo/Jenkinsfile",
		Env:             string(env),
		ResourceVersion: "0",
	}
	b, err := getBuildConfig(tmpl, data)
	if err != nil {
		t.Error(err)
	}
	configBytes, err := ioutil.ReadFile("testdata/golden/pipeline.json")
	if err != nil {
		t.Error(err)
	}
	actual := b.String()
	expected := string(configBytes)
	if actual != expected {
		t.Errorf("Not the same, have: %s, want: %s", actual, expected)
	}
}

func TestExtractComponent(t *testing.T) {
	tests := map[string]struct {
		repository    string
		project       string
		wantComponent string
	}{
		"repository contains project prefix": {
			repository:    "prj-example",
			project:       "PRJ",
			wantComponent: "example",
		},
		"repository does not contain project prefix": {
			repository:    "proj-example",
			project:       "PRJ",
			wantComponent: "proj-example",
		},
		"repository contains project but not as prefix": {
			repository:    "prj-example-prj-test",
			project:       "PRJ",
			wantComponent: "example-prj-test",
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			got := extractComponent(tc.repository, tc.project)
			if got != tc.wantComponent {
				t.Fatalf("Got: %s, want: %s", got, tc.wantComponent)
			}
		})
	}
}
