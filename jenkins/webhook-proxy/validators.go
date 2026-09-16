package main

import (
	"encoding/base64"
	"errors"
	"fmt"
	"net/url"
	"regexp"
)

// FieldValidator validates a single string value, returning a descriptive
// error when the value is rejected. Validators are composed per field (a
// field can have several) to express rules such as alphanumeric-with-dashes,
// a valid URL, base64, or one of a fixed list of values.
type FieldValidator func(value string) error

// matchesFormat builds a FieldValidator from a regex, e.g. alphanumeric,
// alphanumeric-with-dashes, etc. Anchored regexes (safeNameRegex,
// safeBranchRegex, ...) also double as an injection-prevention measure,
// since only whitelisted characters can ever reach downstream systems
// (BuildConfig template, Jenkins).
func matchesFormat(re *regexp.Regexp) FieldValidator {
	return func(value string) error {
		if !re.MatchString(value) {
			return fmt.Errorf("does not match required format %s", re.String())
		}
		return nil
	}
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

// isURL requires an absolute URL using one of the given schemes, restricted
// to safeURLRegex's whitelist so shell metacharacters and query/fragment
// smuggling are rejected regardless of what net/url.Parse tolerates.
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
