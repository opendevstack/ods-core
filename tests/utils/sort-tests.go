package utils

func sortTestableQuickstarters(t *testing.T, dir string, var quickstarterPaths []string) error {

    file, err := os.Open("testsWithPriority.txt")
    if err != nil {
        fmt.Println(err)
        t.Fatal(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        fmt.Println(scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        fmt.Println(err)
        t.Fatal(err)
    }

}
