package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"
MAX_BYTES :: 3000

// TODO: Maybe if type[] Should be a union of type and (figure something out)
// categories VARCHAR[],

main :: proc() {
	if len(os.args) < 1 {
		fmt.eprintln("NOT ENOUGH ARGUMENTS\nUsage: sqlyr <filepath to .sql file>")
		return
	} else if os.args[1] == "--help"  || os.args[1] == "-h" {
		fmt.println("Usage: sqlyr <filepath to .sql file>")
	}

	input_path := os.args[1]
	file_bytes, ok := os.read_entire_file_from_filename(input_path);if !ok {
		fmt.eprintln("Cannot access file")
		return
	}

	content := string(file_bytes)
	all_tokens := tokenize(content)
	tables := test_fn(all_tokens[:])
	defer delete(file_bytes)
	defer delete(all_tokens)

	print_tables(tables)
}


print_tables :: proc(tables: []Table) {
	using strings
	for table in tables {

		fmt.println("type", to_upper_camel_case(table.name), "struct {")
		for field in table.fields {
			fmt.printf(
				"\t%s %s `json:'%s'`\n",
				to_upper_camel_case(field.title),
				field.type,
				field.title,
			)
		}
		fmt.println("}\n")
	}
}
