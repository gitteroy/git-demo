package practice

import "fmt"

var GlobalMap = map[string]string{}

func main() {
	GlobalMap["name"] = "Alice"

	// If you found the right linter, this line should error
	name := GlobalMap["name"]

	fmt.Printf("My name is %s!\n", name)
}
