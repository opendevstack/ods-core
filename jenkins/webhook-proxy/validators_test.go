package main

import (
	"regexp"
	"strings"
	"testing"
)

func TestIsDNS1123Label(t *testing.T) {
	tests := map[string]struct {
		value string
		want  bool
	}{
		"lowercase label":      {value: "python-flask-example", want: true},
		"numeric label":        {value: "123-component", want: true},
		"maximum length":       {value: strings.Repeat("a", 63), want: true},
		"empty":                {value: "", want: false},
		"uppercase":            {value: "My-component", want: false},
		"underscore":           {value: "my_component", want: false},
		"dot":                  {value: "my.component", want: false},
		"leading hyphen":       {value: "-component", want: false},
		"trailing hyphen":      {value: "component-", want: false},
		"longer than 63 chars": {value: strings.Repeat("a", 64), want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := isDNS1123Label(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("isDNS1123Label(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestMatchesFormat(t *testing.T) {
	validate := matchesFormat(regexp.MustCompile(`^[a-z0-9-]+$`))

	tests := map[string]struct {
		value string
		want  bool
	}{
		"matches":              {value: "my-repo-1", want: true},
		"empty string":         {value: "", want: false},
		"uppercase rejected":   {value: "My-Repo", want: false},
		"spaces rejected":      {value: "my repo", want: false},
		"special chars/inject": {value: `my"repo{}`, want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := validate(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("matchesFormat(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestIsConfigItem(t *testing.T) {
	tests := map[string]struct {
		value string
		want  bool
	}{
		"safe configuration item":    {value: "some-config-item", want: true},
		"template placeholder":        {value: configItemPlaceholder, want: true},
		"other angle-bracketed value": {value: "<not-a-placeholder>", want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := isConfigItem(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("isConfigItem(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestOneOf(t *testing.T) {
	validate := oneOf("DEV", "TEST", "PROD")

	tests := map[string]struct {
		value string
		want  bool
	}{
		"allowed value":         {value: "DEV", want: true},
		"another allowed value": {value: "PROD", want: true},
		"disallowed value":      {value: "STAGING", want: false},
		"case sensitive":        {value: "dev", want: false},
		"empty string":          {value: "", want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := validate(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("oneOf(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestIsBase64(t *testing.T) {
	tests := map[string]struct {
		value string
		want  bool
	}{
		"valid base64":           {value: "aGVsbG8=", want: true},
		"empty string is valid":  {value: "", want: true},
		"invalid characters":     {value: "not-base64!", want: false},
		"invalid padding":        {value: "aGVsbG8", want: false},
		"plain text with spaces": {value: "hello world", want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := isBase64(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("isBase64(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestIsIPRangeList(t *testing.T) {
	tests := map[string]struct {
		value string
		want  bool
	}{
		"single IP":               {value: "192.168.1.1", want: true},
		"single CIDR":             {value: "10.0.0.0/8", want: true},
		"multiple entries":        {value: "10.0.0.0/8,192.168.1.1", want: true},
		"entries with spaces":     {value: "10.0.0.0/8, 192.168.1.1", want: true},
		"invalid entry":           {value: "not-an-ip", want: false},
		"invalid CIDR":            {value: "10.0.0.0/99", want: false},
		"empty string is valid":   {value: "", want: true}, // parseIPRanges treats it as an empty list
		"base64 payload rejected": {value: "MTAuMC4wLjAvOA==", want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := isIPRangeList(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("isIPRangeList(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestIsURL(t *testing.T) {
	validate := isURL("http", "https")

	tests := map[string]struct {
		value string
		want  bool
	}{
		"valid https URL":              {value: "https://bitbucket.example.com", want: true},
		"valid http URL":               {value: "http://bitbucket.example.com", want: true},
		"disallowed scheme":            {value: "ftp://bitbucket.example.com", want: false},
		"missing scheme/host":          {value: "not-a-url", want: false},
		"empty string":                 {value: "", want: false},
		"command substitution in path": {value: "http://bitbucket.example.com/$(id)", want: false},
		"backticks in path":            {value: "http://bitbucket.example.com/`id`", want: false},
		"semicolon in path":            {value: "http://bitbucket.example.com/;id", want: false},
		"query string smuggling":       {value: "http://bitbucket.example.com/?x=$(id)", want: false},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			err := validate(tc.value)
			if got := err == nil; got != tc.want {
				t.Fatalf("isURL(%q) error = %v, want valid=%v", tc.value, err, tc.want)
			}
		})
	}
}

func TestNewStringSet(t *testing.T) {
	set := newStringSet("a", "b", "a")

	if len(set) != 2 {
		t.Fatalf("newStringSet() len = %d, want 2", len(set))
	}
	for _, v := range []string{"a", "b"} {
		if _, ok := set[v]; !ok {
			t.Fatalf("newStringSet() missing expected value %q", v)
		}
	}
}
