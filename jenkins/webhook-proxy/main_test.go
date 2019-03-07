package main

import (
	"testing"
)

func TestMakePipelineName(t *testing.T) {
	tests := []struct {
		project   string
		component string
		branch    string
		expected  string
	}{
		{
			"PRJ",
			"comp",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-529",
		},
		{ // also allow a bare ticket id.
			"PRJ",
			"comp",
			"bugfix/PRJ-529",
			"comp-529",
		},
		{
			// case insensitive comparison of project
			"pRJ",
			"comp",
			"bugfix/Prj-529-bar-6-baz",
			"comp-529",
		},
		{
			// case insensitive comparison of component
			// component appears in lowercase in pipeline
			"PRJ",
			"ComP",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-529",
		},
		{
			// missing - project in request
			"",
			"comp",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-6",
		},
		{
			"PRJ",
			"comp",
			"bugfix/äü",
			"comp-bugfix-",
		},
		{
			// assert current behavior, but could be changed in the future.
			"PRJ",
			"comp",
			"bugfix/PRJ-529-PRJ-777-bar-6-baz",
			"comp-777",
		},
		{
			// assert current behavior, but could be changed in the future.
			"PRJ",
			"comp",
			"bugfix/PRJ-529/PRJ-777-bar-6-baz",
			"comp-777",
		},
		// Cases which leads to pipeline string of
		// {comp}-{sanitized(branch)}
		{
			// project is a prefix or project in branch
			"PR",
			"comp",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-bugfix-prj-529-bar-6-baz",
		},
		{
			// project in branch is a prefix of project
			"PRJL",
			"comp",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-bugfix-prj-529-bar-6-baz",
		},
		{
			// missing '-' between project and number
			"PRJ",
			"comp",
			"bugfix/PRJ529-bar-6-baz",
			"comp-bugfix-prj529-bar-6-baz",
		},
	}

	for _, tt := range tests {
		pipeline := makePipelineName(tt.project, tt.component, tt.branch)
		if tt.expected != pipeline {
			t.Errorf(
				"Expected '%s' but '%s' returned by makePipeline(project='%s', component='%s', branch='%s')",
				tt.expected,
				pipeline,
				tt.project,
				tt.component,
				tt.branch,
			)
		}
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
