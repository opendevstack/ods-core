//go:build tools
// +build tools

package tools

// See https://github.com/golang/go/issues/25922#issuecomment-412992431
import (
	_ "github.com/jstemmer/go-junit-report"
)
