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
		{
			// case insensitive comparison of project
			"pRJ",
			"comp",
			"bugfix/Prj-529-bar-6-baz",
			"comp-529",
		},
		{
			// case insensitive comparison of component
			// case of component maintained in pipeline
			"PRJ",
			"ComP",
			"bugfix/PRJ-529-bar-6-baz",
			"ComP-529",
		},
		{
			// missing - project in request
			"",
			"comp",
			"bugfix/PRJ529-bar-6-baz",
			"comp-6",
		},
		{
			"PRJ",
			"comp",
			"bugfix/äü",
			"comp-bugfix-",
		},
		{
			// todo: is this desired acceptable
			"PRJ",
			"comp",
			"bugfix/PRJ-529-PRJ-777-bar-6-baz",
			"comp-777",
		},
		{
			// todo: is this desired acceptable
			"PRJ",
			"comp",
			"bugfix/PRJ-529/PRJ-777-bar-6-baz",
			"comp-777",
		},
		// Cases which leads to pipeline string of
		// {comp}-{sanitized(branch)}
		{
			// project in branch not complete
			"PR",
			"comp",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-bugfix-prj-529-bar-6-baz",
		},
		{
			// project in branch not complete
			"PRJL",
			"comp",
			"bugfix/PRJ-529-bar-6-baz",
			"comp-bugfix-prj-529-bar-6-baz",
		},
		{
			// missing - between project and number
			"PRJ",
			"comp",
			"bugfix/PRJ529-bar-6-baz",
			"comp-bugfix-prj529-bar-6-baz",
		},
		// Some more fundamental error cases
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
