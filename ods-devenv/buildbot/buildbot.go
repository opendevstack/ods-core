package main

import (
	"fmt"
	"runtime"
)

func Main() {
	_, filename, b, c := runtime.Caller(0)
	fmt.Printf("Hello, World!")
	fmt.Printf("b: %d", b)
	fmt.Printf("c: %t", c)
	fmt.Printf("filename: %s", filename)
}
