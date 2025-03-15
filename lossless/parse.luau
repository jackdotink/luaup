--!optimize 2
--!nolint LocalShadow
local cst = require("./cst")
local span = require("./span")

local function unreachable(_: never): never
	error("unreachable")
end

export type ParseError = {
	message: string,
	span: cst.Span,
}

local load: (text: string) -> ()
local next_token: () -> cst.Token

local line: number

local current_token: cst.Token
local current_kind: typeof((({} :: any) :: cst.Token).kind)
local lookahead_token: cst.Token
local lookahead_kind: typeof((({} :: any) :: cst.Token).kind)

do
	local buf: buffer
	local pos: number
	local len: number

	local brace_count: number
	local brace_stack: { number } = {}

	local function char(c: string): number
		return string.byte(c) :: number
	end

	local function peek(): number
		return buffer.readu8(buf, pos) :: any
	end

	local function bump()
		pos = math.min((pos + 1) :: any, len)
	end

	local function bump_any()
		if peek() == char("\n") then
			line += 1
		end

		bump()
	end

	local function bump_peek()
		bump()
		return peek()
	end

	local function is_whitespace(c: number): boolean
		return c == char(" ") or c == char("\t") or c == char("\n") or c == char("\r")
	end

	local function is_digit(c: number): boolean
		return char("0") <= c and c <= char("9")
	end

	local function is_alpha(c: number): boolean
		return (char("a") <= c and c <= char("z")) or (char("A") <= c and c <= char("Z"))
	end

	local function number(): "number" | "error"
		local start = pos
		local base = 10

		local c: number = peek()

		if c == char("0") then
			c = bump_peek()

			if c == char("x") or c == char("X") then
				c = bump_peek()
				base = 16
			elseif c == char("b") or c == char("B") then
				c = bump_peek()
				base = 2
			end
		end

		while is_digit(c) or c == char(".") or c == char("_") do
			c = bump_peek()
		end

		if c == char("e") or c == char("E") then
			c = bump_peek()

			if c == char("+") or c == char("-") then
				c = bump_peek()
			end
		end

		while is_digit(c) or is_alpha(c :: any) or c == char("_") do
			c = bump_peek()
		end

		local text: string
		if base == 10 then
			text = buffer.readstring(buf, start, pos - start) :: string
		else
			text = buffer.readstring(buf, start + 2, pos - start - 2) :: string
		end

		if tonumber(text, base) then
			return "number"
		else
			return "error"
		end
	end
	
	local function string_backslash()
		local c = peek()

		if c == char("\r") then
			c = bump_peek()

			if c == char("\n") then
				bump()
				line += 1
			end
		elseif c == char("z") then
			bump()

			while is_whitespace(peek()) do
				bump_any()
			end
		else
			bump_any()
		end
	end

	local function quoted_string(): "string" | "error"
		local delim = peek()
		local c = bump_peek()

		while c ~= delim do
			if c == 0 or c == char("\n") or c == char("\r") then
				return "error"
			elseif c == char("\\") then
				bump()
				string_backslash()
			else
				bump()
			end

			c = peek()
		end

		bump()
		return "string"
	end

	local function long_seperator(): number
		local count = 0

		while peek() == char("=") do
			bump()
			count += 1
		end
		
		return count
	end

	local function long_string(eqs: number): "string" | "error"
		bump()

		while true do
			local c = peek()

			if c == char("]") then
				bump()

				if long_seperator() == eqs and peek() == char("]") then
					bump()
					return "string"
				end
			elseif c == 0 then
				return "error"
			else
				bump_any()
			end
		end
	end

	local function istring_section(
		from: "start" | "middle"
	): "istring_simple" | "istring_first" | "istring_middle" | "istring_last" | "error"
		local c = peek()

		while c ~= char("`") do
			if c == 0 or c == char("\n") or c == char("\r") then
				return "error"
			elseif c == char("\\") then
				bump()

				if peek() == char("u") then
					bump()

					if peek() == char("{") then
						bump()
					end
				else
					string_backslash()
				end
			elseif c == char("{") then
				bump()

				if peek() == char("{") then
					bump()
					return "error"
				else
					table.insert(brace_stack, brace_count)

					if from == "start" then
						return "istring_first"
					else
						return "istring_middle"
					end
				end
			else
				bump()
			end

			c = peek()
		end

		bump()

		if from == "start" then
			return "istring_simple"
		else
			return "istring_last"
		end
	end

	local function comment(): "comment" | "error"
		local c = peek()

		if c == char("[") then
			bump()
			local eqs = long_seperator()

			if peek() == char("[") then
				local result = long_string(eqs)

				if result == "error" then
					return "error"
				else
					return "comment"
				end
			end
		end

		c = peek()

		while c ~= 0 and c ~= char("\n") do
			c = bump_peek()
		end

		return "comment"
	end

	local function next_kind(): typeof((({} :: any) :: cst.Token | cst.Trivia).kind)
		local c = peek()

		if c == 0 then
			return "eof"
		elseif is_whitespace(c) then
			repeat
				bump_any()
			until not is_whitespace(peek())

			return "whitespace"
		elseif is_alpha(c :: any) or c == char("_") then
			local start = pos
			local first = c

			repeat
				c = bump_peek()
			until not (is_alpha(c :: any) or is_digit(c :: any) or c == char("_"))

			if first == char("l") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "local" then text else "ident"
			elseif first == char("e") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "end" or text == "elseif" or text == "else" then text else "ident"
			elseif first == char("t") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "then" or text == "true" then text else "ident"
			elseif first == char("r") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "return" or text == "repeat" then text else "ident"
			elseif first == char("f") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "function" or text == "for" or text == "false" then text else "ident"
			elseif first == char("i") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "if" or text == "in" then text else "ident"
			elseif first == char("d") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "do" then text else "ident"
			elseif first == char("n") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "nil" or text == "not" then text else "ident"
			elseif first == char("o") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "or" then text else "ident"
			elseif first == char("a") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "and" then text else "ident"
			elseif first == char("b") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "break" then text else "ident"
			elseif first == char("w") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "while" then text else "ident"
			elseif first == char("u") then
				local text = buffer.readstring(buf, start, pos - start) :: string
				return if text == "until" then text else "ident"
			else
				return "ident"
			end
		elseif is_digit(c :: number) then
			return if number() then "number" else "error"
		elseif c == char("'") or c == char('"') then
			return quoted_string()
		elseif c == char("`") then
			bump()
			return istring_section("start")
		elseif c == char("{") then
			brace_count += 1
			bump()
			return "{"
		elseif c == char("}") then
			if #brace_stack ~= 0 and brace_stack[#brace_stack] == brace_count then
				table.remove(brace_stack)
				return istring_section("middle")
			else
				brace_count -= 1
				bump()
				return "}"
			end
		elseif c == char("[") then
			bump()

			local eqs = long_seperator()
			
			if peek() == char("[") then
				return long_string(eqs)
			elseif eqs > 0 then
				return "error"
			else
				return "["
			end
		elseif c == char("-") then
			c = bump_peek()

			if c == char(">") then
				bump()
				return "->"
			elseif c == char("=") then
				bump()
				return "-="
			elseif c == char("-") then
				bump()
				return comment()
			else
				return "-"
			end
		end

		bump()

		if c == char(",") then
			return ","
		elseif c == char("(") then
			return "("
		elseif c == char(")") then
			return ")"
		elseif c == char("=") then
			c = peek()

			if c == char("=") then
				bump()
				return "=="
			else
				return "="
			end
		elseif c == char(".") then
			c = peek()

			if c == char(".") then
				c = bump_peek()

				if c == char(".") then
					bump()
					return "..."
				elseif c == char("=") then
					bump()
					return "..="
				else
					return ".."
				end
			elseif is_digit(c) then
				pos -= 1
				return number()
			else
				return "."
			end
		elseif c == char(":") then
			c = peek()

			if c == char(":") then
				bump()
				return "::"
			else
				return ":"
			end
		elseif c == char(">") then
			c = peek()

			if c == char("=") then
				bump()
				return ">="
			else
				return ">"
			end
		elseif c == char("<") then
			c = peek()

			if c == char("=") then
				bump()
				return "<="
			else
				return "<"
			end
		elseif c == char("]") then
			return "]"
		elseif c == char("|") then
			return "|"
		elseif c == char("?") then
			return "?"
		elseif c == char("+") then
			c = peek()

			if c == char("=") then
				bump()
				return "+="
			else
				return "+"
			end
		elseif c == char("*") then
			c = peek()

			if c == char("=") then
				bump()
				return "*="
			else
				return "*"
			end
		elseif c == char("#") then
			return "#"
		elseif c == char("&") then
			return "&"
		elseif c == char("~") then
			c = peek()

			if c == char("=") then
				bump()
				return "~="
			else
				return "error"
			end
		elseif c == char("^") then
			c = peek()

			if c == char("=") then
				bump()
				return "^="
			else
				return "^"
			end
		elseif c == char("/") then
			c = peek()

			if c == char("/") then
				c = bump_peek()

				if c == char("=") then
					bump()
					return "//="
				else
					return "//"
				end
			elseif c == char("=") then
				bump()
				return "/="
			else
				return "/"
			end
		elseif c == char(";") then
			return ";"
		elseif c == char("%") then
			c = peek()

			if c == char("=") then
				bump()
				return "%="
			else
				return "%"
			end
		end

		return "error"
	end

	function next_token(): cst.Token
		local trivia = {}

		while true do
			local start = pos
			local kind = next_kind()

			if kind == "whitespace" or kind == "comment" then
				table.insert(trivia, {
					kind = kind,
					text = buffer.readstring(buf, start, pos - start),
					span = { x = start, y = pos, z = 0 },
				})
			else
				if
					kind == "error"
					or kind == "ident"
					or kind == "number"
					or kind == "string"
					or kind == "istring_simple"
					or kind == "istring_first"
					or kind == "istring_middle"
					or kind == "istring_last"
					or kind == "attribute"
				then
					return {
						kind = kind,
						text = buffer.readstring(buf, start, pos - start),
						span = { x = start, y = pos, z = 0 },
						trivia = trivia,
					} :: any
				else
					return {
						kind = kind,
						span = { x = start, y = pos, z = 0 },
						trivia = trivia,
					} :: any
				end
			end
		end
	end

	function load(text: string)
		len = #text + 1
		pos = 0

		buf = buffer.create(len)
		buffer.writestring(buf, 0, text, len - 1)

		brace_count = 0
		table.clear(brace_stack)

		line = 1

		current_token = next_token()
		current_kind = current_token.kind
		lookahead_token = next_token()
		lookahead_kind = lookahead_token.kind
	end
end

local function consume(): cst.Token
	local result = current_token

	current_token = lookahead_token
	current_kind = lookahead_kind
	lookahead_token = next_token()
	lookahead_kind = lookahead_token.kind
	
	return result
end

local function display(token: cst.Token): string
	local kind = token.kind

	if 
		kind == "ident"
		or kind == "number"
		or kind == "string"
	then
		return kind
	elseif kind == "attribute" or kind == "error" then
		return "'" .. (token :: any).text .. "'"
	else
		return "'" .. kind .. "'"
	end
end

local function report(message: string, span: cst.Span?): never
	local report: ParseError = {
		message = message,
		span = span or current_token.span,
	}

	error(report)
end

local expect_failure: (kind: typeof((({} :: any) :: cst.Token).kind)) -> never

function expect_failure(kind: typeof((({} :: any) :: cst.Token).kind)): never
	return report(`expected {display({ kind = kind } :: any)}, but got {display(current_token)} instead`)
end

local function expect<T>(kind: T & typeof((({} :: any) :: cst.Token).kind)): cst.TokenKind<T>
	if current_kind == kind :: any then
		return consume() :: any
	else
		return (expect_failure(kind))
	end
end

local parse_type: () -> cst.Type
local parse_return_type: () -> cst.ReturnType
local parse_generic_declaration: () -> cst.GenericDeclaration
local parse_generic_declaration_with_defaults: () -> cst.GenericDeclarationWithDefaults
local parse_expr: () -> cst.Expr
local parse_var: () -> cst.Var
local parse_table: () -> cst.Table
local parse_block: () -> cst.Block

do
	local parse_simple_type: (allow_list_pack: boolean) -> cst.Type | cst.TypeList
	local parse_type_suffix: (type: cst.Type) -> cst.Type

	function parse_generic_declaration(): cst.GenericDeclaration
		local open = expect("<")
		local names: cst.Separated<cst.TokenKind<"ident">, cst.TokenKind<",">> = {}
		local packs: cst.Separated<{
			name: cst.TokenKind<"ident">,
			dots: cst.TokenKind<"...">,
		}, cst.TokenKind<",">> = {}

		while true do
			if current_kind == "ident" and lookahead_kind == "..." then
				break
			else
				local name = expect("ident")

				if current_kind == "," then
					table.insert(names, {
						node = name,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(names, {
						node = name,
						sep = nil
					})

					return {
						angles = { open = open, close = expect(">") },
						names = names,
						packs = packs,
					}
				end
			end
		end

		while true do
			local name = expect("ident")
			local dots = expect("...")

			if current_kind == "," then
				table.insert(packs, {
					node = { name = name, dots = dots },
					sep = consume() :: cst.TokenKind<",">,
				})
			else
				table.insert(packs, {
					node = { name = name, dots = dots },
					sep = nil,
				})

				return {
					angles = { open = open, close = consume() :: cst.TokenKind<">"> },
					names = names,
					packs = packs,
				}
			end
		end
	end

	local function parse_tail_type(): cst.TailType
		if current_kind == "..." then
			local dots = consume() :: cst.TokenKind<"...">
			local type = parse_type()
			return { kind = "variadic", dots = dots, type = type }
		elseif current_kind == "ident" and lookahead_kind == "..." then
			local name = consume() :: cst.TokenKind<"ident">
			local dots = consume() :: cst.TokenKind<"...">
			return { kind = "generic", name = name, dots = dots }
		else
			error("internal: parse_tail_type called in invalid position")
		end
	end

	function parse_generic_declaration_with_defaults(): cst.GenericDeclarationWithDefaults
		local open = expect("<")
		local names: cst.Separated<{
			name: cst.TokenKind<"ident">,
			default: {
				equals: cst.TokenKind<"=">,
				type: cst.Type,
			}?,
		}, cst.TokenKind<",">> = {}
		local packs: cst.Separated<{
			name: cst.TokenKind<"ident">,
			dots: cst.TokenKind<"...">,
			default: {
				equals: cst.TokenKind<"=">,
				pack: cst.TypePack,
			}?,
		}, cst.TokenKind<",">> = {}

		while true do
			if current_kind == "ident" and lookahead_kind == "..." then
				break
			else
				local name = expect("ident")
				local default: {
					equals: cst.TokenKind<"=">,
					type: cst.Type,
				}? = nil
				
				if current_kind == "=" then
					local equals = consume() :: cst.TokenKind<"=">
					local type = parse_type()
					default = { equals = equals, type = type }
				end

				if current_kind == "," then
					table.insert(names, {
						node = { name = name, default = default },
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(names, {
						node = { name = name, default = default },
						sep = nil
					})

					return {
						angles = { open = open, close = expect(">") },
						names = names,
						packs = packs,
					}
				end
			end
		end

		while true do
			local name = expect("ident")
			local dots = expect("...")
			local default: {
				equals: cst.TokenKind<"=">,
				pack: cst.TypePack,
			}? = nil

			if current_kind == "=" then
				local equals = consume() :: cst.TokenKind<"=">
				local pack: cst.TypePack

				if
					current_kind == "..."
					or (current_kind == "ident" and lookahead_kind == "...")
				then
					pack = parse_tail_type()
				elseif current_kind == "(" then
					local maybe_pack = parse_simple_type(true)

					if maybe_pack.kind == "list" then
						pack = maybe_pack
					elseif maybe_pack.kind == "function" then
						report("expected type pack after '=', found function type", span.type(maybe_pack))
					else
						error("internal: parse_simple_type did not return a list or function type at '(' token")
					end
				else
					report(`expected type pack after '=', found {display(current_token)}`)
				end

				default = { equals = equals, pack = pack }
			end

			if current_kind == "," then
				table.insert(packs, {
					node = { name = name, dots = dots, default = default },
					sep = consume() :: cst.TokenKind<",">,
				})
			else
				table.insert(packs, {
					node = { name = name, dots = dots, default = default },
					sep = nil,
				})

				return {
					angles = { open = open, close = expect(">") },
					names = names,
					packs = packs,
				}
			end
		end
	end

	local function parse_function_type_params(): (cst.Separated<{
		name: {
			name: cst.TokenKind<"ident">,
			colon: cst.TokenKind<":">,
		}?,

		type: cst.Type,
	}, cst.TokenKind<",">>, cst.TailType?)
		local params: cst.Separated<{
			name: {
				name: cst.TokenKind<"ident">,
				colon: cst.TokenKind<":">,
			}?,

			type: cst.Type,
		}, cst.TokenKind<",">> = {}

		while true do
			if
				current_kind == "..."
				or (current_kind == "ident" and lookahead_kind == "...")
			then
				local pack = parse_tail_type()
				return params, pack
			end

			local name: {
				name: cst.TokenKind<"ident">,
				colon: cst.TokenKind<":">,
			}? = nil

			if current_kind == "ident" and lookahead_kind == ":" then
				name = {
					name = consume() :: cst.TokenKind<"ident">,
					colon = consume() :: cst.TokenKind<":">,
				}
			end

			local type = parse_type()

			if current_kind == "," then
				table.insert(params, {
					node = { name = name, type = type },
					sep = consume() :: cst.TokenKind<",">,
				})
			else
				table.insert(params, {
					node = { name = name, type = type },
					sep = nil,
				})

				return params, nil
			end
		end
	end

	function parse_simple_type(allow_list_pack: boolean): cst.Type | cst.TypeList
		if current_kind == "nil" then
			return { kind = "nil", tok = consume() :: cst.TokenKind<"nil"> }
		elseif current_kind == "true" or current_kind == "false" then
			return { kind = "boolean", tok = consume() :: cst.TokenKind<"true"> | cst.TokenKind<"false"> }
		elseif current_kind == "string" then
			return { kind = "string", tok = consume() :: cst.TokenKind<"string"> }
		elseif current_kind == "ident" then
			if (current_token :: cst.TokenKind<"ident">).text == "typeof" then
				local typeof_tok = consume() :: cst.TokenKind<"ident">
				local open = expect("(")
				local expr = parse_expr()
				local close = expect(")")

				return {
					kind = "typeof",
					typeof_tok = typeof_tok,
					parens = { open = open, close = close },
					expr = expr,
				}
			else
				local name = consume() :: cst.TokenKind<"ident">
				local prefix: {
					name: cst.TokenKind<"ident">,
					dot: cst.TokenKind<".">,
				}? = nil

				if current_kind == "." then
					prefix = { name = name, dot = consume() :: cst.TokenKind<"."> }
					name = expect("ident")
				elseif current_kind == "..." then
					local message = "unexpected '...' after type name; type pack is not allowed in this context"
					report(message)
				end

				if current_kind == "<" then
					local open = consume() :: cst.TokenKind<"<">
					local types: cst.Separated<cst.TypeArg, cst.TokenKind<",">> = {}

					if current_kind == ">" then
						return {
							kind = "reference",
							prefix = prefix,
							name = name,
							generics = {
								angles = { open = open, close = consume() :: cst.TokenKind<">"> },
								types = types,
							},
						} :: cst.Type_Reference
					else
						while true do
							local generic: cst.TypeArg

							if
								current_kind == "..."
								or (current_kind == "ident" and lookahead_kind == "...")
							then
								generic = parse_tail_type()
							elseif current_kind == "(" then
								local type = parse_simple_type(true)

								if type.kind == "list" then
									generic = type
								else
									generic = parse_type_suffix(type)
								end
							else
								generic = parse_type()
							end

							if current_kind == "," then
								table.insert(types, {
									node = generic,
									sep = consume() :: cst.TokenKind<",">,
								})
							else
								table.insert(types, {
									node = generic,
									sep = nil,
								})

								return {
									kind = "reference",
									prefix = prefix,
									name = name,
									generics = {
										angles = { open = open, close = expect(">") },
										types = types,
									},
								} :: cst.Type_Reference
							end
						end
					end
				else
					return {
						kind = "reference",
						prefix = prefix,
						name = name,
						generics = nil,
					}
				end
			end
		elseif current_kind == "{" then
			local open = consume() :: cst.TokenKind<"{">
			local had_indexer = false
			local fields: cst.Separated<cst.TableTypeField, cst.TokenKind<","> | cst.TokenKind<";">> = {}

			while current_kind ~= "}" do
				local access: cst.TokenKind<"ident">? = nil
				local field: cst.TableTypeField

				if current_kind == "ident" and lookahead_kind ~= ":" then
					local text = (current_token :: cst.TokenKind<"ident">).text

					if text == "read" or text == "write" then
						access = consume() :: cst.TokenKind<"ident">
					end
				end

				if current_kind == "[" then
					if lookahead_kind == "string" then
						local open = consume() :: cst.TokenKind<"[">
						local key = consume() :: cst.TokenKind<"string">
						local close = expect("]")
						local colon = expect(":")
						local type = parse_type()

						field = {
							kind = "stringprop" :: "stringprop",
							access = access,
							bracks = { open = open, close = close },
							key = key,
							colon = colon,
							type = type,
						}
					else
						local open = consume() :: cst.TokenKind<"[">
						local key = parse_type()
						local close = expect("]")
						local colon = expect(":")
						local type = parse_type()

						field = {
							kind = "indexer" :: "indexer",
							access = access,
							bracks = { open = open, close = close },
							key = key,
							colon = colon,
							type = type,
						}

						if had_indexer then
							report("table types cannot have more than one indexer", span.table_type_field(field))
						else
							had_indexer = true
						end
					end
				elseif current_kind == "ident" and lookahead_kind == ":" then
					local name = consume() :: cst.TokenKind<"ident">
					local colon = consume() :: cst.TokenKind<":">
					local type = parse_type()

					field = {
						kind = "nameprop" :: "nameprop",
						access = access,
						name = name,
						colon = colon,
						type = type,
					}
				elseif #fields == 0 then
					local type = parse_type()
					local close = expect("}")

					if access ~= nil then
						report(`'{access.text}' keyword is illegal in this position`, access.span)
					end

					return {
						kind = "array",
						braces = { open = open, close = close },
						type = type,
					}
				end

				if current_kind == "," or current_kind == ";" then
					table.insert(fields, {
						node = field,
						sep = consume() :: cst.TokenKind<","> | cst.TokenKind<";">,
					})
				else
					table.insert(fields, {
						node = field,
						sep = nil,
					})

					break
				end
			end

			local close = expect("}")

			return {
				kind = "table",
				braces = { open = open, close = close },
				fields = fields,
			}
		elseif current_kind == "(" or current_kind == "<" then
			local force_function_type = current_kind == "<"
			local generics: cst.GenericDeclaration? = (
				if force_function_type then parse_generic_declaration()
				else nil
			)

			local open = expect("(")
			local params: cst.Separated<{
				name: {
					name: cst.TokenKind<"ident">,
					colon: cst.TokenKind<":">,
				}?,

				type: cst.Type,
			}, cst.TokenKind<",">>, tail: cst.TailType?

			if current_kind ~= ")" then
				params, tail = parse_function_type_params()
			else
				params = {}
			end

			local close = expect(")")

			if not force_function_type then
				for _, pair in params do
					if pair.node.name ~= nil then
						force_function_type = true
						break
					end
				end
			end

			local return_type_introducer = current_kind == "->"

			if not force_function_type and not return_type_introducer then
				if allow_list_pack then
					local types: cst.Separated<cst.Type, cst.TokenKind<",">> = {}

					for _, pair in params do
						table.insert(types, {
							node = pair.node.type,
							sep = pair.sep,
						})
					end

					return {
						kind = "list",
						parens = { open = open, close = close },
						types = types,
						tail = tail,
					}
				elseif ((#params :: any) :: number) == 1 and tail == nil then
					return {
						kind = "paren",
						parens = { open = open, close = close },
						type = params[1].node.type,
					}
				end
			end

			local arrow = expect("->")
			local ret = parse_return_type()

			return {
				kind = "function",
				generics = generics,
				parens = { open = open, close = close },
				params = params,
				varargs = tail,
				arrow = arrow,
				ret = ret,
			}
		else
			return report(`expected type, but got {display(current_token)}`)
		end
	end

	function parse_type_suffix(current_type: cst.Type?): cst.Type
		local types: cst.Separated<cst.Type, cst.TokenKind<"|"> | cst.TokenKind<"&">> = {}
		local leading = if current_type then nil else consume()
		local is_union, is_intersection = false, false

		if leading then
			if leading.kind == "|" then
				is_union = true
			elseif leading.kind == "&" then
				is_intersection = true
			else
				error("internal: invalid leading token")
			end
		end

		while true do
			local type: cst.Type

			if current_type then
				type = current_type
				current_type = nil
			else
				type = parse_simple_type(false) :: cst.Type
			end

			if current_kind == "?" then
				if is_intersection then
					report("optional types cannot be used in intersections")
				else
					local question = consume() :: cst.TokenKind<"?">
					current_type = { kind = "optional", type = type, question = question }
					is_union = true
				end
			elseif current_kind == "|" then
				if is_intersection then
					report("unions and intersections cannot be mixed")
				else
					local pipe = consume() :: cst.TokenKind<"|">
					table.insert(types, { node = type, sep = pipe })
					is_union = true
				end
			elseif current_kind == "&" then
				if is_union then
					report("unions and intersections cannot be mixed")
				else
					local amp = consume() :: cst.TokenKind<"&">
					table.insert(types, { node = type, sep = amp })
					is_intersection = true
				end
			elseif #types == 0 and leading == nil then
				return type
			else
				table.insert(types, { node = type, sep = nil })
				break
			end
		end

		if is_union then
			return {
				kind = "union",
				leading = leading :: cst.TokenKind<"|">,
				types = types :: cst.Separated<cst.Type, cst.TokenKind<"|">>,
			} :: cst.Type_Union
		elseif is_intersection then
			return {
				kind = "intersection",
				leading = leading :: cst.TokenKind<"&">,
				types = types :: cst.Separated<cst.Type, cst.TokenKind<"&">>,
			} :: cst.Type_Intersection
		else
			error("internal: reached end of parse_type_suffix without is_union or is_intersection set")
		end
	end

	function parse_type(): cst.Type
		local type: cst.Type? = nil

		if current_kind ~= "|" and current_kind ~= "&" then
			type = parse_simple_type(false) :: cst.Type
		end

		return parse_type_suffix(type)
	end

	function parse_return_type(): cst.ReturnType
		if current_kind ~= "(" then
			if
				current_kind == "..."
				or (current_kind == "ident" and lookahead_kind == "...")
			then
				return parse_tail_type()
			else
				return parse_type()
			end
		end

		local open = consume() :: cst.TokenKind<"(">
		local params: cst.Separated<{
			name: {
				name: cst.TokenKind<"ident">,
				colon: cst.TokenKind<":">,
			}?,

			type: cst.Type,
		}, cst.TokenKind<",">>, tail: cst.TailType?

		if current_kind ~= ")" then
			params, tail = parse_function_type_params()
		else
			params = {}
		end

		local close = expect(")")

		local has_named_param = false
		for _, pair in params do
			if pair.node.name ~= nil then
				has_named_param = true
				break
			end
		end

		if current_kind ~= "->" and not has_named_param then
			if ((#params :: any) :: number) == 1 and tail == nil then
				local paren_type = {
					kind = "paren",
					parens = { open = open, close = close },
					type = params[1].node.type,
				}

				return parse_type_suffix(paren_type)
			else
				local types: cst.Separated<cst.Type, cst.TokenKind<",">> = {}

				for _, pair in params do
					table.insert(types, {
						node = pair.node.type,
						sep = pair.sep,
					})
				end

				return {
					kind = "list",
					parens = { open = open, close = close },
					types = types,
					tail = tail,
				}
			end
		else
			local arrow = expect("->")
			local ret = parse_return_type()

			return {
				kind = "function",
				generics = nil,
				parens = { open = open, close = close },
				params = params,
				varargs = tail,
				arrow = arrow,
				ret = ret :: any, -- TODO: Luau bug
			} :: cst.Type_Function
		end
	end
end

local function parse_binding(): cst.Binding
	local name = expect("ident")

	if current_kind == ":" then
		local colon = consume() :: cst.TokenKind<":">
		local type = parse_type()
		
		return { name = name, type = { colon = colon, type = type } } :: cst.Binding
	else
		return { name = name, type = nil } :: cst.Binding
	end
end

local function parse_function_body(): cst.FunctionBody
	local generics: cst.GenericDeclaration? = nil

	if current_kind == "<" then
		generics = parse_generic_declaration()
	end

	local open = expect("(")
	local params: cst.Separated<cst.Binding, cst.TokenKind<",">> = {}
	local varargs: {
		dots: cst.TokenKind<"...">,
		
		type: {
			colon: cst.TokenKind<":">,
			type: cst.Type | cst.GenericTypePack,
		}?,
	}? = nil

	if current_kind ~= ")" then
		while true do
			if current_kind == "ident" then
				local binding = parse_binding()

				if current_kind == "," then
					table.insert(params, {
						node = binding,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(params, {
						node = binding,
						sep = nil,
					})

					break
				end
			elseif current_kind == "..." then
				local dots = consume() :: cst.TokenKind<"...">

				if current_kind == ":" then
					local colon = consume() :: cst.TokenKind<":">
					local type: cst.Type | cst.GenericTypePack

					if current_kind == "ident" and lookahead_kind == "..." then
						type = {
							kind = "generic",
							name = consume() :: cst.TokenKind<"ident">,
							dots = consume() :: cst.TokenKind<"...">,
						}
					else
						type = parse_type()
					end

					varargs = {
						dots = dots,
						type = { colon = colon, type = type },
					} :: any -- TODO: Luau bug
				else
					varargs = {
						dots = dots,
						type = nil,
					} :: any -- TODO: Luau bug
				end

				break
			else
				report(`expected binding, but got {display(current_token)}`)
			end
		end
	end

	local close = expect(")")
	local ret: { colon: cst.TokenKind<":">, type: cst.ReturnType }? = nil

	if current_kind == ":" then
		local colon = consume() :: cst.TokenKind<":">
		local type = parse_return_type()

		ret = { colon = colon, type = type }
	end

	local block = parse_block()
	local end_tok = expect("end")

	return {
		generics = generics,
		parens = { open = open, close = close },
		params = params,
		varargs = varargs,
		ret = ret,
		block = block,
		end_tok = end_tok,
	}
end

do
	local function parse_simple_expr(): cst.Expr
		if current_kind == "nil" then
			return { kind = "nil", tok = consume() :: cst.TokenKind<"nil"> }
		elseif current_kind == "true" or current_kind == "false" then
			return { kind = "boolean", tok = consume() :: cst.TokenKind<"true"> | cst.TokenKind<"false"> }
		elseif current_kind == "number" then
			return { kind = "number", tok = consume() :: cst.TokenKind<"number"> }
		elseif current_kind == "string" then
			return { kind = "string", tok = consume() :: cst.TokenKind<"string"> }
		elseif current_kind == "..." then
			return { kind = "varargs", tok = consume() :: cst.TokenKind<"..."> }
		elseif current_kind == "istring_simple" then
			return {
				kind = "istring",
				istring = {
					kind = "simple",
					tok = consume() :: cst.TokenKind<"istring_simple">,
				},
			}
		elseif current_kind == "istring_first" then
			local first = consume() :: cst.TokenKind<"istring_first">
			local middle: cst.Separated<cst.Expr, cst.TokenKind<"istring_middle">> = {}

			while true do
				local expr = parse_expr()

				if current_kind == "istring_middle" then
					table.insert(middle, {
						node = expr,
						sep = consume() :: cst.TokenKind<"istring_middle">,
					})
				else
					table.insert(middle, {
						node = expr,
						sep = nil,
					})

					break
				end
			end

			local last = expect("istring_last")

			return {
				kind = "istring",
				istring = {
					kind = "complex",
					first = first,
					middle = middle,
					last = last,
				},
			} :: cst.Expr_IString
		elseif current_kind == "{" then
			return { kind = "table", table = parse_table() }
		elseif current_kind == "function" or current_kind == "attribute" then
			local attributes: { cst.TokenKind<"attribute"> } = {}

			while current_kind == "attribute" do
				table.insert(attributes, consume() :: cst.TokenKind<"attribute">)
			end

			local function_tok = expect("function")
			local body = parse_function_body()

			return {
				kind = "function",
				attributes = attributes,
				function_tok = function_tok,
				body = body,
			}
		elseif current_kind == "if" then
			local if_tok = consume() :: cst.TokenKind<"if">
			local branches: cst.Separated<cst.IfElseExprBranch, cst.TokenKind<"elseif">> = {}
		
			while true do
				local condition = parse_expr()
				local then_tok = expect("then")
				local body = parse_expr()

				if current_kind == "elseif" then
					table.insert(branches, {
						node = {
							condition = condition,
							then_tok = then_tok,
							body = body,
						},
						sep = consume() :: cst.TokenKind<"elseif">,
					})
				else
					table.insert(branches, {
						node = {
							condition = condition,
							then_tok = then_tok,
							body = body,
						},
						sep = nil,
					})

					break
				end
			end

			local else_tok = expect("else")
			local else_body = parse_expr()

			return {
				kind = "ifelse",
				if_tok = if_tok,
				branches = branches,
				else_tok = else_tok,
				else_body = else_body,
			}
		else
			return { kind = "var", var = parse_var() }
		end
	end

	local function parse_unary_operator(): cst.UnaryOperator?
		if
			current_kind == "+"
			or current_kind == "-"
			or current_kind == "#"
			or current_kind == "not"
		then
			return consume() :: any
		else
			return nil
		end
	end

	local function current_binary_operator(): cst.BinaryOperator?
		if
			current_kind == "+"
			or current_kind == "-"
			or current_kind == "*"
			or current_kind == "/"
			or current_kind == "//"
			or current_kind == "%"
			or current_kind == "^"
			or current_kind == ".."
			or current_kind == "<"
			or current_kind == "<="
			or current_kind == ">"
			or current_kind == ">="
			or current_kind == "=="
			or current_kind == "~="
			or current_kind == "and"
			or current_kind == "or"
		then
			return current_token :: any
		else
			return nil
		end
	end

	local function binary_operator_priority(op: cst.BinaryOperator): (number, number)
		local kind = op.kind

		if kind == "+" or kind == "-" then
			return 6, 6
		elseif kind == "*" or kind == "/" or kind == "//" or kind == "%" then
			return 7, 7
		elseif kind == "^" then
			return 10, 9
		elseif kind == ".." then
			return 5, 4
		elseif kind == "==" or kind == "~=" then
			return 3, 3
		elseif kind == "<" or kind == "<=" or kind == ">" or kind == ">=" then
			return 3, 3
		elseif kind == "and" then
			return 2, 2
		elseif kind == "or" then
			return 1, 1
		else
			return unreachable(kind), 0
		end
	end

	local function parse_expr_with_limit(limit: number?): cst.Expr
		limit = limit or 0

		local expr: cst.Expr

		local unop = parse_unary_operator()

		if unop then
			local rhs = parse_expr_with_limit(8)

			expr = {
				kind = "unary",
				operator = unop,
				expr = rhs,
			}
		else
			expr = parse_simple_expr()

			if current_kind == "::" then
				local colon = consume() :: cst.TokenKind<"::">
				local type = parse_type()

				expr = {
					kind = "assertion",
					expr = expr,
					colon = colon,
					type = type,
				}
			end
		end

		while true do
			local binop = current_binary_operator()

			if binop == nil then
				break
			end

			local left_priority, right_priority = binary_operator_priority(binop)

			if left_priority < limit then
				break
			end

			consume()

			local rhs = parse_expr_with_limit(right_priority)

			expr = {
				kind = "binary",
				left = expr,
				operator = binop,
				right = rhs,
			}
		end

		return expr
	end

	parse_expr = parse_expr_with_limit :: () -> cst.Expr
end

function parse_table(): cst.Table
	local open = consume() :: cst.TokenKind<"{">
	local fields: cst.Separated<cst.TableField, cst.TokenKind<","> | cst.TokenKind<";">> = {}

	while current_kind ~= "}" do
		local field: cst.TableField

		if current_kind == "[" then
			local open = consume() :: cst.TokenKind<"[">
			local key = parse_expr()
			local close = expect("]")
			local equals = expect("=")
			local value = parse_expr()

			field = {
				kind = "exprkey",
				bracks = { open = open, close = close },
				key = key,
				equals = equals,
				value = value,
			}
		elseif current_kind == "ident" and lookahead_kind == "=" then
			local name = consume() :: cst.TokenKind<"ident">
			local equals = consume() :: cst.TokenKind<"=">
			local value = parse_expr()

			field = {
				kind = "namekey",
				name = name,
				equals = equals,
				value = value,
			}
		else
			local value = parse_expr()

			field = {
				kind = "nokey",
				value = value,
			}
		end

		if current_kind == "," or current_kind == ";" then
			table.insert(fields, {
				node = field,
				sep = consume() :: cst.TokenKind<","> | cst.TokenKind<";">,
			})
		else
			table.insert(fields, {
				node = field,
				sep = nil,
			})

			break
		end
	end

	local close = expect("}")

	return {
		braces = { open = open, close = close },
		fields = fields,
	}
end

function parse_var(): cst.Var
	local root: cst.VarRoot

	if current_kind == "ident" then
		root = {
			kind = "name",
			tok = consume() :: cst.TokenKind<"ident">,
		}
	elseif current_kind == "(" then
		local open = consume() :: cst.TokenKind<"(">
		local expr = parse_expr()
		local close = expect(")")

		root = {
			kind = "paren",
			parens = { open = open, close = close },
			expr = expr,
		}
	else
		return report(`expected variable or expression, but got {display(current_token)}`)
	end

	local suffixes: { cst.VarSuffix } = {}
	local last_line = line

	while true do
		if current_kind == "." then
			local dot = consume() :: cst.TokenKind<".">
			local name = expect("ident")

			table.insert(suffixes, {
				kind = "nameindex",
				dot = dot,
				name = name,
			})
		elseif current_kind == "[" then
			local open = consume() :: cst.TokenKind<"[">
			local expr = parse_expr()
			local close = expect("]")

			table.insert(suffixes, {
				kind = "exprindex",
				bracks = { open = open, close = close },
				expr = expr,
			})
		elseif current_kind == "(" and line ~= last_line then
			local message = "ambiguous syntax: this looks like an argument \z
				list for a function call, but could also be the start \z
				of a new statement; use ';' to separate statements"
			
			report(message)
		elseif
			current_kind == "("
			or current_kind == ":"
			or current_kind == "{"
			or current_kind == "string"
		then
			local method: {
				colon: cst.TokenKind<":">,
				name: cst.TokenKind<"ident">,
			}? = nil

			if current_kind == ":" then
				method = {
					colon = consume() :: cst.TokenKind<":">,
					name = expect("ident"),
				}
			end

			local arg: cst.FunctionArg

			if current_kind == "(" then
				local open = consume() :: cst.TokenKind<"(">
				local exprs: cst.Separated<cst.Expr, cst.TokenKind<",">> = {}

				if current_kind ~= ")" then
					while true do
						local expr = parse_expr()

						if current_kind == "," then
							table.insert(exprs, {
								node = expr,
								sep = consume() :: cst.TokenKind<",">,
							})
						else
							table.insert(exprs, {
								node = expr,
								sep = nil,
							})

							break
						end
					end
				end

				local close = expect(")")

				arg = {
					kind = "pack",
					parens = { open = open, close = close },
					exprs = exprs,
				}
			elseif current_kind == "{" then
				local table = parse_table()

				arg = {
					kind = "table",
					table = table,
				}
			elseif current_kind == "string" then
				arg = {
					kind = "string",
					tok = consume() :: cst.TokenKind<"string">,
				}
			else
				report(`expected function argument, but got {display(current_token)}`)
			end

			table.insert(suffixes, {
				kind = "call",
				method = method,
				arg = arg,
			})
		else
			break
		end

		last_line = line
	end

	return {
		root = root,
		suffixes = suffixes,
	}
end

do
	local function parse_stat_if(): cst.Stat_If
		local if_tok = consume() :: cst.TokenKind<"if">
		local branches: cst.Separated<cst.IfStatBranch, cst.TokenKind<"elseif">> = {}
	
		while true do
			local condition = parse_expr()
			local then_tok = expect("then")
			local block = parse_block()

			if current_kind == "elseif" then
				table.insert(branches, {
					node = {
						condition = condition,
						then_tok = then_tok,
						block = block,
					},
					sep = consume() :: cst.TokenKind<"elseif">,
				})
			else
				table.insert(branches, {
					node = {
						condition = condition,
						then_tok = then_tok,
						block = block,
					},
					sep = nil,
				})

				break
			end
		end

		local else_branch: {
			else_tok: cst.TokenKind<"else">,
			block: cst.Block,
		}? = nil
		
		if current_kind == "else" then
			else_branch = {
				else_tok = consume() :: cst.TokenKind<"else">,
				block = parse_block(),
			}
		end

		local end_tok = expect("end")

		return {
			kind = "if",
			if_tok = if_tok,
			branches = branches,
			else_branch = else_branch,
			end_tok = end_tok,
		}
	end

	local function parse_stat_while(): cst.Stat_While
		local while_tok = consume() :: cst.TokenKind<"while">
		local condition = parse_expr()
		local do_tok = expect("do")
		local block = parse_block()
		local end_tok = expect("end")

		return {
			kind = "while",
			while_tok = while_tok,
			condition = condition,
			do_tok = do_tok,
			block = block,
			end_tok = end_tok,
		}
	end

	local function parse_stat_do(): cst.Stat_Do
		local do_tok = consume() :: cst.TokenKind<"do">
		local block = parse_block()
		local end_tok = expect("end")

		return {
			kind = "do",
			do_tok = do_tok,
			block = block,
			end_tok = end_tok,
		}
	end

	local function parse_stat_for(): cst.Stat_NumericFor | cst.Stat_ForIn
		local for_tok = consume() :: cst.TokenKind<"for">
		local binding = parse_binding()

		if current_kind == "=" then
			local equals = consume() :: cst.TokenKind<"=">
			local start_expr = parse_expr()
			local comma = expect(",")
			local end_expr = parse_expr()

			local step: {
				comma: cst.TokenKind<",">,
				expr: cst.Expr,
			}? = nil
			

			if current_kind == "," then
				local comma = consume() :: cst.TokenKind<",">
				local expr = parse_expr()

				step = { comma = comma, expr = expr }
			end

			local do_tok = expect("do")
			local block = parse_block()
			local end_tok = expect("end")

			return {
				kind = "numericfor",
				for_tok = for_tok,
				binding = binding,
				equals = equals,
				start_expr = start_expr,
				comma = comma,
				end_expr = end_expr,
				step = step,
				do_tok = do_tok,
				block = block,
				end_tok = end_tok,
			}
		else
			local bindings: cst.Separated<cst.Binding, cst.TokenKind<",">> = {}

			while true do
				if current_kind == "," then
					table.insert(bindings, {
						node = binding,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(bindings, {
						node = binding,
						sep = nil,
					})

					break
				end

				binding = parse_binding()
			end

			local in_tok = expect("in")
			local exprs: cst.Separated<cst.Expr, cst.TokenKind<",">> = {}

			while true do
				local expr = parse_expr()

				if current_kind == "," then
					table.insert(exprs, {
						node = expr,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(exprs, {
						node = expr,
						sep = nil,
					})

					break
				end
			end

			local do_tok = expect("do")
			local block = parse_block()
			local end_tok = expect("end")

			return {
				kind = "forin",
				for_tok = for_tok,
				bindings = bindings,
				in_tok = in_tok,
				exprs = exprs,
				do_tok = do_tok,
				block = block,
				end_tok = end_tok,
			}
		end
	end

	local function parse_stat_repeat(): cst.Stat_Repeat
		local repeat_tok = consume() :: cst.TokenKind<"repeat">
		local block = parse_block()
		local until_tok = expect("until")
		local condition = parse_expr()

		return {
			kind = "repeat",
			repeat_tok = repeat_tok,
			block = block,
			until_tok = until_tok,
			condition = condition,
		}
	end

	local function parse_stat_function(attributes: { cst.TokenKind<"attribute"> }): cst.Stat_Function
		local function_tok = consume() :: cst.TokenKind<"function">
		local names: cst.Separated<cst.TokenKind<"ident">, cst.TokenKind<".">> = {}

		while true do
			local name = expect("ident")

			if current_kind == "." then
				table.insert(names, {
					node = name,
					sep = consume() :: cst.TokenKind<".">,
				})
			else
				table.insert(names, {
					node = name,
					sep = nil,
				})

				break
			end
		end

		local method: {
			colon: cst.TokenKind<":">,
			name: cst.TokenKind<"ident">,
		}? = nil
		
		if current_kind == ":" then
			method = {
				colon = consume() :: cst.TokenKind<":">,
				name = expect("ident"),
			}
		end

		local body = parse_function_body()

		return {
			kind = "function",
			attributes = attributes,
			function_tok = function_tok,
			names = names,
			method = method,
			body = body,
		}
	end

	local function parse_stat_local(attributes: { cst.TokenKind<"attribute"> }): cst.Stat_LocalFunction | cst.Stat_LocalVariable
		local local_tok = consume() :: cst.TokenKind<"local">

		if current_kind == "function" then
			local function_tok = consume() :: cst.TokenKind<"function">
			local name = expect("ident")
			local body = parse_function_body()

			return {
				kind = "localfunction",
				attributes = attributes,
				local_tok = local_tok,
				function_tok = function_tok,
				name = name,
				body = body,
			}
		elseif #attributes ~= 0 then
			return report(`expected 'function' after local declaration \z
				with attribute{if #attributes == 1 then "" else "s"}, but \z
				got {display(current_token)}`)
		else
			local bindings: cst.Separated<cst.Binding, cst.TokenKind<",">> = {}

			while true do
				local binding = parse_binding()

				if current_kind == "," then
					table.insert(bindings, {
						node = binding,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(bindings, {
						node = binding,
						sep = nil,
					})

					break
				end
			end

			if current_kind == "=" then
				local equals = consume() :: cst.TokenKind<"=">
				local exprs: cst.Separated<cst.Expr, cst.TokenKind<",">> = {}

				while true do
					local expr = parse_expr()

					if current_kind == "," then
						table.insert(exprs, {
							node = expr,
							sep = consume() :: cst.TokenKind<",">,
						})
					else
						table.insert(exprs, {
							node = expr,
							sep = nil,
						})

						break
					end
				end

				return {
					kind = "localvariable",
					local_tok = local_tok,
					bindings = bindings,
					values = {
						equals = equals,
						exprs = exprs,
					},
				} :: cst.Stat_LocalVariable
			else
				return {
					kind = "localvariable",
					local_tok = local_tok,
					bindings = bindings,
					values = nil,
				} :: cst.Stat_LocalVariable
			end
		end
	end

	local function is_block_end(): boolean
		return current_kind == "end" or current_kind == "else" or current_kind == "elseif" or current_kind == "until" or current_kind == "eof"
	end

	local function parse_last_stat_return(): cst.LastStat_Return
		local return_tok = consume() :: cst.TokenKind<"return">
		local exprs: cst.Separated<cst.Expr, cst.TokenKind<",">> = {}

		if current_kind ~= ";" and not is_block_end() then
			while true do
				local expr = parse_expr()

				if current_kind == "," then
					table.insert(exprs, {
						node = expr,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(exprs, {
						node = expr,
						sep = nil,
					})

					break
				end
			end
		end

		return {
			kind = "return",
			return_tok = return_tok,
			exprs = exprs,
		}
	end

	local function parse_compound_operator(): cst.CompoundOperator?
		if
			current_kind == "+="
			or current_kind == "-="
			or current_kind == "*="
			or current_kind == "/="
			or current_kind == "//="
			or current_kind == "%="
			or current_kind == "^="
			or current_kind == "..="
		then
			return consume() :: any
		else
			return nil
		end
	end

	local function parse_stat(): cst.Stat | cst.LastStat
		if current_kind == "if" then
			return parse_stat_if()
		elseif current_kind == "while" then
			return parse_stat_while()
		elseif current_kind == "do" then
			return parse_stat_do()
		elseif current_kind == "for" then
			return parse_stat_for()
		elseif current_kind == "repeat" then
			return parse_stat_repeat()
		elseif current_kind == "function" then
			return parse_stat_function({})
		elseif current_kind == "local" then
			return parse_stat_local({})
		elseif current_kind == "return" then
			return parse_last_stat_return()
		elseif current_kind == "break" then
			return { kind = "break", tok = consume() :: cst.TokenKind<"break"> }
		elseif current_kind == "attribute" then
			local attributes: { cst.TokenKind<"attribute"> } = {}

			while current_kind == "attribute" do
				table.insert(attributes, consume() :: cst.TokenKind<"attribute">)
			end

			if current_kind == "function" then
				return parse_stat_function(attributes)
			elseif current_kind == "local" then
				return parse_stat_local(attributes)
			else
				return report(`expected 'function' or 'local function' after \z
					attribute{if #attributes == 1 then "" else "s"}, but got \z
					{display(current_token)} instead`)
			end
		end

		local var = parse_var()
		local operator = parse_compound_operator()
		local last_suffix: cst.VarSuffix? = var.suffixes[(#var.suffixes :: any) :: number]

		if operator then
			return {
				kind = "compoundassign",
				left = var,
				operator = operator,
				right = parse_expr(),
			}
		elseif last_suffix and last_suffix.kind == "call" then
			return {
				kind = "call",
				call = var,
			}
		elseif current_kind == "," or current_kind == "=" then
			local left: cst.Separated<cst.Var, cst.TokenKind<",">> = {}

			while true do
				if current_kind == "," then
					table.insert(left, {
						node = var,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(left, {
						node = var,
						sep = nil,
					})

					break
				end

				var = parse_var()
			end

			local equals = expect("=")
			local right: cst.Separated<cst.Expr, cst.TokenKind<",">> = {}

			while true do
				local expr = parse_expr()

				if current_kind == "," then
					table.insert(right, {
						node = expr,
						sep = consume() :: cst.TokenKind<",">,
					})
				else
					table.insert(right, {
						node = expr,
						sep = nil,
					})

					break
				end
			end

			return {
				kind = "assign",
				left = left,
				equals = equals,
				right = right,
			}
		elseif last_suffix == nil and var.root.kind == "name" then
			local tok = var.root.tok

			if tok.text == "export" or tok.text == "type" then
				local export_tok: cst.TokenKind<"ident">? = if tok.text == "export" then tok else nil
				local type_tok: cst.TokenKind<"ident">

				if export_tok then
					if current_token.kind == "ident" and current_token.text == "type" then
						type_tok = consume() :: cst.TokenKind<"ident">
					else
						local current_token_any = current_token :: any -- TODO: Luau bug
						report(`expected 'type' after 'export' but got {display(current_token_any)}`)
					end
				else
					type_tok = tok
				end

				if current_kind == "ident" then 
					local name = expect("ident")
					local generics: cst.GenericDeclarationWithDefaults? = nil
	
					if current_kind == "<" then
						generics = parse_generic_declaration_with_defaults()
					end
	
					local equals = expect("=")
					local type = parse_type()
	
					return {
						kind = "type",
						export_tok = export_tok,
						type_tok = type_tok,
						name = name,
						generics = generics,
						equals = equals,
						type = type,
					}	
				elseif current_kind == "function" then -- Type function
					local function_tok = expect("function")

					local name = expect("ident")
		
					local body = parse_function_body()
					
					return {
						kind = "typefunction",
						export_tok = export_tok,
						type_tok = type_tok,
						function_tok = function_tok,
						name = name,
						body = body,
					} :: cst.Stat_TypeFunction -- Luau moment
				else
					report(`expected 'ident' or 'function' after 'export type', but got {display(current_token)}`)
				end
			elseif tok.text == "continue" then
				return {
					kind = "continue",
					tok = tok,
				} :: cst.LastStat_Continue
			end
		end

		return report("incomplete statement: expected assignment or function call")
	end

	function parse_block(): cst.Block
		local stats: cst.Separated<cst.Stat, cst.TokenKind<";">> = {}

		while not is_block_end() do
			local stat = parse_stat()
			local semicolon = if current_kind == ";" then consume() :: cst.TokenKind<";"> else nil

			if stat.kind == "return" or stat.kind == "break" or stat.kind == "continue" then
				return {
					stats = stats,
					last_stat = { stat = stat, semicolon = semicolon },
				} :: cst.Block
			else
				table.insert(stats, {
					node = stat,
					sep = semicolon,
				})
			end
		end

		return {
			stats = stats,
			last_stat = nil,
		} :: cst.Block
	end
end

local function parse_cst(): cst.Cst
	local block = parse_block()
	local eof = expect("eof")

	return {
		block = block,
		eof = eof,
	}
end

return function(input: string): { success: true, cst: cst.Cst } | { success: false, error: ParseError }
	load(input)

	local success, result = pcall(parse_cst)

	if success then
		return { success = true, cst = result }
	else
		return { success = false, error = (result :: any) :: ParseError }
	end
end

