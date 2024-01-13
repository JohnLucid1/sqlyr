package main
import "core:fmt"


Table :: struct {
	name:   string,
	fields: []Field,
}

Field :: struct {
	title: string,
	type:  string, // Basially match to go types
}


test_fn :: proc(tokens: []Token) -> []Table {
	tables := [dynamic]Table{}
	// defer delete(tables)

	amount := find_tables_amount(tokens[:])
	start: u16 = 0
	end: u16 = 0
	for i in 0 ..< amount {
		start, end = find_table(tokens, int(end))
		table_name := get_table_name(tokens[start:end]).? or_else "DEFAULT NAME"
		table_fields := get_fields(tokens[start:end])
		append(&tables, Table{table_name, table_fields})
	}
	return tables[:]
}


get_table_name :: proc(tokens: []Token) -> Maybe(string) {
	for i := 1; i < len(tokens) - 1; i += 1 {
		if (tokens[i - 1].type == .Table || tokens[+1].type == .L_paren) &&
		   tokens[i].type == .Str_lit {
			return tokens[i].value
		}
	}
	return nil
}

get_fields :: proc(tokens: []Token) -> []Field {
	fields := [dynamic]Field{}
	
	for i := 0; i < len(tokens); i += 1 {
		if i > 1 {
			if tokens[i - 1].type == .N_line && tokens[i].type == .Str_lit {
				// fmt.printf("%s: \t%s\n", tokens[i].value, tokens[i + 1].type)
				value := tokens[i].value.? or_else "NONE"
				go_type := parse_type_to_golang(tokens[i + 1].type)
				append(&fields, Field{value, go_type})
			}
		}
	}

	return fields[:]
}

parse_type_to_golang :: proc(type: TokenType) -> string {
	#partial switch type { 	// NOTE: Partial to not switch with strliteral and so on
	case .Integer:
		return "int"
	case .Curr_timestamp:
		return "string"
	case .Timestamp:
		return "string"
	case .Foreign:
		return "int"
	case .Int:
		return "int"
	case .Varchar:
		return "string"
	case .Char:
		return "Dont know yet"
	case .Array:
		return "[]" 
	case .Float:
		return "float64"
	case .Double:
		return "int"
	case .Serial:
		return "int"
	case .Date:
		return "string"
	case .Time:
		return "string"
	case .Datetime:
		return "string"
	case .Boolean:
		return "bool"
	case .Numeric:
		return "int"
	case .Decimal:
		return "float64"
	case .Bit:
		return "bit" // Maybe change that
	case .Blob:
		return "[]byte"
	case .Text:
		return "string"
	case:
		return "unknown"
	}
}

find_table :: proc(tokens: []Token, strt_pos: int) -> (start: u16, end: u16) {
	for i := strt_pos + 1; i < len(tokens); i += 1 {
		if tokens[i].type == .Create do start = u16(i)
		else if tokens[i].type == .Semicol {
			end = u16(i)
			break
		}
	}

	return
}

find_tables_amount :: proc(tokens: []Token) -> int {
	count := 0
	for i := 0; i < len(tokens); i += 1 {
		if tokens[i].type == .Create && tokens[i + 1].type == .Table {
			count += 1
		}
	}
	return count
}
