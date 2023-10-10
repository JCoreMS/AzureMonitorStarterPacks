package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

func CollectPackages(path string) error {
	cmd := exec.Command("dpkg-query", "-W", "-f=${Package},${Architecture},${Version}\n")
	// Capture the output of the command
	output, err := cmd.Output()
	if err != nil {
		fmt.Println(err)
		return nil
	}
	// Convert the output to a string
	outputStr := string(output)
	// Split the output by newline characters
	lines := strings.Split(outputStr, "\n")
	// Create a slice of slices to store the package information
	packages := [][]string{}
	// Loop through the lines and extract the relevant fields
	for _, line := range lines {
		// Skip the empty lines
		if len(line) == 0 {
			continue
		}
		// Split the line by comma characters
		fields := strings.Split(line, ",")
		// Get the name, platform and version of the package
		name := fields[0]
		platform := fields[1]
		version := fields[2]
		// Append the package information to the slice of slices
		packages = append(packages, []string{time.Now().Format("2006-01-02T15:04:05"), name, platform, version})
	}
	filepath := path + "packages.csv"
	// Open or create a CSV file to append the package information
	file, err := os.OpenFile(filepath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println(err)
		return nil
	}
	defer file.Close()
	// Create a CSV writer from the file
	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Check if the file is empty or not
	stat, err := file.Stat()
	if err != nil {
		fmt.Println(err)
		return nil
	}
	// If the file is empty, write the header to the CSV file
	if stat.Size() == 0 {
		writer.Write([]string{"Name", "Platform", "Version"})
	}

	// Append the package information to the CSV file
	for _, pkg := range packages {
		writer.Write(pkg)
	}
	return nil
}
func main() {
	if len(os.Args) < 2 {
		fmt.Println("Please enter a path")
		return
	} else {
		path := os.Args[1]
		CollectPackages(path)
	}

}
