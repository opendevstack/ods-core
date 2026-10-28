package main

import (
	"encoding/base64"
	"errors"
	"fmt"
	"net/url"
	"regexp"
)

var (
	// safeNameRegex permits characters that are valid in repository / component names.
	safeNameRegex = regexp.MustCompile(`^[a-zA-Z0-9._-]+$`)
	// dns1123LabelRegex follows Kubernetes' DNS-1123 label format.
	dns1123LabelRegex = regexp.MustCompile(`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`)
	// safeBranchRegex permits characters that are valid in git branch / ref names.
	safeBranchRegex = regexp.MustCompile(`^[a-zA-Z0-9._/\-+@]+$`)
	// safeJenkinsfilePathRegex permits only relative path segments composed of
	// safe characters. Each segment must begin with an alphanumeric character,
	// which implicitly rejects absolute paths ("/..."), path traversal ("../"),
	// and hidden-file tricks (".").
	safeJenkinsfilePathRegex = regexp.MustCompile(`^[a-zA-Z0-9][a-zA-Z0-9._-]*(?:/[a-zA-Z0-9][a-zA-Z0-9._-]*)*$`)
	// safeEnvNameRegex follows the POSIX environment variable name format.
	safeEnvNameRegex = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9_]*$`)
	// jiraIssueKeyRegex matches a Jira issue key, e.g. "PROJ-116".
	jiraIssueKeyRegex = regexp.MustCompile(`^[A-Z][A-Z0-9]*-[0-9]+$`)
	// projectAdminRegex matches a username or email, e.g. "jane.doe@example.com".
	projectAdminRegex = regexp.MustCompile(`^[A-Za-z0-9._%+-]+(@[A-Za-z0-9.-]+\.[A-Za-z]{2,})?$`)
	// projectGroupsRegex matches "ROLEGROUP=group-name" pairs, e.g. "ADMINGROUP=my-admins,USERGROUP=my-users".
	projectGroupsRegex = regexp.MustCompile(`^[A-Z][A-Z0-9_]*=[A-Za-z0-9._-]+(,[A-Z][A-Z0-9_]*=[A-Za-z0-9._-]+)*$`)
	// safeURLRegex whitelists a plain server/repository URL, excluding query, fragment and shell metacharacters.
	safeURLRegex = regexp.MustCompile(`^[a-zA-Z][a-zA-Z0-9+.-]*://([A-Za-z0-9._-]+@)?[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._/-]*)?$`)
	// safeFreeTextRegex whitelists free text (e.g. a change description) without shell metacharacters.
	safeFreeTextRegex = regexp.MustCompile(`^[\p{L}\p{N} .,:!?_/-]*$`)
)

const configItemPlaceholder = "<CHANGE_THIS_TO_YOUR_CONFIGURATION_ITEM>"

// FieldValidator validates a single string value, returning a descriptive error when the value is rejected.
type FieldValidator func(value string) error

// matchesFormat builds a FieldValidator from an anchored regex, whitelisting only safe characters.
func matchesFormat(re *regexp.Regexp) FieldValidator {
	return func(value string) error {
		if !re.MatchString(value) {
			return fmt.Errorf("does not match required format %s", re.String())
		}
		return nil
	}
}

func isConfigItem(value string) error {
	if value == configItemPlaceholder {
		return nil
	}
	return matchesFormat(safeNameRegex)(value)
}

// isDNS1123Label requires a lowercase DNS-1123 label of at most 63 characters.
func isDNS1123Label(value string) error {
	if len(value) > 63 || !dns1123LabelRegex.MatchString(value) {
		return fmt.Errorf("must be a DNS-1123 label (lowercase alphanumeric or '-', max 63 characters)")
	}
	return nil
}

// oneOf restricts a value to a fixed, enumerated list.
func oneOf(allowed ...string) FieldValidator {
	set := newStringSet(allowed...)
	return func(value string) error {
		if _, ok := set[value]; !ok {
			return fmt.Errorf("must be one of %v", allowed)
		}
		return nil
	}
}

// isBase64 requires the value to be standard base64.
func isBase64(value string) error {
	if _, err := base64.StdEncoding.DecodeString(value); err != nil {
		return fmt.Errorf("is not valid base64: %s", err)
	}
	return nil
}

// isIPRangeList requires the value to be a comma-separated list of IPs/CIDRs,
// as consumed by parseIPRanges.
func isIPRangeList(value string) error {
	if _, err := parseIPRanges(value); err != nil {
		return fmt.Errorf("is not a valid IP range list: %s", err)
	}
	return nil
}

// isURL requires an absolute URL using one of the given schemes, restricted to safeURLRegex's character whitelist.
func isURL(schemes ...string) FieldValidator {
	allowedSchemes := newStringSet(schemes...)
	return func(value string) error {
		if !safeURLRegex.MatchString(value) {
			return fmt.Errorf("does not match required format %s", safeURLRegex.String())
		}
		u, err := url.Parse(value)
		if err != nil || u.Host == "" {
			return errors.New("is not a valid URL")
		}
		if _, ok := allowedSchemes[u.Scheme]; !ok {
			return fmt.Errorf("must use one of the schemes %v", schemes)
		}
		return nil
	}
}

func newStringSet(values ...string) map[string]struct{} {
	set := make(map[string]struct{}, len(values))
	for _, v := range values {
		set[v] = struct{}{}
	}
	return set
}
