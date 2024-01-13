package main
import "core:os"
import "core:strings"
import "core:fmt"

get_longest :: proc() {
	fileBytes, ok := os.read_entire_file_from_filename("keywords.sql");if !ok {
		fmt.eprintln("CANNOT OPEN FILE :)")
		return
	}


	content := string(fileBytes)
	delete(content)
	min := 0
	lines, err := strings.split_lines(content);if err != nil {
		fmt.eprintln("CANNOT OPEN FILE :)")
		return
	}

	for line in lines {
		if len(line) > min {
			fmt.println(line, len(line))
			min = len(line)
		}
	}

	fmt.println("Biggest keyword length: ", min)
}
