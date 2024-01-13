package main

import "core:fmt"
import "core:strings"
import "core:unicode"

Token :: struct {
	value: Maybe(string),
	type:  TokenType,
}


TokenType :: enum {
	Integer,
	Curr_timestamp,
	Timestamp,
	N_line,
	R_paren,
	L_paren,
	L_sqylry,
	R_sqylry,
	Create,
	Table,
	Primary,
	Key,
	Foreign,
	References,
	Int,
	Varchar,
	Serial,
	Char,
	Array,
	Default,
	Float,
	Double,
	Date,
	Time,
	Datetime,
	Boolean,
	Numeric,
	Decimal,
	Bit,
	Blob,
	Text,
	Unique,
	Not,
	Null,
	Auto_increment,
	Int_lit,
	Semicol,
	Comma,
	Str_lit,
}


match_token :: proc(buff: []u8, length: u8) -> Maybe(Token) {
	using TokenType
	str_content := strings.clone_from_bytes(buff[0:length + 1])
	lower := strings.to_lower(str_content[:])
	delete(str_content)
	switch lower {
	case "(":
		return Token{nil, .L_paren}
	case ")":
		return Token{nil, .R_paren}
	case "{":
		return Token{nil, .L_sqylry}
	case "}":
		return Token{nil, .R_sqylry}
	case "create":
		return Token{nil, .Create}
	case "table":
		return Token{nil, .Table}
	case "serial":
		return Token{nil, .Serial}
	case "boolean":
		return Token{nil, .Boolean}
	case "array":
		return Token{nil, .Array}
	case "bit":
		return Token{nil, .Bit}
	case "primary":
		return Token{nil, .Primary}
	case "varchar":
		return Token{nil, .Varchar}
	case "null":
		return Token{nil, .Null}
	case "not":
		return Token{nil, .Not}
	case "key":
		return Token{nil, .Key}
	case ";":
		return Token{nil, .Semicol}
	case ",":
		return Token{nil, .Comma}
	case "references":
		return Token{nil, .References}
	case "int":
		return Token{nil, .Int}
	case "char":
		return Token{nil, .Char}
	case "float":
		return Token{nil, .Float}
	case "double":
		return Token{nil, .Double}
	case "time":
		return Token{nil, .Time}
	case "datetime":
		return Token{nil, .Datetime}
	case "numeric":
		return Token{nil, .Numeric}
	case "decimal":
		return Token{nil, .Decimal}
	case "blob":
		return Token{nil, .Blob}
	case "default":
		return Token{nil, .Default}
	case "text":
		return Token{nil, .Text}
	case "unique":
		return Token{nil, .Unique}
	case "auto-increment":
		return Token{nil, .Auto_increment}
	case "current_timestamp":
		return Token{nil, .Curr_timestamp}
	case "timestamp":
		return Token{nil, .Timestamp}
	case "integer":
		return Token{nil, .Integer}
	case:
		{
			if unicode.is_number(rune(str_content[0])) {
				return Token{lower[:], .Int_lit}
			} else {
				return Token{lower[:], .Str_lit}
			}
		}
	}

	defer delete(lower)
	return nil
}

tokenize :: proc(content: string) -> []Token {
	tokens := [dynamic]Token{}
	buff := [MAX_BYTES]u8{}
	buff_idx := u8(0)

	using unicode
	for i := 0; i < len(content); i += 1 {
		content_rune := rune(content[i])
		if is_alpha(content_rune) { 	// Tokens
			if is_alpha(rune(content[i + 1])) {
				buff[buff_idx] = content[i]
				buff_idx += 1
			} else if rune(content[i + 1]) == '_' { 	// check for values like author_id
				buff[buff_idx] = content[i]
				buff_idx += 1
				buff[buff_idx] = content[i + 1]
				buff_idx += 1
				i += 1
			} else {
				buff[buff_idx] = content[i]
				res, ok := match_token(buff[:], buff_idx).?;if !ok do continue
				buff_idx = 0
				buff = 0
				append(&tokens, res)
			}
		} else if is_punct(content_rune) { 	// Punctuations
			if content_rune == '-' && rune(content[i + 1]) == '-' { 	// Skipping comments
				for rune(content[i + 1]) != '\n' {
					i += 1
				}
			}
			buff[buff_idx] = content[i]
			res, ok := match_token(buff[:], buff_idx).?;if !ok do continue
			buff_idx = 0
			append(&tokens, res)
		} else if is_number(content_rune) { 	// Numbers
			if is_number(rune(content[i + 1])) {
				buff[buff_idx] = content[i]
				buff_idx += 1
			} else {
				buff[buff_idx] = content[i]
				res, ok := match_token(buff[:], buff_idx).?;if !ok do continue
				buff_idx = 0
				buff := 0
				append(&tokens, res)
			}

		} else if content_rune == '\n' { 	// Newlines
			append(&tokens, Token{nil, .N_line})
		} else if is_white_space(content_rune) { 	// Space 
			buff = 0
			buff_idx = 0
			continue
		}
	}

	defer free(&tokens)
	return tokens[:]
}
