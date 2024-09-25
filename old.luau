export type Location = { byte: number, line: number, char: number }

local function location_new(byte: number, line: number, char: number): Location
	return table.freeze({ byte = byte, line = line, char = char })
end

local function location_byte(self: Location): number
	return self.byte
end

local function location_line(self: Location): number
	return self.line
end

local function location_char(self: Location): number
	return self.char
end

export type Span = { start: Location, finish: Location }

local function span_new(start: Location, finish: Location): Span
	return table.freeze({ start = start, finish = finish })
end

local function span_start(self: Span): Location
	return self.start
end

local function span_finish(self: Span): Location
	return self.finish
end

local function span_merge(span1: Span, span2: Span): Span
	return span_new(span_start(span1), span_finish(span2))
end

export type TokenTrivia =
	{ kind: "whitespace", span: Span, value: string }
	| { kind: "comment", span: Span, value: string }

export type TokenType<Kind> = { kind: Kind, span: Span, trivia: { TokenTrivia } }

type TokenIdent<Value = string> = TokenType<"ident"> & { value: Value }
type TokenError = TokenType<"error"> & { value: string }
type TokenNumber = TokenType<"number"> & { value: string }
type TokenString = TokenType<"string"> & { value: string }
type TokenIStringSimple = TokenType<"istringsimple"> & { value: string }
type TokenIStringBegin = TokenType<"istringbegin"> & { value: string }
type TokenIStringMiddle = TokenType<"istringmiddle"> & { value: string }
type TokenIStringLast = TokenType<"istringlast"> & { value: string }
type TokenAttribute = TokenType<"attribute"> & { value: string }

export type Token =
	TokenType<"eof">
	| TokenIdent
	| TokenError
	| TokenNumber
	| TokenString
	| TokenIStringSimple
	| TokenIStringBegin
	| TokenIStringMiddle
	| TokenIStringLast
	| TokenAttribute
	-- Keywords
	| TokenType<"and">
	| TokenType<"break">
	| TokenType<"do">
	| TokenType<"else">
	| TokenType<"elseif">
	| TokenType<"end">
	| TokenType<"false">
	| TokenType<"for">
	| TokenType<"function">
	| TokenType<"if">
	| TokenType<"in">
	| TokenType<"local">
	| TokenType<"nil">
	| TokenType<"not">
	| TokenType<"or">
	| TokenType<"repeat">
	| TokenType<"return">
	| TokenType<"then">
	| TokenType<"true">
	| TokenType<"until">
	| TokenType<"while">
	-- Symbols
	| TokenType<"+=">
	| TokenType<"-=">
	| TokenType<"*=">
	| TokenType<"/=">
	| TokenType<"//=">
	| TokenType<"%=">
	| TokenType<"^=">
	| TokenType<"..=">
	| TokenType<"+">
	| TokenType<"-">
	| TokenType<"*">
	| TokenType<"/">
	| TokenType<"//">
	| TokenType<"%">
	| TokenType<"^">
	| TokenType<"..">
	| TokenType<"<">
	| TokenType<"<=">
	| TokenType<">">
	| TokenType<">=">
	| TokenType<"==">
	| TokenType<"~=">
	| TokenType<"#">
	| TokenType<"...">
	| TokenType<"&">
	| TokenType<"|">
	| TokenType<"?">
	| TokenType<":">
	| TokenType<"::">
	| TokenType<"->">
	| TokenType<"=">
	| TokenType<",">
	| TokenType<";">
	| TokenType<".">
	-- Delims
	| TokenType<"(">
	| TokenType<")">
	| TokenType<"{">
	| TokenType<"}">
	| TokenType<"[">
	| TokenType<"]">

export type TokenKind = typeof((({} :: any) :: Token).kind)

local function token_error(token: Token): string
	if token.kind == "ident" or token.kind == "number" or token.kind == "string" then
		return token.kind
	elseif token.kind == "attribute" then
		return "'@" .. token.value .. "'"
	elseif token.kind == "error" then
		return "'" .. token.value .. "'"
	else
		return "'" .. token.kind .. "'"
	end
end

type State = {
	buf: buffer,
	pos: number,

	line: number,
	char: number,

	brace_count: number,
	brace_stack: { number },

	current: Token?,
	lookahead: Token?,
}

local lexer_next: (state: State) -> Token

do
	local function char(c: string): number
		return string.byte(c)
	end

	local function is_whitespace(c: number): boolean
		return c == char(" ")
			or c == char("\t")
			or c == char("\n")
			or c == char("\r")
			or c == char("\v")
			or c == char("\f")
	end

	local function is_digit(c: number): boolean
		return char("0") <= c and c <= char("9")
	end

	local function is_alpha(c: number): boolean
		return (char("a") <= c and c <= char("z")) or (char("A") <= c and c <= char("Z"))
	end

	local function first(state: State): number
		if state.pos >= buffer.len(state.buf) then
			return 0
		else
			return buffer.readu8(state.buf, state.pos)
		end
	end

	local function second(state: State): number
		if state.pos + 1 >= buffer.len(state.buf) then
			return 0
		else
			return buffer.readu8(state.buf, state.pos + 1)
		end
	end

	local function bump(state: State)
		state.char += 1
		state.pos += 1
	end

	local function value(state: State, start: number): string
		return buffer.readstring(state.buf, start, state.pos - start)
	end

	local function loc(state: State): Location
		return location_new(state.pos, state.line, state.char)
	end

	function lexer_next(state: State): Token
		local trivia: { TokenTrivia } = {}

		while true do
			if is_whitespace(first(state)) then
				local start = loc(state)

				while is_whitespace(first(state)) do
					if first(state) == char("\n") then
						state.line += 1
						state.char = 0
					end

					bump(state)
				end

				local finish = loc(state)
				local value = value(state, start.byte)

				table.insert(trivia, { kind = "whitespace", span = span_new(start, finish), value = value })
			elseif first(state) == char("-") and second(state) == char("-") then
				local start = loc(state)

				bump(state)
				bump(state)

				local long: number? = nil

				if first(state) == char("[") then
					bump(state)
					local count = 0

					while first(state) == char("=") do
						bump(state)
						count += 1
					end

					if first(state) == char("[") then
						bump(state)
						long = count
					end
				end

				while true do
					if long then
						if first(state) == char("]") then
							bump(state)

							local count = 0

							while first(state) == char("=") do
								bump(state)
								count += 1
							end

							if count == long and first(state) == char("]") then
								bump(state)
								break
							end
						end
					else
						if first(state) == char("\n") or first(state) == 0 then
							break
						end
					end

					bump(state)
				end

				local finish = loc(state)
				local value = value(state, start.byte)

				table.insert(trivia, { kind = "comment", span = span_new(start, finish), value = value })
			else
				break
			end
		end

		local start = loc(state)
		local c = first(state)

		if c == 0 then
			return { kind = "eof", span = span_new(start, start), trivia = trivia }
		elseif is_alpha(c) or c == char("_") then
			bump(state)
			local v = first(state)

			while is_alpha(v) or is_digit(v) or v == char("_") do
				bump(state)
				v = first(state)
			end

			local finish = loc(state)
			local value = value(state, start.byte)

			if c == char("l") then
				if value == "local" then
					return { kind = "local", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("e") then
				if value == "end" then
					return { kind = "end", span = span_new(start, finish), trivia = trivia }
				elseif value == "elseif" then
					return { kind = "elseif", span = span_new(start, finish), trivia = trivia }
				elseif value == "else" then
					return { kind = "else", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("t") then
				if value == "then" then
					return { kind = "then", span = span_new(start, finish), trivia = trivia }
				elseif value == "true" then
					return { kind = "true", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("r") then
				if value == "return" then
					return { kind = "return", span = span_new(start, finish), trivia = trivia }
				elseif value == "repeat" then
					return { kind = "repeat", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("f") then
				if value == "function" then
					return { kind = "function", span = span_new(start, finish), trivia = trivia }
				elseif value == "for" then
					return { kind = "for", span = span_new(start, finish), trivia = trivia }
				elseif value == "false" then
					return { kind = "false", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("i") then
				if value == "if" then
					return { kind = "if", span = span_new(start, finish), trivia = trivia }
				elseif value == "in" then
					return { kind = "in", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("d") then
				if value == "do" then
					return { kind = "do", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("n") then
				if value == "nil" then
					return { kind = "nil", span = span_new(start, finish), trivia = trivia }
				elseif value == "not" then
					return { kind = "not", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("o") then
				if value == "or" then
					return { kind = "or", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("a") then
				if value == "and" then
					return { kind = "and", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("b") then
				if value == "break" then
					return { kind = "break", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("w") then
				if value == "while" then
					return { kind = "while", span = span_new(start, finish), trivia = trivia }
				end
			elseif c == char("u") then
				if value == "until" then
					return { kind = "until", span = span_new(start, finish), trivia = trivia }
				end
			end

			return { kind = "ident", span = span_new(start, finish), value = value, trivia = trivia }
		elseif is_digit(c) or (c == char(".") and is_digit(second(state))) then
			local base = 10

			if c == char("0") then
				local b = second(state)

				if b == char("x") or b == char("X") then
					base = 16
					bump(state)
				elseif b == char("b") or b == char("B") then
					base = 2
					bump(state)
				end
			end

			bump(state)
			c = first(state)

			while is_digit(c) or c == char(".") or c == char("_") do
				bump(state)
				c = first(state)
			end

			if c == char("e") or c == char("E") then
				bump(state)
				c = first(state)

				if c == char("+") or c == char("-") then
					bump(state)
					c = first(state)
				end
			end

			while is_digit(c) or is_alpha(c) or c == char("_") do
				bump(state)
				c = first(state)
			end

			local value = if base == 10 then value(state, start.byte) else value(state, start.byte + 2)
			local finish = loc(state)

			if tonumber(string.gsub(value, "_", ""), base) then
				return { kind = "number", span = span_new(start, finish), value = value, trivia = trivia }
			else
				return { kind = "error", span = span_new(start, finish), value = value, trivia = trivia }
			end
		elseif c == char('"') or c == char("'") then
			local quote = c
			bump(state)

			while first(state) ~= quote do
				if first(state) == char("\n") or first(state) == 0 then
					local finish = loc(state)
					local value = value(state, start.byte)

					return { kind = "error", span = span_new(start, finish), value = value, trivia = trivia }
				elseif first(state) == char("\\") then
					bump(state)

					if first(state) == char("\r") and second(state) == char("\n") then
						bump(state)
						bump(state)

						state.line += 1
						state.char = 0
					elseif first(state) == char("z") then
						bump(state)

						while is_whitespace(first(state)) do
							if first(state) == char("\n") then
								state.line += 1
								state.char = 0
							end

							bump(state)
						end
					else
						if first(state) == char("\n") then
							state.line += 1
							state.char = 0
						end

						bump(state)
					end
				else
					bump(state)
				end
			end

			bump(state)

			local finish = loc(state)
			local value = value(state, start.byte)

			return { kind = "string", span = span_new(start, finish), value = value, trivia = trivia }
		elseif c == char("`") then
			bump(state)

			while true do
				if first(state) == char("`") then
					bump(state)

					local finish = loc(state)
					local value = value(state, start.byte)

					return { kind = "istringsimple", span = span_new(start, finish), value = value, trivia = trivia }
				elseif first(state) == 0 or first(state) == char("\n") then
					local finish = loc(state)
					local value = value(state, start.byte)

					return { kind = "error", span = span_new(start, finish), value = value, trivia = trivia }
				elseif first(state) == char("{") then
					bump(state)
					table.insert(state.brace_stack, state.brace_count)

					local finish = loc(state)
					local value = value(state, start.byte)

					return { kind = "istringbegin", span = span_new(start, finish), value = value, trivia = trivia }
				elseif first(state) == char("\\") then
					bump(state)

					if first(state) == char("\r") and second(state) == char("\n") then
						bump(state)
						bump(state)

						state.line += 1
						state.char = 0
					elseif first(state) == char("z") then
						bump(state)

						while is_whitespace(first(state)) do
							if first(state) == char("\n") then
								state.line += 1
								state.char = 0
							end

							bump(state)
						end
					elseif first(state) == char("u") and second(state) == char("{") then
						bump(state)
						bump(state)
					else
						if first(state) == char("\n") then
							state.line += 1
							state.char = 0
						end

						bump(state)
					end
				else
					bump(state)
				end
			end
		elseif c == char("}") then
			if #state.brace_stack ~= 0 and state.brace_stack[#state.brace_stack] == state.brace_count then
				state.brace_stack[#state.brace_stack] = nil
				bump(state)

				while true do
					if first(state) == char("`") then
						bump(state)

						local finish = loc(state)
						local value = value(state, start.byte)

						return { kind = "istringlast", span = span_new(start, finish), value = value, trivia = trivia }
					elseif first(state) == 0 or first(state) == char("\n") then
						local finish = loc(state)
						local value = value(state, start.byte)

						return { kind = "error", span = span_new(start, finish), value = value, trivia = trivia }
					elseif first(state) == char("{") then
						bump(state)
						table.insert(state.brace_stack, state.brace_count)

						local finish = loc(state)
						local value = value(state, start.byte)

						return { kind = "istringmiddle", span = span_new(start, finish), value = value, trivia = trivia }
					elseif first(state) == char("\\") then
						bump(state)

						if first(state) == char("\r") and second(state) == char("\n") then
							bump(state)
							bump(state)

							state.line += 1
							state.char = 0
						elseif first(state) == char("z") then
							bump(state)

							while is_whitespace(first(state)) do
								if first(state) == char("\n") then
									state.line += 1
									state.char = 0
								end

								bump(state)
							end
						elseif first(state) == char("u") and second(state) == char("{") then
							bump(state)
							bump(state)
						else
							if first(state) == char("\n") then
								state.line += 1
								state.char = 0
							end

							bump(state)
						end
					else
						bump(state)
					end
				end
			else
				state.brace_count -= 1
				bump(state)

				return { kind = "}", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("{") then
			state.brace_count += 1
			bump(state)

			return { kind = "{", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("[") then
			bump(state)

			if first(state) == char("[") or first(state) == char("=") then
				local eqs = 0

				while first(state) == char("=") do
					bump(state)
					eqs += 1
				end

				if first(state) == char("[") then
					bump(state)

					while true do
						if first(state) == 0 then
							local finish = loc(state)
							local value = value(state, start.byte)

							return { kind = "error", span = span_new(start, finish), value = value, trivia = trivia }
						elseif first(state) == char("]") then
							bump(state)
							local count = 0

							while first(state) == char("=") do
								count += 1
								bump(state)
							end

							if count == eqs and first(state) == char("]") then
								bump(state)
								break
							else
								bump(state)
							end
						elseif first(state) == char("\\") then
							bump(state)

							if first(state) == char("\r") and second(state) == char("\n") then
								bump(state)
								bump(state)

								state.line += 1
								state.char = 0
							elseif first(state) == char("z") then
								bump(state)

								while is_whitespace(first(state)) do
									if first(state) == char("\n") then
										state.line += 1
										state.char = 0
									end

									bump(state)
								end
							else
								if first(state) == char("\n") then
									state.line += 1
									state.char = 0
								end

								bump(state)
							end
						else
							bump(state)
						end
					end

					local finish = loc(state)
					local value = value(state, start.byte)

					return { kind = "string", span = span_new(start, finish), value = value, trivia = trivia }
				else
					local finish = loc(state)
					local value = value(state, start.byte)

					return { kind = "error", span = span_new(start, finish), value = value, trivia = trivia }
				end
			else
				return { kind = "[", span = span_new(start, loc(state)), trivia = trivia }
			end
		end

		bump(state)

		if c == char(",") then
			return { kind = ",", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("(") then
			return { kind = "(", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char(")") then
			return { kind = ")", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("=") then
			if first(state) == char("=") then
				bump(state)
				return { kind = "==", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "=", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char(".") then
			if first(state) == char(".") then
				bump(state)

				if first(state) == char(".") then
					bump(state)
					return { kind = "...", span = span_new(start, loc(state)), trivia = trivia }
				elseif first(state) == char("=") then
					bump(state)
					return { kind = "..=", span = span_new(start, loc(state)), trivia = trivia }
				else
					return { kind = "..", span = span_new(start, loc(state)), trivia = trivia }
				end
			else
				return { kind = ".", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char(":") then
			if first(state) == char(":") then
				bump(state)
				return { kind = "::", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = ":", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char(">") then
			if first(state) == char("=") then
				bump(state)
				return { kind = ">=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = ">", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("<") then
			if first(state) == char("=") then
				bump(state)
				return { kind = "<=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "<", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("]") then
			return { kind = "]", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("-") then
			if first(state) == char(">") then
				bump(state)
				return { kind = "->", span = span_new(start, loc(state)), trivia = trivia }
			elseif first(state) == char("=") then
				bump(state)
				return { kind = "-=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "-", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("|") then
			return { kind = "|", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("?") then
			return { kind = "?", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("+") then
			if first(state) == char("=") then
				bump(state)
				return { kind = "+=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "+", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("*") then
			if first(state) == char("=") then
				bump(state)
				return { kind = "*=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "*", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("#") then
			return { kind = "#", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("&") then
			return { kind = "&", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("~") and first(state) == char("=") then
			bump(state)

			return { kind = "~=", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("^") then
			if first(state) == char("=") then
				bump(state)
				return { kind = "^=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "^", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char("/") then
			if first(state) == char("/") then
				bump(state)

				if first(state) == char("=") then
					bump(state)
					return { kind = "//=", span = span_new(start, loc(state)), trivia = trivia }
				else
					return { kind = "//", span = span_new(start, loc(state)), trivia = trivia }
				end
			elseif first(state) == char("=") then
				bump(state)
				return { kind = "/=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "/", span = span_new(start, loc(state)), trivia = trivia }
			end
		elseif c == char(";") then
			return { kind = ";", span = span_new(start, loc(state)), trivia = trivia }
		elseif c == char("%") then
			if first(state) == char("=") then
				bump(state)
				return { kind = "%=", span = span_new(start, loc(state)), trivia = trivia }
			else
				return { kind = "%", span = span_new(start, loc(state)), trivia = trivia }
			end
		else
			return { kind = "error", span = span_new(start, loc(state)), value = string.char(c), trivia = trivia }
		end
	end
end

export type AstDelim<Open, Close> = { open: TokenType<Open>, close: TokenType<Close> }

export type AstPair<Sep, Item> = { item: Item, sep: Sep? }

export type AstSeparated<Sep, Item> = { AstPair<Sep, Item> }

export type AstIStringSimple = {
	kind: "simple",
	tok: TokenIStringSimple,
}

export type AstIStringComplex = {
	kind: "complex",
	begin: TokenIStringBegin,
	middle: AstSeparated<TokenIStringMiddle, AstExpr>,
	last: TokenIStringLast,
}

export type AstIString = AstIStringSimple | AstIStringComplex

export type AstTypeNil = {
	kind: "nil",
	tok: TokenType<"nil">,
}

export type AstTypeTrue = {
	kind: "true",
	tok: TokenType<"true">,
}

export type AstTypeFalse = {
	kind: "false",
	tok: TokenType<"false">,
}

export type AstTypeString = {
	kind: "string",
	tok: TokenString,
}

export type AstTypeReference = {
	kind: "reference",
	prefix: { name: TokenIdent, dot: TokenType<"."> }?,
	name: TokenIdent,
	generics: {
		angles: AstDelim<"<", ">">,
		types: AstSeparated<TokenType<",">, AstType | AstTypePack>,
	}?,
}

export type AstTypeTypeof = {
	kind: "typeof",
	tok: TokenIdent<"typeof">,
	parens: AstDelim<"(", ")">,
	expr: AstExpr,
}

export type AstTypeArray = {
	kind: "array",
	braces: AstDelim<"{", "}">,
	type: AstType,
}

export type AstTypeTable = {
	kind: "table",
	braces: AstDelim<"{", "}">,
	fields: AstSeparated<TokenType<","> | TokenType<";">, AstTypeTableField>,
}

export type AstTypeTableFieldNameProp = {
	kind: "nameprop",
	key: TokenIdent,
	colon: TokenType<":">,
	value: AstType,
}

export type AstTypeTableFieldStringProp = {
	kind: "stringprop",
	bracks: AstDelim<"[", "]">,
	key: TokenString,
	colon: TokenType<":">,
	value: AstType,
}

export type AstTypeTableFieldIndexer = {
	kind: "indexer",
	bracks: AstDelim<"[", "]">,
	key: AstType,
	colon: TokenType<":">,
	value: AstType,
}

export type AstTypeTableField = AstTypeTableFieldNameProp | AstTypeTableFieldStringProp | AstTypeTableFieldIndexer

export type AstTypeFunction = {
	kind: "function",
	generics: AstGenericTypeList?,
	parens: AstDelim<"(", ")">,
	params: AstSeparated<TokenType<",">, {
		name: { name: TokenIdent, colon: TokenType<":"> }?,
		type: AstType,
	}>,
	tail: AstTypePackTail?,
	arrow: TokenType<"->">,
	returns: AstReturnType,
}

export type AstTypeParen = {
	kind: "paren",
	parens: AstDelim<"(", ")">,
	type: AstType,
}

export type AstTypeOptional = {
	kind: "optional",
	type: AstType,
	question: TokenType<"?">,
}

export type AstTypeUnion = {
	kind: "union",
	leading: TokenType<"|">?,
	types: AstSeparated<TokenType<"|">, AstType>,
}

export type AstTypeIntersection = {
	kind: "intersection",
	leading: TokenType<"&">?,
	types: AstSeparated<TokenType<"&">, AstType>,
}

export type AstType =
	AstTypeNil
	| AstTypeTrue
	| AstTypeFalse
	| AstTypeString
	| AstTypeReference
	| AstTypeTypeof
	| AstTypeArray
	| AstTypeTable
	| AstTypeFunction
	| AstTypeParen
	| AstTypeOptional
	| AstTypeUnion
	| AstTypeIntersection

export type AstReturnType = AstType | AstTypePack

export type AstTypePackVariadic = {
	kind: "variadic",
	dots: TokenType<"...">,
	type: AstType,
}

export type AstTypePackGeneric = {
	kind: "generic",
	name: TokenIdent,
	dots: TokenType<"...">,
}

export type AstTypePackTail = AstTypePackVariadic | AstTypePackGeneric

export type AstTypePackList = {
	kind: "list",
	parens: AstDelim<"(", ")">,
	types: AstSeparated<TokenType<",">, AstType>,
	tail: AstTypePackTail?,
}

export type AstTypePack = AstTypePackList | AstTypePackVariadic | AstTypePackGeneric

export type AstGenericTypeList = {
	angles: AstDelim<"<", ">">,
	names: AstSeparated<TokenType<",">, TokenIdent>,
	packs: AstSeparated<TokenType<",">, { name: TokenIdent, dots: TokenType<"..."> }>,
}

export type AstGenericTypeListWithDefaults = {
	angles: AstDelim<"<", ">">,
	names: AstSeparated<TokenType<",">, { name: TokenIdent, default: { eq: TokenType<"=">, type: AstType }? }>,
	packs: AstSeparated<TokenType<",">, {
		name: TokenIdent,
		dots: TokenType<"...">,
		default: { eq: TokenType<"=">, pack: AstTypePack }?,
	}>,
}

export type AstBinding = {
	name: TokenIdent,
	type: { colon: TokenType<":">, type: AstType }?,
}

export type AstExprNil = {
	kind: "nil",
	tok: TokenType<"nil">,
}

export type AstExprBoolean = {
	kind: "boolean",
	tok: TokenType<"true"> | TokenType<"false">,
}

export type AstExprNumber = {
	kind: "number",
	tok: TokenNumber,
}

export type AstExprString = {
	kind: "string",
	tok: TokenString,
}

export type AstExprVarargs = {
	kind: "varargs",
	tok: TokenType<"...">,
}

export type AstExprIString = {
	kind: "istring",
	istring: AstIString,
}

export type AstExprTable = {
	kind: "table",
	table: AstTable,
}

export type AstExprFunction = {
	kind: "function",
	attributes: { TokenAttribute },
	function_tok: TokenType<"function">,
	body: AstFunctionBody,
}

export type AstExprIfElse = {
	kind: "ifelse",
	if_tok: TokenType<"if">,
	condition: AstExpr,
	then_tok: TokenType<"then">,
	if_expr: AstExpr,
	elseifs: {
		{
			elseif_tok: TokenType<"elseif">,
			condition: AstExpr,
			then_tok: TokenType<"then">,
			elseif_expr: AstExpr,
		}
	},
	else_tok: TokenType<"else">,
	else_expr: AstExpr,
}

export type AstExprVar = {
	kind: "var",
	var: AstVar,
}

export type AstExprAssertion = {
	kind: "assertion",
	expr: AstExpr,
	colons: TokenType<"::">,
	type: AstType,
}

export type AstUnaryOp = TokenType<"+"> | TokenType<"-"> | TokenType<"not"> | TokenType<"#">

export type AstExprUnary = {
	kind: "unary",
	op: AstUnaryOp,
	rhs: AstExpr,
}

export type AstBinaryOp =
	TokenType<"+">
	| TokenType<"-">
	| TokenType<"*">
	| TokenType<"/">
	| TokenType<"//">
	| TokenType<"%">
	| TokenType<"^">
	| TokenType<"..">
	| TokenType<"<">
	| TokenType<"<=">
	| TokenType<">">
	| TokenType<">=">
	| TokenType<"==">
	| TokenType<"~=">
	| TokenType<"and">
	| TokenType<"or">

export type AstExprBinary = {
	kind: "binary",
	lhs: AstExpr,
	op: AstBinaryOp,
	rhs: AstExpr,
}

export type AstExpr =
	AstExprNil
	| AstExprBoolean
	| AstExprNumber
	| AstExprString
	| AstExprVarargs
	| AstExprIString
	| AstExprTable
	| AstExprFunction
	| AstExprIfElse
	| AstExprVar
	| AstExprAssertion
	| AstExprUnary
	| AstExprBinary

export type AstVarName = {
	kind: "name",
	tok: TokenIdent,
}

export type AstVarExpr = {
	kind: "expr",
	parens: AstDelim<"(", ")">,
	expr: AstExpr,
}

export type AstVarIndexName = {
	kind: "indexname",
	lhs: AstVar,
	dot: TokenType<".">,
	name: TokenIdent,
}

export type AstVarIndexExpr = {
	kind: "indexexpr",
	lhs: AstVar,
	bracks: AstDelim<"[", "]">,
	expr: AstExpr,
}

export type AstVarCall = {
	kind: "call",
	call: AstFunctionCall,
}

export type AstVar = AstVarName | AstVarExpr | AstVarIndexName | AstVarIndexExpr | AstVarCall

export type AstFunctionCall = {
	lhs: AstVar,
	method: { colon: TokenType<":">, name: TokenIdent }?,
	args: AstFunctionArgs,
}

export type AstFunctionArgsExprList = {
	kind: "exprlist",
	parens: AstDelim<"(", ")">,
	exprs: AstSeparated<TokenType<",">, AstExpr>,
}

export type AstFunctionArgsTable = {
	kind: "table",
	table: AstTable,
}

export type AstFunctionArgsString = {
	kind: "string",
	tok: TokenString,
}

export type AstFunctionArgs = AstFunctionArgsExprList | AstFunctionArgsTable | AstFunctionArgsString

export type AstTable = {
	braces: AstDelim<"{", "}">,
	fields: AstSeparated<TokenType<","> | TokenType<";">, AstTableField>,
}

export type AstTableFieldExprKey = {
	kind: "exprkey",
	bracks: AstDelim<"[", "]">,
	key: AstExpr,
	eq: TokenType<"=">,
	value: AstExpr,
}

export type AstTableFieldNameKey = {
	kind: "namekey",
	key: TokenIdent,
	eq: TokenType<"=">,
	value: AstExpr,
}

export type AstTableFieldNoKey = {
	kind: "nokey",
	value: AstExpr,
}

export type AstTableField = AstTableFieldExprKey | AstTableFieldNameKey | AstTableFieldNoKey

export type AstFunctionBody = {
	generics: AstGenericTypeList?,
	parens: AstDelim<"(", ")">,
	params: AstSeparated<TokenType<",">, AstBinding>,
	varargs: { dots: TokenType<"...">, type: { colon: TokenType<":">, type: AstTypePackGeneric | AstType }? }?,
	returns: { colon: TokenType<":">, type: AstReturnType }?,
	block: AstBlock,
	end_tok: TokenType<"end">,
}

export type AstStatAssign = {
	kind: "assign",
	lhs: AstSeparated<TokenType<",">, AstVar>,
	eq: TokenType<"=">,
	rhs: AstSeparated<TokenType<",">, AstExpr>,
}

export type AstCompoundOp =
	TokenType<"+=">
	| TokenType<"-=">
	| TokenType<"*=">
	| TokenType<"/=">
	| TokenType<"//=">
	| TokenType<"%=">
	| TokenType<"^=">
	| TokenType<"..=">

export type AstStatCompoundAssign = {
	kind: "compoundassign",
	lhs: AstVar,
	op: AstCompoundOp,
	rhs: AstExpr,
}

export type AstStatCall = {
	kind: "call",
	call: AstFunctionCall,
}

export type AstStatDo = {
	kind: "do",
	do_tok: TokenType<"do">,
	block: AstBlock,
	end_tok: TokenType<"end">,
}

export type AstStatWhile = {
	kind: "while",
	while_tok: TokenType<"while">,
	condition: AstExpr,
	do_tok: TokenType<"do">,
	block: AstBlock,
	end_tok: TokenType<"end">,
}

export type AstStatRepeat = {
	kind: "repeat",
	repeat_tok: TokenType<"repeat">,
	block: AstBlock,
	until_tok: TokenType<"until">,
	condition: AstExpr,
}

export type AstStatIf = {
	kind: "if",
	if_tok: TokenType<"if">,
	condition: AstExpr,
	then_tok: TokenType<"then">,
	block: AstBlock,
	elseifs: { { elseif_tok: TokenType<"elseif">, condition: AstExpr, then_tok: TokenType<"then">, block: AstBlock } },
	else_: { else_tok: TokenType<"else">, block: AstBlock }?,
	end_tok: TokenType<"end">,
}

export type AstStatNumericFor = {
	kind: "numericfor",
	for_tok: TokenType<"for">,
	binding: AstBinding,
	eq: TokenType<"=">,
	start: AstExpr,
	comma: TokenType<",">,
	finish: AstExpr,
	step: { comma: TokenType<",">, expr: AstExpr }?,
	do_tok: TokenType<"do">,
	block: AstBlock,
	end_tok: TokenType<"end">,
}

export type AstStatGenericFor = {
	kind: "genericfor",
	for_tok: TokenType<"for">,
	bindings: AstSeparated<TokenType<",">, AstBinding>,
	in_tok: TokenType<"in">,
	exprs: AstSeparated<TokenType<",">, AstExpr>,
	do_tok: TokenType<"do">,
	block: AstBlock,
	end_tok: TokenType<"end">,
}

export type AstStatFunction = {
	kind: "function",
	attributes: { TokenAttribute },
	function_tok: TokenType<"function">,
	names: AstSeparated<TokenType<".">, TokenIdent>,
	method: { colon: TokenType<":">, name: TokenIdent }?,
	body: AstFunctionBody,
}

export type AstStatLocalFunction = {
	kind: "localfunction",
	attributes: { TokenAttribute },
	local_tok: TokenType<"local">,
	function_tok: TokenType<"function">,
	name: TokenIdent,
	body: AstFunctionBody,
}

export type AstStatLocalAssign = {
	kind: "localassign",
	local_tok: TokenType<"local">,
	bindings: AstSeparated<TokenType<",">, AstBinding>,
	values: {
		eq: TokenType<"=">,
		exprs: AstSeparated<TokenType<",">, AstExpr>,
	}?,
}

export type AstStatType = {
	kind: "type",
	export_tok: TokenIdent<"export">?,
	type_tok: TokenIdent<"type">,
	name: TokenIdent,
	generics: AstGenericTypeListWithDefaults?,
	eq: TokenType<"=">,
	type: AstType,
}

export type AstStat =
	AstStatAssign
	| AstStatCompoundAssign
	| AstStatCall
	| AstStatDo
	| AstStatWhile
	| AstStatRepeat
	| AstStatIf
	| AstStatNumericFor
	| AstStatGenericFor
	| AstStatFunction
	| AstStatLocalFunction
	| AstStatLocalAssign
	| AstStatType

export type AstLastStatReturn = {
	kind: "return",
	return_tok: TokenType<"return">,
	exprs: AstSeparated<TokenType<",">, AstExpr>,
}

export type AstLastStatBreak = {
	kind: "break",
	tok: TokenType<"break">,
}

export type AstLastStatContinue = {
	kind: "continue",
	tok: TokenIdent<"continue">,
}

export type AstLastStat = AstLastStatReturn | AstLastStatBreak | AstLastStatContinue

export type AstBlock = {
	stats: { { stat: AstStat, semicolon: TokenType<";">? } },
	laststat: { stat: AstLastStat, semicolon: TokenType<";">? }?,
}

export type Ast = {
	block: AstBlock,
	eof: TokenType<"eof">,
}

local ast_span_istring: (istring: AstIString) -> Span
local ast_span_type: (type: AstType) -> Span
local ast_span_type_table_field: (field: AstTypeTableField) -> Span
local ast_span_return_type: (type: AstReturnType) -> Span
local ast_span_type_pack: (pack: AstTypePack) -> Span
local ast_span_generic_type_list: (generics: AstGenericTypeList) -> Span
local ast_span_generic_type_list_with_defaults: (generics: AstGenericTypeListWithDefaults) -> Span
local ast_span_binding: (binding: AstBinding) -> Span
local ast_span_expr: (expr: AstExpr) -> Span
local ast_span_var: (var: AstVar) -> Span
local ast_span_function_call: (call: AstFunctionCall) -> Span
local ast_span_function_args: (args: AstFunctionArgs) -> Span
local ast_span_table: (table: AstTable) -> Span
local ast_span_table_field: (field: AstTableField) -> Span
local ast_span_function_body: (body: AstFunctionBody) -> Span
local ast_span_stat: (stat: AstStat) -> Span
local ast_span_laststat: (stat: AstLastStat) -> Span
local ast_span_block: (block: AstBlock) -> Span

do
	function ast_span_istring(istring: AstIString): Span
		if istring.kind == "simple" then
			return istring.tok.span
		elseif istring.kind == "complex" then
			return span_merge(istring.begin.span, istring.last.span)
		else
			error("unreachable")
		end
	end

	function ast_span_type(type: AstType): Span
		if type.kind == "nil" or type.kind == "true" or type.kind == "false" or type.kind == "string" then
			return type.tok.span
		elseif type.kind == "reference" then
			return span_merge(
				if type.prefix then type.prefix.name.span else type.name.span,
				if type.generics then type.generics.angles.close.span else type.name.span
			)
		elseif type.kind == "typeof" then
			return span_merge(type.tok.span, ast_span_expr(type.expr))
		elseif type.kind == "array" then
			return span_merge(type.braces.open.span, type.braces.close.span)
		elseif type.kind == "table" then
			return span_merge(type.braces.open.span, type.braces.close.span)
		elseif type.kind == "function" then
			return span_merge(
				if type.generics then type.generics.angles.open.span else type.parens.open.span,
				ast_span_return_type(type.returns)
			)
		elseif type.kind == "paren" then
			return span_merge(type.parens.open.span, type.parens.close.span)
		elseif type.kind == "optional" then
			return span_merge(ast_span_type(type.type), type.question.span)
		elseif type.kind == "union" then
			return span_merge(
				if type.leading then type.leading.span else ast_span_type(type.types[1].item),
				ast_span_type(type.types[#type.types].item)
			)
		elseif type.kind == "intersection" then
			return span_merge(
				if type.leading then type.leading.span else ast_span_type(type.types[1].item),
				ast_span_type(type.types[#type.types].item)
			)
		else
			error("unreachable")
		end
	end

	function ast_span_type_table_field(field: AstTypeTableField): Span
		if field.kind == "nameprop" then
			return span_merge(field.key.span, ast_span_type(field.value))
		elseif field.kind == "stringprop" then
			return span_merge(field.bracks.open.span, ast_span_type(field.value))
		elseif field.kind == "indexer" then
			return span_merge(field.bracks.open.span, ast_span_type(field.value))
		else
			error("unreachable")
		end
	end

	function ast_span_return_type(return_type: AstReturnType): Span
		if return_type.kind == "list" or return_type.kind == "variadic" or return_type.kind == "generic" then
			return ast_span_type_pack(return_type)
		else
			return ast_span_type(return_type)
		end
	end

	function ast_span_type_pack(pack: AstTypePack): Span
		if pack.kind == "list" then
			return span_merge(pack.parens.open.span, pack.parens.close.span)
		elseif pack.kind == "variadic" then
			return span_merge(pack.dots.span, ast_span_type(pack.type))
		elseif pack.kind == "generic" then
			return span_merge(pack.name.span, pack.dots.span)
		else
			error("unreachable")
		end
	end

	function ast_span_generic_type_list(generics: AstGenericTypeList): Span
		return span_merge(generics.angles.open.span, generics.angles.close.span)
	end

	function ast_span_generic_type_list_with_defaults(generics: AstGenericTypeListWithDefaults): Span
		return span_merge(generics.angles.open.span, generics.angles.close.span)
	end

	function ast_span_binding(binding: AstBinding): Span
		if binding.type then
			return span_merge(binding.name.span, ast_span_type(binding.type.type))
		else
			return binding.name.span
		end
	end

	function ast_span_expr(expr: AstExpr): Span
		if
			expr.kind == "nil"
			or expr.kind == "boolean"
			or expr.kind == "number"
			or expr.kind == "string"
			or expr.kind == "varargs"
		then
			return expr.tok.span
		elseif expr.kind == "istring" then
			return ast_span_istring(expr.istring)
		elseif expr.kind == "table" then
			return ast_span_table(expr.table)
		elseif expr.kind == "function" then
			return span_merge(expr.function_tok.span, ast_span_function_body(expr.body))
		elseif expr.kind == "ifelse" then
			return span_merge(expr.if_tok.span, ast_span_expr(expr.else_expr))
		elseif expr.kind == "var" then
			return ast_span_var(expr.var)
		elseif expr.kind == "assertion" then
			return span_merge(ast_span_expr(expr.expr), ast_span_type(expr.type))
		elseif expr.kind == "unary" then
			return span_merge(expr.op.span, ast_span_expr(expr.rhs))
		elseif expr.kind == "binary" then
			return span_merge(ast_span_expr(expr.lhs), ast_span_expr(expr.rhs))
		else
			error("unreachable")
		end
	end

	function ast_span_var(var: AstVar): Span
		if var.kind == "name" then
			return var.tok.span
		elseif var.kind == "expr" then
			return span_merge(var.parens.open.span, var.parens.close.span)
		elseif var.kind == "indexname" then
			return span_merge(ast_span_var(var.lhs), var.name.span)
		elseif var.kind == "indexexpr" then
			return span_merge(ast_span_var(var.lhs), var.bracks.close.span)
		elseif var.kind == "call" then
			return ast_span_function_call(var.call)
		else
			error("unreachable")
		end
	end

	function ast_span_function_call(call: AstFunctionCall): Span
		return span_merge(ast_span_var(call.lhs), ast_span_function_args(call.args))
	end

	function ast_span_function_args(args: AstFunctionArgs): Span
		if args.kind == "exprlist" then
			return span_merge(args.parens.open.span, args.parens.close.span)
		elseif args.kind == "table" then
			return ast_span_table(args.table)
		elseif args.kind == "string" then
			return args.tok.span
		else
			error("unreachable")
		end
	end

	function ast_span_table(table: AstTable): Span
		return span_merge(table.braces.open.span, table.braces.close.span)
	end

	function ast_span_table_field(field: AstTableField): Span
		if field.kind == "exprkey" then
			return span_merge(field.bracks.open.span, ast_span_expr(field.value))
		elseif field.kind == "namekey" then
			return span_merge(field.key.span, ast_span_expr(field.value))
		elseif field.kind == "nokey" then
			return ast_span_expr(field.value)
		else
			error("unreachable")
		end
	end

	function ast_span_function_body(body: AstFunctionBody): Span
		return span_merge(
			if body.generics then body.generics.angles.open.span else body.parens.open.span,
			body.end_tok.span
		)
	end

	function ast_span_stat(stat: AstStat): Span
		if stat.kind == "assign" then
			return span_merge(ast_span_var(stat.lhs[1].item), ast_span_expr(stat.rhs[#stat.rhs].item))
		elseif stat.kind == "compoundassign" then
			return span_merge(ast_span_var(stat.lhs), ast_span_expr(stat.rhs))
		elseif stat.kind == "call" then
			return ast_span_function_call(stat.call)
		elseif stat.kind == "do" then
			return span_merge(stat.do_tok.span, stat.end_tok.span)
		elseif stat.kind == "while" then
			return span_merge(stat.while_tok.span, stat.end_tok.span)
		elseif stat.kind == "repeat" then
			return span_merge(stat.repeat_tok.span, ast_span_expr(stat.condition))
		elseif stat.kind == "if" then
			return span_merge(stat.if_tok.span, stat.end_tok.span)
		elseif stat.kind == "numericfor" then
			return span_merge(stat.for_tok.span, stat.end_tok.span)
		elseif stat.kind == "genericfor" then
			return span_merge(stat.for_tok.span, stat.end_tok.span)
		elseif stat.kind == "function" then
			return span_merge(stat.function_tok.span, ast_span_function_body(stat.body))
		elseif stat.kind == "localfunction" then
			return span_merge(stat.local_tok.span, ast_span_function_body(stat.body))
		elseif stat.kind == "localassign" then
			if stat.values then
				return span_merge(stat.local_tok.span, ast_span_expr(stat.values.exprs[#stat.values.exprs].item))
			else
				local last_binding = stat.bindings[#stat.bindings].item

				if last_binding.type then
					return span_merge(stat.local_tok.span, ast_span_type(last_binding.type.type))
				else
					return span_merge(stat.local_tok.span, last_binding.name.span)
				end
			end
		elseif stat.kind == "type" then
			return span_merge(
				if stat.export_tok then stat.export_tok.span else stat.type_tok.span,
				ast_span_type(stat.type)
			)
		else
			error("unreachable")
		end
	end

	function ast_span_laststat(stat: AstLastStat): Span
		if stat.kind == "return" then
			return span_merge(stat.return_tok.span, ast_span_expr(stat.exprs[#stat.exprs].item))
		elseif stat.kind == "break" then
			return stat.tok.span
		elseif stat.kind == "continue" then
			return stat.tok.span
		else
			error("unreachable")
		end
	end

	function ast_span_block(block: AstBlock): Span
		local laststat = block.laststat

		if laststat then
			return span_merge(ast_span_stat(block.stats[1].stat), ast_span_laststat(laststat.stat))
		else
			return span_merge(ast_span_stat(block.stats[1].stat), ast_span_stat(block.stats[#block.stats].stat))
		end
	end
end

export type Visitor<Self> = {
	token: (self: Self, token: Token) -> (),

	istring_simple: (self: Self, istring: AstIStringSimple) -> AstIStringSimple,
	istring_simple_end: (self: Self, istring: AstIStringSimple) -> AstIStringSimple,
	istring_complex: (self: Self, istring: AstIStringComplex) -> AstIStringComplex,
	istring_complex_end: (self: Self, istring: AstIStringComplex) -> AstIStringComplex,
	istring: (self: Self, istring: AstIString) -> AstIString,
	istring_end: (self: Self, istring: AstIString) -> AstIString,

	type_nil: (self: Self, type: AstTypeNil) -> AstTypeNil,
	type_nil_end: (self: Self, type: AstTypeNil) -> AstTypeNil,
	type_true: (self: Self, type: AstTypeTrue) -> AstTypeTrue,
	type_true_end: (self: Self, type: AstTypeTrue) -> AstTypeTrue,
	type_false: (self: Self, type: AstTypeFalse) -> AstTypeFalse,
	type_false_end: (self: Self, type: AstTypeFalse) -> AstTypeFalse,
	type_string: (self: Self, type: AstTypeString) -> AstTypeString,
	type_string_end: (self: Self, type: AstTypeString) -> AstTypeString,
	type_reference: (self: Self, type: AstTypeReference) -> AstTypeReference,
	type_reference_end: (self: Self, type: AstTypeReference) -> AstTypeReference,
	type_typeof: (self: Self, type: AstTypeTypeof) -> AstTypeTypeof,
	type_typeof_end: (self: Self, type: AstTypeTypeof) -> AstTypeTypeof,
	type_array: (self: Self, type: AstTypeArray) -> AstTypeArray,
	type_array_end: (self: Self, type: AstTypeArray) -> AstTypeArray,
	type_table: (self: Self, type: AstTypeTable) -> AstTypeTable,
	type_table_end: (self: Self, type: AstTypeTable) -> AstTypeTable,
	type_function: (self: Self, type: AstTypeFunction) -> AstTypeFunction,
	type_function_end: (self: Self, type: AstTypeFunction) -> AstTypeFunction,
	type_paren: (self: Self, type: AstTypeParen) -> AstTypeParen,
	type_paren_end: (self: Self, type: AstTypeParen) -> AstTypeParen,
	type_optional: (self: Self, type: AstTypeOptional) -> AstTypeOptional,
	type_optional_end: (self: Self, type: AstTypeOptional) -> AstTypeOptional,
	type_union: (self: Self, type: AstTypeUnion) -> AstTypeUnion,
	type_union_end: (self: Self, type: AstTypeUnion) -> AstTypeUnion,
	type_intersection: (self: Self, type: AstTypeIntersection) -> AstTypeIntersection,
	type_intersection_end: (self: Self, type: AstTypeIntersection) -> AstTypeIntersection,
	type: (self: Self, type: AstType) -> AstType,
	type_end: (self: Self, type: AstType) -> AstType,

	type_table_field_name_prop: (self: Self, field: AstTypeTableFieldNameProp) -> AstTypeTableFieldNameProp,
	type_table_field_name_prop_end: (self: Self, field: AstTypeTableFieldNameProp) -> AstTypeTableFieldNameProp,
	type_table_field_string_prop: (self: Self, field: AstTypeTableFieldStringProp) -> AstTypeTableFieldStringProp,
	type_table_field_string_prop_end: (self: Self, field: AstTypeTableFieldStringProp) -> AstTypeTableFieldStringProp,
	type_table_field_indexer: (self: Self, field: AstTypeTableFieldIndexer) -> AstTypeTableFieldIndexer,
	type_table_field_indexer_end: (self: Self, field: AstTypeTableFieldIndexer) -> AstTypeTableFieldIndexer,
	type_table_field: (self: Self, field: AstTypeTableField) -> AstTypeTableField,
	type_table_field_end: (self: Self, field: AstTypeTableField) -> AstTypeTableField,

	return_type: (self: Self, type: AstReturnType) -> AstReturnType,
	return_type_end: (self: Self, type: AstReturnType) -> AstReturnType,

	type_pack_list: (self: Self, pack: AstTypePackList) -> AstTypePackList,
	type_pack_list_end: (self: Self, pack: AstTypePackList) -> AstTypePackList,
	type_pack_variadic: (self: Self, pack: AstTypePackVariadic) -> AstTypePackVariadic,
	type_pack_variadic_end: (self: Self, pack: AstTypePackVariadic) -> AstTypePackVariadic,
	type_pack_generic: (self: Self, pack: AstTypePackGeneric) -> AstTypePackGeneric,
	type_pack_generic_end: (self: Self, pack: AstTypePackGeneric) -> AstTypePackGeneric,
	type_pack_tail: (self: Self, pack: AstTypePackTail) -> AstTypePackTail,
	type_pack_tail_end: (self: Self, pack: AstTypePackTail) -> AstTypePackTail,
	type_pack: (self: Self, pack: AstTypePack) -> AstTypePack,
	type_pack_end: (self: Self, pack: AstTypePack) -> AstTypePack,

	generic_type_list: (self: Self, generics: AstGenericTypeList) -> AstGenericTypeList,
	generic_type_list_end: (self: Self, generics: AstGenericTypeList) -> AstGenericTypeList,
	generic_type_list_with_defaults: (
		self: Self,
		generics: AstGenericTypeListWithDefaults
	) -> AstGenericTypeListWithDefaults,
	generic_type_list_with_defaults_end: (
		self: Self,
		generics: AstGenericTypeListWithDefaults
	) -> AstGenericTypeListWithDefaults,

	binding: (self: Self, binding: AstBinding) -> AstBinding,
	binding_end: (self: Self, binding: AstBinding) -> AstBinding,

	expr_nil: (self: Self, expr: AstExprNil) -> AstExprNil,
	expr_nil_end: (self: Self, expr: AstExprNil) -> AstExprNil,
	expr_boolean: (self: Self, expr: AstExprBoolean) -> AstExprBoolean,
	expr_boolean_end: (self: Self, expr: AstExprBoolean) -> AstExprBoolean,
	expr_number: (self: Self, expr: AstExprNumber) -> AstExprNumber,
	expr_number_end: (self: Self, expr: AstExprNumber) -> AstExprNumber,
	expr_string: (self: Self, expr: AstExprString) -> AstExprString,
	expr_string_end: (self: Self, expr: AstExprString) -> AstExprString,
	expr_varargs: (self: Self, expr: AstExprVarargs) -> AstExprVarargs,
	expr_varargs_end: (self: Self, expr: AstExprVarargs) -> AstExprVarargs,
	expr_istring: (self: Self, expr: AstExprIString) -> AstExprIString,
	expr_istring_end: (self: Self, expr: AstExprIString) -> AstExprIString,
	expr_table: (self: Self, expr: AstExprTable) -> AstExprTable,
	expr_table_end: (self: Self, expr: AstExprTable) -> AstExprTable,
	expr_function: (self: Self, expr: AstExprFunction) -> AstExprFunction,
	expr_function_end: (self: Self, expr: AstExprFunction) -> AstExprFunction,
	expr_ifelse: (self: Self, expr: AstExprIfElse) -> AstExprIfElse,
	expr_ifelse_end: (self: Self, expr: AstExprIfElse) -> AstExprIfElse,
	expr_var: (self: Self, expr: AstExprVar) -> AstExprVar,
	expr_var_end: (self: Self, expr: AstExprVar) -> AstExprVar,
	expr_assertion: (self: Self, expr: AstExprAssertion) -> AstExprAssertion,
	expr_assertion_end: (self: Self, expr: AstExprAssertion) -> AstExprAssertion,
	expr_unary: (self: Self, expr: AstExprUnary) -> AstExprUnary,
	expr_unary_end: (self: Self, expr: AstExprUnary) -> AstExprUnary,
	expr_binary: (self: Self, expr: AstExprBinary) -> AstExprBinary,
	expr_binary_end: (self: Self, expr: AstExprBinary) -> AstExprBinary,
	expr: (self: Self, expr: AstExpr) -> AstExpr,
	expr_end: (self: Self, expr: AstExpr) -> AstExpr,

	unary_op: (self: Self, op: AstUnaryOp) -> AstUnaryOp,
	unary_op_end: (self: Self, op: AstUnaryOp) -> AstUnaryOp,
	binary_op: (self: Self, op: AstBinaryOp) -> AstBinaryOp,
	binary_op_end: (self: Self, op: AstBinaryOp) -> AstBinaryOp,

	var_name: (self: Self, var: AstVarName) -> AstVarName,
	var_name_end: (self: Self, var: AstVarName) -> AstVarName,
	var_expr: (self: Self, var: AstVarExpr) -> AstVarExpr,
	var_expr_end: (self: Self, var: AstVarExpr) -> AstVarExpr,
	var_index_name: (self: Self, var: AstVarIndexName) -> AstVarIndexName,
	var_index_name_end: (self: Self, var: AstVarIndexName) -> AstVarIndexName,
	var_index_expr: (self: Self, var: AstVarIndexExpr) -> AstVarIndexExpr,
	var_index_expr_end: (self: Self, var: AstVarIndexExpr) -> AstVarIndexExpr,
	var_call: (self: Self, var: AstVarCall) -> AstVarCall,
	var_call_end: (self: Self, var: AstVarCall) -> AstVarCall,
	var: (self: Self, var: AstVar) -> AstVar,
	var_end: (self: Self, var: AstVar) -> AstVar,

	function_call: (self: Self, call: AstFunctionCall) -> AstFunctionCall,
	function_call_end: (self: Self, call: AstFunctionCall) -> AstFunctionCall,

	function_args_expr_list: (self: Self, args: AstFunctionArgsExprList) -> AstFunctionArgsExprList,
	function_args_expr_list_end: (self: Self, args: AstFunctionArgsExprList) -> AstFunctionArgsExprList,
	function_args_table: (self: Self, args: AstFunctionArgsTable) -> AstFunctionArgsTable,
	function_args_table_end: (self: Self, args: AstFunctionArgsTable) -> AstFunctionArgsTable,
	function_args_string: (self: Self, args: AstFunctionArgsString) -> AstFunctionArgsString,
	function_args_string_end: (self: Self, args: AstFunctionArgsString) -> AstFunctionArgsString,
	function_args: (self: Self, args: AstFunctionArgs) -> AstFunctionArgs,
	function_args_end: (self: Self, args: AstFunctionArgs) -> AstFunctionArgs,

	table: (self: Self, table: AstTable) -> AstTable,
	table_end: (self: Self, table: AstTable) -> AstTable,

	table_field_expr_key: (self: Self, field: AstTableFieldExprKey) -> AstTableFieldExprKey,
	table_field_expr_key_end: (self: Self, field: AstTableFieldExprKey) -> AstTableFieldExprKey,
	table_field_name_key: (self: Self, field: AstTableFieldNameKey) -> AstTableFieldNameKey,
	table_field_name_key_end: (self: Self, field: AstTableFieldNameKey) -> AstTableFieldNameKey,
	table_field_no_key: (self: Self, field: AstTableFieldNoKey) -> AstTableFieldNoKey,
	table_field_no_key_end: (self: Self, field: AstTableFieldNoKey) -> AstTableFieldNoKey,
	table_field: (self: Self, field: AstTableField) -> AstTableField,
	table_field_end: (self: Self, field: AstTableField) -> AstTableField,

	function_body: (self: Self, body: AstFunctionBody) -> AstFunctionBody,
	function_body_end: (self: Self, body: AstFunctionBody) -> AstFunctionBody,

	compound_op: (self: Self, op: AstCompoundOp) -> AstCompoundOp,
	compound_op_end: (self: Self, op: AstCompoundOp) -> AstCompoundOp,

	stat_assign: (self: Self, stat: AstStatAssign) -> AstStatAssign,
	stat_assign_end: (self: Self, stat: AstStatAssign) -> AstStatAssign,
	stat_compound_assign: (self: Self, stat: AstStatCompoundAssign) -> AstStatCompoundAssign,
	stat_compound_assign_end: (self: Self, stat: AstStatCompoundAssign) -> AstStatCompoundAssign,
	stat_call: (self: Self, stat: AstStatCall) -> AstStatCall,
	stat_call_end: (self: Self, stat: AstStatCall) -> AstStatCall,
	stat_do: (self: Self, stat: AstStatDo) -> AstStatDo,
	stat_do_end: (self: Self, stat: AstStatDo) -> AstStatDo,
	stat_while: (self: Self, stat: AstStatWhile) -> AstStatWhile,
	stat_while_end: (self: Self, stat: AstStatWhile) -> AstStatWhile,
	stat_repeat: (self: Self, stat: AstStatRepeat) -> AstStatRepeat,
	stat_repeat_end: (self: Self, stat: AstStatRepeat) -> AstStatRepeat,
	stat_if: (self: Self, stat: AstStatIf) -> AstStatIf,
	stat_if_end: (self: Self, stat: AstStatIf) -> AstStatIf,
	stat_numeric_for: (self: Self, stat: AstStatNumericFor) -> AstStatNumericFor,
	stat_numeric_for_end: (self: Self, stat: AstStatNumericFor) -> AstStatNumericFor,
	stat_generic_for: (self: Self, stat: AstStatGenericFor) -> AstStatGenericFor,
	stat_generic_for_end: (self: Self, stat: AstStatGenericFor) -> AstStatGenericFor,
	stat_function: (self: Self, stat: AstStatFunction) -> AstStatFunction,
	stat_function_end: (self: Self, stat: AstStatFunction) -> AstStatFunction,
	stat_local_function: (self: Self, stat: AstStatLocalFunction) -> AstStatLocalFunction,
	stat_local_function_end: (self: Self, stat: AstStatLocalFunction) -> AstStatLocalFunction,
	stat_local_assign: (self: Self, stat: AstStatLocalAssign) -> AstStatLocalAssign,
	stat_local_assign_end: (self: Self, stat: AstStatLocalAssign) -> AstStatLocalAssign,
	stat_type: (self: Self, stat: AstStatType) -> AstStatType,
	stat_type_end: (self: Self, stat: AstStatType) -> AstStatType,
	stat: (self: Self, stat: AstStat) -> AstStat,
	stat_end: (self: Self, stat: AstStat) -> AstStat,

	laststat_return: (self: Self, stat: AstLastStatReturn) -> AstLastStatReturn,
	laststat_return_end: (self: Self, stat: AstLastStatReturn) -> AstLastStatReturn,
	laststat_break: (self: Self, stat: AstLastStatBreak) -> AstLastStatBreak,
	laststat_break_end: (self: Self, stat: AstLastStatBreak) -> AstLastStatBreak,
	laststat_continue: (self: Self, stat: AstLastStatContinue) -> AstLastStatContinue,
	laststat_continue_end: (self: Self, stat: AstLastStatContinue) -> AstLastStatContinue,
	laststat: (self: Self, stat: AstLastStat) -> AstLastStat,
	laststat_end: (self: Self, stat: AstLastStat) -> AstLastStat,

	block: (self: Self, block: AstBlock) -> AstBlock,
	block_end: (self: Self, block: AstBlock) -> AstBlock,
	ast: (self: Self, ast: Ast) -> Ast,
	ast_end: (self: Self, ast: Ast) -> Ast,
}

local function visitor_new<Self>(): Visitor<Self>
	local noop: <T>(Self, T) -> T = function(_, v)
		return v
	end

	return {
		token = noop,

		istring_simple = noop,
		istring_simple_end = noop,
		istring_complex = noop,
		istring_complex_end = noop,
		istring = noop,
		istring_end = noop,

		type_nil = noop,
		type_nil_end = noop,
		type_true = noop,
		type_true_end = noop,
		type_false = noop,
		type_false_end = noop,
		type_string = noop,
		type_string_end = noop,
		type_reference = noop,
		type_reference_end = noop,
		type_typeof = noop,
		type_typeof_end = noop,
		type_array = noop,
		type_array_end = noop,
		type_table = noop,
		type_table_end = noop,
		type_function = noop,
		type_function_end = noop,
		type_paren = noop,
		type_paren_end = noop,
		type_optional = noop,
		type_optional_end = noop,
		type_union = noop,
		type_union_end = noop,
		type_intersection = noop,
		type_intersection_end = noop,
		type = noop,
		type_end = noop,

		type_table_field_name_prop = noop,
		type_table_field_name_prop_end = noop,
		type_table_field_string_prop = noop,
		type_table_field_string_prop_end = noop,
		type_table_field_indexer = noop,
		type_table_field_indexer_end = noop,
		type_table_field = noop,
		type_table_field_end = noop,

		return_type = noop,
		return_type_end = noop,

		type_pack_list = noop,
		type_pack_list_end = noop,
		type_pack_variadic = noop,
		type_pack_variadic_end = noop,
		type_pack_generic = noop,
		type_pack_generic_end = noop,
		type_pack_tail = noop,
		type_pack_tail_end = noop,
		type_pack = noop,
		type_pack_end = noop,

		generic_type_list = noop,
		generic_type_list_end = noop,
		generic_type_list_with_defaults = noop,
		generic_type_list_with_defaults_end = noop,

		binding = noop,
		binding_end = noop,

		expr_nil = noop,
		expr_nil_end = noop,
		expr_boolean = noop,
		expr_boolean_end = noop,
		expr_number = noop,
		expr_number_end = noop,
		expr_string = noop,
		expr_string_end = noop,
		expr_varargs = noop,
		expr_varargs_end = noop,
		expr_istring = noop,
		expr_istring_end = noop,
		expr_table = noop,
		expr_table_end = noop,
		expr_function = noop,
		expr_function_end = noop,
		expr_ifelse = noop,
		expr_ifelse_end = noop,
		expr_var = noop,
		expr_var_end = noop,
		expr_assertion = noop,
		expr_assertion_end = noop,
		expr_unary = noop,
		expr_unary_end = noop,
		expr_binary = noop,
		expr_binary_end = noop,
		expr = noop,
		expr_end = noop,

		unary_op = noop,
		unary_op_end = noop,
		binary_op = noop,
		binary_op_end = noop,

		var_name = noop,
		var_name_end = noop,
		var_expr = noop,
		var_expr_end = noop,
		var_index_name = noop,
		var_index_name_end = noop,
		var_index_expr = noop,
		var_index_expr_end = noop,
		var_call = noop,
		var_call_end = noop,
		var = noop,
		var_end = noop,

		function_call = noop,
		function_call_end = noop,

		function_args_expr_list = noop,
		function_args_expr_list_end = noop,
		function_args_table = noop,
		function_args_table_end = noop,
		function_args_string = noop,
		function_args_string_end = noop,
		function_args = noop,
		function_args_end = noop,

		table = noop,
		table_end = noop,

		table_field_expr_key = noop,
		table_field_expr_key_end = noop,
		table_field_name_key = noop,
		table_field_name_key_end = noop,
		table_field_no_key = noop,
		table_field_no_key_end = noop,
		table_field = noop,
		table_field_end = noop,

		function_body = noop,
		function_body_end = noop,

		compound_op = noop,
		compound_op_end = noop,

		stat_assign = noop,
		stat_assign_end = noop,
		stat_compound_assign = noop,
		stat_compound_assign_end = noop,
		stat_call = noop,
		stat_call_end = noop,
		stat_do = noop,
		stat_do_end = noop,
		stat_while = noop,
		stat_while_end = noop,
		stat_repeat = noop,
		stat_repeat_end = noop,
		stat_if = noop,
		stat_if_end = noop,
		stat_numeric_for = noop,
		stat_numeric_for_end = noop,
		stat_generic_for = noop,
		stat_generic_for_end = noop,
		stat_function = noop,
		stat_function_end = noop,
		stat_local_function = noop,
		stat_local_function_end = noop,
		stat_local_assign = noop,
		stat_local_assign_end = noop,
		stat_type = noop,
		stat_type_end = noop,
		stat = noop,
		stat_end = noop,

		laststat_return = noop,
		laststat_return_end = noop,
		laststat_break = noop,
		laststat_break_end = noop,
		laststat_continue = noop,
		laststat_continue_end = noop,
		laststat = noop,
		laststat_end = noop,

		block = noop,
		block_end = noop,
		ast = noop,
		ast_end = noop,
	}
end

local ast_visit: <Self>(self: Self, visitor: Visitor<Self>, ast: Ast) -> Ast

do
	local visit_istring: <Self>(self: Self, visitor: Visitor<Self>, istring: AstIString) -> AstIString
	local visit_type: <Self>(self: Self, visitor: Visitor<Self>, type: AstType) -> AstType
	local visit_return_type: <Self>(self: Self, visitor: Visitor<Self>, type: AstReturnType) -> AstReturnType
	local visit_type_pack: <Self>(self: Self, visitor: Visitor<Self>, pack: AstTypePack) -> AstTypePack
	local visit_generic_type_list: <Self>(self: Self, visitor: Visitor<Self>, generics: AstGenericTypeList) -> AstGenericTypeList
	local visit_generic_type_list_with_defaults: <Self>(
		self: Self,
		visitor: Visitor<Self>,
		generics: AstGenericTypeListWithDefaults
	) -> AstGenericTypeListWithDefaults
	local visit_binding: <Self>(self: Self, visitor: Visitor<Self>, binding: AstBinding) -> AstBinding
	local visit_expr: <Self>(self: Self, visitor: Visitor<Self>, expr: AstExpr) -> AstExpr
	local visit_var: <Self>(self: Self, visitor: Visitor<Self>, var: AstVar) -> AstVar
	local visit_function_call: <Self>(self: Self, visitor: Visitor<Self>, call: AstFunctionCall) -> AstFunctionCall
	local visit_function_args: <Self>(self: Self, visitor: Visitor<Self>, args: AstFunctionArgs) -> AstFunctionArgs
	local visit_table: <Self>(self: Self, visitor: Visitor<Self>, table: AstTable) -> AstTable
	local visit_function_body: <Self>(self: Self, visitor: Visitor<Self>, body: AstFunctionBody) -> AstFunctionBody
	local visit_stat: <Self>(self: Self, visitor: Visitor<Self>, stat: AstStat) -> AstStat
	local visit_laststat: <Self>(self: Self, visitor: Visitor<Self>, stat: AstLastStat) -> AstLastStat
	local visit_block: <Self>(self: Self, visitor: Visitor<Self>, block: AstBlock) -> AstBlock

	function visit_istring<Self>(self: Self, visitor: Visitor<Self>, istring: AstIString): AstIString
		istring = visitor.istring(self, istring)

		if istring.kind == "simple" then
			istring = visitor.istring_simple(self, istring)
			visitor.token(self, istring.tok)
			istring = visitor.istring_simple_end(self, istring)
		elseif istring.kind == "complex" then
			istring = visitor.istring_complex(self, istring)
			visitor.token(self, istring.begin)

			for _, pair in istring.middle do
				local expr, middle = pair.item, pair.sep

				visit_expr(self, visitor, expr)
				visitor.token(self, middle :: TokenIStringMiddle)
			end

			visitor.token(self, istring.last)
			istring = visitor.istring_complex_end(self, istring)
		end

		return visitor.istring_end(self, istring)
	end

	local function visit_type_pack_tail<Self>(self: Self, visitor: Visitor<Self>, pack: AstTypePackTail): AstTypePackTail
		pack = visitor.type_pack_tail(self, pack)

		if pack.kind == "variadic" then
			pack = visitor.type_pack_variadic(self, pack)
			visitor.token(self, pack.dots)
			pack.type = visit_type(self, visitor, pack.type)
			pack = visitor.type_pack_variadic_end(self, pack)
		elseif pack.kind == "generic" then
			pack = visitor.type_pack_generic(self, pack)
			visitor.token(self, pack.name)
			visitor.token(self, pack.dots)
			pack = visitor.type_pack_generic_end(self, pack)
		end

		return visitor.type_pack_tail_end(self, pack)
	end

	function visit_type<Self>(self: Self, visitor: Visitor<Self>, type: AstType): AstType
		type = visitor.type(self, type)

		if type.kind == "nil" then
			type = visitor.type_nil(self, type)
			visitor.token(self, type.tok)
			type = visitor.type_nil_end(self, type)
		elseif type.kind == "true" then
			type = visitor.type_true(self, type)
			visitor.token(self, type.tok)
			type = visitor.type_true_end(self, type)
		elseif type.kind == "false" then
			type = visitor.type_false(self, type)
			visitor.token(self, type.tok)
			type = visitor.type_false_end(self, type)
		elseif type.kind == "string" then
			type = visitor.type_string(self, type)
			visitor.token(self, type.tok)
			type = visitor.type_string_end(self, type)
		elseif type.kind == "reference" then
			type = visitor.type_reference(self, type)

			if type.prefix then
				visitor.token(self, type.prefix.name)
				visitor.token(self, type.prefix.dot)
			end

			visitor.token(self, type.name)

			if type.generics then
				visitor.token(self, type.generics.angles.open)

				for _, pair in type.generics.types do
					local type_or_pack = pair.item

					if
						type_or_pack.kind == "list"
						or type_or_pack.kind == "variadic"
						or type_or_pack.kind == "generic"
					then
						type_or_pack = visit_type_pack(self, visitor, type_or_pack)
					else
						type_or_pack = visit_type(self, visitor, type_or_pack)
					end

					pair.item = type_or_pack
				end

				visitor.token(self, type.generics.angles.close)
			end

			type = visitor.type_reference_end(self, type)
		elseif type.kind == "typeof" then
			type = visitor.type_typeof(self, type)
			visitor.token(self, type.tok :: any)
			visitor.token(self, type.parens.open)
			type.expr = visit_expr(self, visitor, type.expr)
			visitor.token(self, type.parens.close)
			type = visitor.type_typeof_end(self, type)
		elseif type.kind == "array" then
			type = visitor.type_array(self, type)
			type.type = visit_type(self, visitor, type.type)
			type = visitor.type_array_end(self, type)
		elseif type.kind == "table" then
			type = visitor.type_table(self, type)
			visitor.token(self, type.braces.open)

			for _, pair in type.fields do
				local field, sep = pair.item, pair.sep
				field = visitor.type_table_field(self, field)

				if field.kind == "nameprop" then
					field = visitor.type_table_field_name_prop(self, field)
					visitor.token(self, field.key)
					visitor.token(self, field.colon)
					field.value = visit_type(self, visitor, field.value)
					field = visitor.type_table_field_name_prop_end(self, field)
				elseif field.kind == "stringprop" then
					field = visitor.type_table_field_string_prop(self, field)
					visitor.token(self, field.bracks.open)
					visitor.token(self, field.key)
					visitor.token(self, field.bracks.close)
					visitor.token(self, field.colon)
					field.value = visit_type(self, visitor, field.value)
					field = visitor.type_table_field_string_prop_end(self, field)
				elseif field.kind == "indexer" then
					field = visitor.type_table_field_indexer(self, field)
					visitor.token(self, field.bracks.open)
					field.key = visit_type(self, visitor, field.key)
					visitor.token(self, field.bracks.close)
					field.value = visit_type(self, visitor, field.value)
					field = visitor.type_table_field_indexer_end(self, field)
				end

				pair.item = visitor.type_table_field_end(self, field)

				if sep then
					visitor.token(self, sep)
				end
			end

			visitor.token(self, type.braces.close)
			type = visitor.type_table_end(self, type)
		elseif type.kind == "function" then
			type = visitor.type_function(self, type)

			if type.generics then
				type.generics = visit_generic_type_list(self, visitor, type.generics)
			end

			visitor.token(self, type.parens.open)

			for _, pair in type.params do
				local param, sep = pair.item, pair.sep

				if param.name then
					visitor.token(self, param.name.name)
					visitor.token(self, param.name.colon)
				end

				param.type = visit_type(self, visitor, type)

				if sep then
					visitor.token(self, sep)
				end
			end

			if type.tail then
				type.tail = visit_type_pack_tail(self, visitor, type.tail)
			end

			visitor.token(self, type.parens.close)
			visitor.token(self, type.arrow)
			type.returns = visit_return_type(self, visitor, type.returns)

			type = visitor.type_function_end(self, type)
		elseif type.kind == "paren" then
			type = visitor.type_paren(self, type)
			visitor.token(self, type.parens.open)
			type.type = visit_type(self, visitor, type.type)
			visitor.token(self, type.parens.close)
			type = visitor.type_paren_end(self, type)
		elseif type.kind == "optional" then
			type = visitor.type_optional(self, type)
			visit_type(self, visitor, type.type)
			visitor.token(self, type.question)
			type = visitor.type_optional_end(self, type)
		elseif type.kind == "union" then
			type = visitor.type_union(self, type)

			if type.leading then
				visitor.token(self, type.leading)
			end

			for _, pair in type.types do
				pair.item = visit_type(self, visitor, pair.item)

				local sep = pair.sep

				if sep then
					visitor.token(self, sep)
				end
			end

			type = visitor.type_union_end(self, type)
		elseif type.kind == "intersection" then
			type = visitor.type_intersection(self, type)

			if type.leading then
				visitor.token(self, type.leading)
			end

			for _, pair in type.types do
				pair.item = visit_type(self, visitor, pair.item)

				local sep = pair.sep

				if sep then
					visitor.token(self, sep)
				end
			end

			type = visitor.type_intersection_end(self, type)
		else
			error("unreachable")
		end

		return visitor.type_end(self, type)
	end

	function visit_return_type<Self>(self: Self, visitor: Visitor<Self>, type: AstReturnType): AstReturnType
		type = visitor.return_type(self, type)

		if type.kind == "variadic" or type.kind == "generic" or type.kind == "list" then
			type = visit_type_pack(self, visitor, type)
		else
			type = visit_type(self, visitor, type)
		end

		return visitor.return_type_end(self, type)
	end

	function visit_type_pack<Self>(self: Self, visitor: Visitor<Self>, pack: AstTypePack): AstTypePack
		pack = visitor.type_pack(self, pack)

		if pack.kind == "variadic" or pack.kind == "generic" then
			pack = visit_type_pack_tail(self, visitor, pack)
		else
			pack = visitor.type_pack_list(self, pack)
			visitor.token(self, pack.parens.open)

			for _, pair in pack.types do
				pair.item = visit_type(self, visitor, pair.item)

				local sep = pair.sep

				if sep then
					visitor.token(self, sep)
				end
			end

			if pack.tail then
				pack.tail = visit_type_pack_tail(self, visitor, pack.tail)
			end

			visitor.token(self, pack.parens.close)
			pack = visitor.type_pack_list_end(self, pack)
		end

		return visitor.type_pack_end(self, pack)
	end

	function visit_generic_type_list<Self>(
		self: Self,
		visitor: Visitor<Self>,
		generics: AstGenericTypeList
	): AstGenericTypeList
		generics = visitor.generic_type_list(self, generics)
		visitor.token(self, generics.angles.open)

		for _, pair in generics.names do
			local name, sep = pair.item, pair.sep

			visitor.token(self, name)

			if sep then
				visitor.token(self, sep)
			end
		end

		for _, pair in generics.packs do
			local pack, sep = pair.item, pair.sep

			visitor.token(self, pack.name)
			visitor.token(self, pack.dots)

			if sep then
				visitor.token(self, sep)
			end
		end

		visitor.token(self, generics.angles.close)
		return visitor.generic_type_list(self, generics)
	end

	function visit_generic_type_list_with_defaults<Self>(
		self: Self,
		visitor: Visitor<Self>,
		generics: AstGenericTypeListWithDefaults
	): AstGenericTypeListWithDefaults
		generics = visitor.generic_type_list_with_defaults(self, generics)
		visitor.token(self, generics.angles.open)

		for _, pair in generics.names do
			local name, sep = pair.item, pair.sep

			visitor.token(self, name.name)

			if name.default then
				visitor.token(self, name.default.eq)
				visit_type(self, visitor, name.default.type)
			end

			if sep then
				visitor.token(self, sep)
			end
		end

		for _, pair in generics.packs do
			local pack, sep = pair.item, pair.sep

			visitor.token(self, pack.name)
			visitor.token(self, pack.dots)

			if pack.default then
				visitor.token(self, pack.default.eq)
				visit_type_pack(self, visitor, pack.default.pack)
			end

			if sep then
				visitor.token(self, sep)
			end
		end

		visitor.token(self, generics.angles.close)
		return visitor.generic_type_list_with_defaults_end(self, generics)
	end

	function visit_binding<Self>(self: Self, visitor: Visitor<Self>, binding: AstBinding): AstBinding
		binding = visitor.binding(self, binding)
		visitor.token(self, binding.name)

		if binding.type then
			visitor.token(self, binding.type.colon)
			binding.type.type = visit_type(self, visitor, binding.type.type)
		end

		return visitor.binding_end(self, binding)
	end

	function visit_expr<Self>(self: Self, visitor: Visitor<Self>, expr: AstExpr): AstExpr
		expr = visitor.expr(self, expr)

		if expr.kind == "nil" then
			expr = visitor.expr_nil(self, expr)
			visitor.token(self, expr.tok)
			expr = visitor.expr_nil_end(self, expr)
		elseif expr.kind == "boolean" then
			expr = visitor.expr_boolean(self, expr)
			visitor.token(self, expr.tok)
			expr = visitor.expr_boolean_end(self, expr)
		elseif expr.kind == "number" then
			expr = visitor.expr_number(self, expr)
			visitor.token(self, expr.tok)
			expr = visitor.expr_number_end(self, expr)
		elseif expr.kind == "string" then
			expr = visitor.expr_string(self, expr)
			visitor.token(self, expr.tok)
			expr = visitor.expr_string_end(self, expr)
		elseif expr.kind == "varargs" then
			expr = visitor.expr_varargs(self, expr)
			visitor.token(self, expr.tok)
			expr = visitor.expr_varargs_end(self, expr)
		elseif expr.kind == "istring" then
			expr = visitor.expr_istring(self, expr)
			expr.istring = visit_istring(self, visitor, expr.istring)
			expr = visitor.expr_istring_end(self, expr)
		elseif expr.kind == "table" then
			expr = visitor.expr_table(self, expr)
			expr.table = visit_table(self, visitor, expr.table)
			expr = visitor.expr_table_end(self, expr)
		elseif expr.kind == "function" then
			expr = visitor.expr_function(self, expr)

			for _, attribute in expr.attributes do
				visitor.token(self, attribute)
			end

			visitor.token(self, expr.function_tok)
			expr.body = visit_function_body(self, visitor, expr.body)

			return visitor.expr_function_end(self, expr)
		elseif expr.kind == "ifelse" then
			expr = visitor.expr_ifelse(self, expr)
			visitor.token(self, expr.if_tok)
			expr.condition = visit_expr(self, visitor, expr.condition)
			visitor.token(self, expr.then_tok)
			expr.if_expr = visit_expr(self, visitor, expr.if_expr)

			for _, elseif_ in expr.elseifs do
				visitor.token(self, elseif_.elseif_tok)
				elseif_.condition = visit_expr(self, visitor, elseif_.condition)
				visitor.token(self, elseif_.then_tok)
				elseif_.elseif_expr = visit_expr(self, visitor, elseif_.elseif_expr)
			end

			visitor.token(self, expr.else_tok)
			expr.else_expr = visit_expr(self, visitor, expr.else_expr)
			expr = visitor.expr_ifelse_end(self, expr)
		elseif expr.kind == "var" then
			expr = visitor.expr_var(self, expr)
			expr.var = visit_var(self, visitor, expr.var)
			expr = visitor.expr_var_end(self, expr)
		elseif expr.kind == "assertion" then
			expr = visitor.expr_assertion(self, expr)
			expr.expr = visit_expr(self, visitor, expr.expr)
			visitor.token(self, expr.colons)
			expr.type = visit_type(self, visitor, expr.type)
			expr = visitor.expr_assertion_end(self, expr)
		elseif expr.kind == "unary" then
			expr = visitor.expr_unary(self, expr)
			visitor.unary_op(self, expr.op)
			visitor.token(self, expr.op)
			expr.rhs = visit_expr(self, visitor, expr.rhs)
			expr = visitor.expr_unary_end(self, expr)
		elseif expr.kind == "binary" then
			expr = visitor.expr_binary(self, expr)
			expr.lhs = visit_expr(self, visitor, expr.lhs)
			visitor.binary_op(self, expr.op)
			visitor.token(self, expr.op)
			expr.rhs = visit_expr(self, visitor, expr.rhs)
			expr = visitor.expr_binary_end(self, expr)
		else
			error("unreachable")
		end

		return visitor.expr_end(self, expr)
	end

	function visit_var<Self>(self: Self, visitor: Visitor<Self>, var: AstVar): AstVar
		var = visitor.var(self, var)

		if var.kind == "name" then
			var = visitor.var_name(self, var)
			visitor.token(self, var.tok)
			var = visitor.var_name_end(self, var)
		elseif var.kind == "expr" then
			var = visitor.var_expr(self, var)
			visitor.token(self, var.parens.open)
			var.expr = visit_expr(self, visitor, var.expr)
			visitor.token(self, var.parens.close)
			var = visitor.var_expr_end(self, var)
		elseif var.kind == "indexname" then
			var = visitor.var_index_name(self, var)
			var.lhs = visit_var(self, visitor, var.lhs)
			visitor.token(self, var.dot)
			visitor.token(self, var.name)
			var = visitor.var_index_name_end(self, var)
		elseif var.kind == "indexexpr" then
			var = visitor.var_index_expr(self, var)
			var.lhs = visit_var(self, visitor, var.lhs)
			visitor.token(self, var.bracks.open)
			var.expr = visit_expr(self, visitor, var.expr)
			visitor.token(self, var.bracks.close)
			var = visitor.var_index_expr_end(self, var)
		elseif var.kind == "call" then
			var = visitor.var_call(self, var)
			var.call = visit_function_call(self, visitor, var.call)
			var = visitor.var_call_end(self, var)
		else
			error("unreachable")
		end

		return visitor.var_end(self, var)
	end

	function visit_function_call<Self>(self: Self, visitor: Visitor<Self>, call: AstFunctionCall): AstFunctionCall
		call = visitor.function_call(self, call)
		call.lhs = visit_var(self, visitor, call.lhs)

		if call.method then
			visitor.token(self, call.method.colon)
			visitor.token(self, call.method.name)
		end

		call.args = visit_function_args(self, visitor, call.args)
		return visitor.function_call_end(self, call)
	end

	function visit_function_args<Self>(self: Self, visitor: Visitor<Self>, args: AstFunctionArgs): AstFunctionArgs
		args = visitor.function_args(self, args)

		if args.kind == "exprlist" then
			args = visitor.function_args_expr_list(self, args)
			visitor.token(self, args.parens.open)

			for _, pair in args.exprs do
				local expr, sep = pair.item, pair.sep

				expr = visit_expr(self, visitor, expr)
				pair.item = expr

				if sep then
					visitor.token(self, sep)
				end
			end

			visitor.token(self, args.parens.close)
			args = visitor.function_args_expr_list_end(self, args)
		elseif args.kind == "table" then
			args = visitor.function_args_table(self, args)
			args.table = visit_table(self, visitor, args.table)
			args = visitor.function_args_table_end(self, args)
		elseif args.kind == "string" then
			args = visitor.function_args_string(self, args)
			visitor.token(self, args.tok)
			args = visitor.function_args_string_end(self, args)
		else
			error("unreachable")
		end

		return visitor.function_args_end(self, args)
	end

	function visit_table<Self>(self: Self, visitor: Visitor<Self>, table: AstTable): AstTable
		table = visitor.table(self, table)
		visitor.token(self, table.braces.open)

		for _, pair in table.fields do
			local field, sep = pair.item, pair.sep
			field = visitor.table_field(self, field)

			if field.kind == "exprkey" then
				field = visitor.table_field_expr_key(self, field)
				visitor.token(self, field.bracks.open)
				field.key = visit_expr(self, visitor, field.key)
				visitor.token(self, field.bracks.close)
				visitor.token(self, field.eq)
				field.value = visit_expr(self, visitor, field.value)
				field = visitor.table_field_expr_key_end(self, field)
			elseif field.kind == "namekey" then
				field = visitor.table_field_name_key(self, field)
				visitor.token(self, field.key)
				visitor.token(self, field.eq)
				field.value = visit_expr(self, visitor, field.value)
				field = visitor.table_field_name_key_end(self, field)
			elseif field.kind == "nokey" then
				field = visitor.table_field_no_key(self, field)
				field.value = visit_expr(self, visitor, field.value)
				field = visitor.table_field_no_key_end(self, field)
			end

			pair.item = visitor.table_field_end(self, field)

			if sep then
				visitor.token(self, sep)
			end
		end

		visitor.token(self, table.braces.close)
		return visitor.table_end(self, table)
	end

	function visit_function_body<Self>(self: Self, visitor: Visitor<Self>, body: AstFunctionBody): AstFunctionBody
		body = visitor.function_body(self, body)

		if body.generics then
			body.generics = visit_generic_type_list(self, visitor, body.generics)
		end

		visitor.token(self, body.parens.open)

		for _, pair in body.params do
			local binding, sep = pair.item, pair.sep

			binding = visit_binding(self, visitor, binding)
			pair.item = binding

			if sep then
				visitor.token(self, sep)
			end
		end

		if body.varargs then
			visitor.token(self, body.varargs.dots)

			if body.varargs.type then
				visitor.token(self, body.varargs.type.colon)
				local type = body.varargs.type.type

				if type.kind == "generic" then
					type = visitor.type_pack_generic(self, type)
					visitor.token(self, type.name)
					visitor.token(self, type.dots)
					type = visitor.type_pack_generic_end(self, type)
				else
					type = visit_type(self, visitor, type)
				end

				body.varargs.type.type = type
			end
		end

		visitor.token(self, body.parens.close)

		if body.returns then
			visitor.token(self, body.returns.colon)
			body.returns.type = visit_return_type(self, visitor, body.returns.type)
		end

		body.block = visit_block(self, visitor, body.block)
		visitor.token(self, body.end_tok)
		return visitor.function_body_end(self, body)
	end

	function visit_stat<Self>(self: Self, visitor: Visitor<Self>, stat: AstStat): AstStat
		stat = visitor.stat(self, stat)

		if stat.kind == "assign" then
			stat = visitor.stat_assign(self, stat)

			for _, pair in stat.lhs do
				local var, sep = pair.item, pair.sep

				var = visit_var(self, visitor, var)
				pair.item = var

				if sep then
					visitor.token(self, sep)
				end
			end

			visitor.token(self, stat.eq)

			for _, pair in stat.rhs do
				local expr, sep = pair.item, pair.sep

				expr = visit_expr(self, visitor, expr)
				pair.item = expr

				if sep then
					visitor.token(self, sep)
				end
			end

			stat = visitor.stat_assign_end(self, stat)
		elseif stat.kind == "compoundassign" then
			stat = visitor.stat_compound_assign(self, stat)
			stat.lhs = visit_var(self, visitor, stat.lhs)
			visitor.compound_op(self, stat.op)
			visitor.token(self, stat.op)
			stat.rhs = visit_expr(self, visitor, stat.rhs)
			stat = visitor.stat_compound_assign_end(self, stat)
		elseif stat.kind == "call" then
			stat = visitor.stat_call(self, stat)
			stat.call = visit_function_call(self, visitor, stat.call)
			stat = visitor.stat_call_end(self, stat)
		elseif stat.kind == "do" then
			stat = visitor.stat_do(self, stat)
			visitor.token(self, stat.do_tok)
			stat.block = visit_block(self, visitor, stat.block)
			visitor.token(self, stat.end_tok)
			stat = visitor.stat_do_end(self, stat)
		elseif stat.kind == "while" then
			stat = visitor.stat_while(self, stat)
			visitor.token(self, stat.while_tok)
			stat.condition = visit_expr(self, visitor, stat.condition)
			visitor.token(self, stat.do_tok)
			stat.block = visit_block(self, visitor, stat.block)
			visitor.token(self, stat.end_tok)
			stat = visitor.stat_while_end(self, stat)
		elseif stat.kind == "repeat" then
			stat = visitor.stat_repeat(self, stat)
			visitor.token(self, stat.repeat_tok)
			stat.block = visit_block(self, visitor, stat.block)
			visitor.token(self, stat.until_tok)
			stat.condition = visit_expr(self, visitor, stat.condition)
			stat = visitor.stat_repeat_end(self, stat)
		elseif stat.kind == "if" then
			stat = visitor.stat_if(self, stat)
			visitor.token(self, stat.if_tok)
			stat.condition = visit_expr(self, visitor, stat.condition)
			visitor.token(self, stat.then_tok)
			stat.block = visit_block(self, visitor, stat.block)

			for _, elseif_ in stat.elseifs do
				visitor.token(self, elseif_.elseif_tok)
				elseif_.condition = visit_expr(self, visitor, elseif_.condition)
				visitor.token(self, elseif_.then_tok)
				elseif_.block = visit_block(self, visitor, elseif_.block)
			end

			if stat.else_ then
				visitor.token(self, stat.else_.else_tok)
				stat.else_.block = visit_block(self, visitor, stat.else_.block)
			end

			visitor.token(self, stat.end_tok)
			stat = visitor.stat_if_end(self, stat)
		elseif stat.kind == "numericfor" then
			stat = visitor.stat_numeric_for(self, stat)
			visitor.token(self, stat.for_tok)
			stat.binding = visit_binding(self, visitor, stat.binding)
			visitor.token(self, stat.eq)
			stat.start = visit_expr(self, visitor, stat.start)
			visitor.token(self, stat.comma)
			stat.finish = visit_expr(self, visitor, stat.finish)

			if stat.step then
				visitor.token(self, stat.comma)
				stat.step.expr = visit_expr(self, visitor, stat.step.expr)
			end

			visitor.token(self, stat.do_tok)
			stat.block = visit_block(self, visitor, stat.block)
			visitor.token(self, stat.end_tok)
			stat = visitor.stat_numeric_for_end(self, stat)
		elseif stat.kind == "genericfor" then
			stat = visitor.stat_generic_for(self, stat)
			visitor.token(self, stat.for_tok)

			for _, pair in stat.bindings do
				local binding, sep = pair.item, pair.sep

				binding = visit_binding(self, visitor, binding)
				pair.item = binding

				if sep then
					visitor.token(self, sep)
				end
			end

			visitor.token(self, stat.in_tok)

			for _, pair in stat.exprs do
				local expr, sep = pair.item, pair.sep

				expr = visit_expr(self, visitor, expr)
				pair.item = expr

				if sep then
					visitor.token(self, sep)
				end
			end

			visitor.token(self, stat.do_tok)
			stat.block = visit_block(self, visitor, stat.block)
			visitor.token(self, stat.end_tok)
			stat = visitor.stat_generic_for_end(self, stat)
		elseif stat.kind == "function" then
			stat = visitor.stat_function(self, stat)

			for _, attribute in stat.attributes do
				visitor.token(self, attribute)
			end

			visitor.token(self, stat.function_tok)

			for _, pair in stat.names do
				local name, sep = pair.item, pair.sep

				visitor.token(self, name)

				if sep then
					visitor.token(self, sep)
				end
			end

			if stat.method then
				visitor.token(self, stat.method.colon)
				visitor.token(self, stat.method.name)
			end

			stat.body = visit_function_body(self, visitor, stat.body)
			stat = visitor.stat_function_end(self, stat)
		elseif stat.kind == "localfunction" then
			stat = visitor.stat_local_function(self, stat)

			for _, attribute in stat.attributes do
				visitor.token(self, attribute)
			end

			visitor.token(self, stat.local_tok)
			visitor.token(self, stat.function_tok)
			visitor.token(self, stat.name)
			stat.body = visit_function_body(self, visitor, stat.body)
			stat = visitor.stat_local_function_end(self, stat)
		elseif stat.kind == "localassign" then
			stat = visitor.stat_local_assign(self, stat)
			visitor.token(self, stat.local_tok)

			for _, pair in stat.bindings do
				local binding, sep = pair.item, pair.sep

				binding = visit_binding(self, visitor, binding)
				pair.item = binding

				if sep then
					visitor.token(self, sep)
				end
			end

			if stat.values then
				visitor.token(self, stat.values.eq)

				for _, pair in stat.values.exprs do
					local expr, sep = pair.item, pair.sep

					expr = visit_expr(self, visitor, expr)
					pair.item = expr

					if sep then
						visitor.token(self, sep)
					end
				end
			end

			stat = visitor.stat_local_assign_end(self, stat)
		elseif stat.kind == "type" then
			stat = visitor.stat_type(self, stat)

			if stat.export_tok then
				visitor.token(self, stat.export_tok :: any)
			end

			visitor.token(self, stat.type_tok :: any)
			visitor.token(self, stat.name)

			if stat.generics then
				stat.generics = visit_generic_type_list_with_defaults(self, visitor, stat.generics)
			end

			visitor.token(self, stat.eq)
			stat.type = visit_type(self, visitor, stat.type)
			stat = visitor.stat_type_end(self, stat)
		end

		return visitor.stat_end(self, stat)
	end

	function visit_laststat<Self>(self: Self, visitor: Visitor<Self>, stat: AstLastStat): AstLastStat
		stat = visitor.laststat(self, stat)

		if stat.kind == "return" then
			stat = visitor.laststat_return(self, stat)
			visitor.token(self, stat.return_tok)

			for _, pair in stat.exprs do
				local expr, sep = pair.item, pair.sep

				expr = visit_expr(self, visitor, expr)
				pair.item = expr

				if sep then
					visitor.token(self, sep)
				end
			end
		elseif stat.kind == "break" then
			stat = visitor.laststat_break(self, stat)
			visitor.token(self, stat.tok)
			stat = visitor.laststat_break_end(self, stat)
		elseif stat.kind == "continue" then
			stat = visitor.laststat_continue(self, stat)
			visitor.token(self, stat.tok :: any)
			stat = visitor.laststat_continue_end(self, stat)
		end

		return visitor.laststat_end(self, stat)
	end

	function visit_block<Self>(self: Self, visitor: Visitor<Self>, block: AstBlock): AstBlock
		block = visitor.block(self, block)

		for _, stat in block.stats do
			stat.stat = visit_stat(self, visitor, stat.stat)

			local semicolon = stat.semicolon

			if semicolon then
				visitor.token(self, semicolon)
			end
		end

		local laststat = block.laststat

		if laststat then
			laststat.stat = visit_laststat(self, visitor, laststat.stat)

			local semicolon = laststat.semicolon

			if semicolon then
				visitor.token(self, semicolon)
			end
		end

		return visitor.block_end(self, block)
	end

	function ast_visit<Self>(self: Self, visitor: Visitor<Self>, ast: Ast): Ast
		ast = visitor.ast(self, ast)

		ast.block = visit_block(self, visitor, ast.block)
		visitor.token(self, ast.eof)

		return visitor.ast_end(self, ast)
	end
end

export type ParseError = {
	span: Span,
	message: string,
}

local parse_ast: (state: State) -> Ast | ParseError

do
	local parse_istring: (state: State) -> AstIString
	local parse_type: (state: State) -> AstType
	local parse_return_type: (state: State) -> AstReturnType
	local parse_generic_type_list: (state: State) -> AstGenericTypeList
	local parse_generic_type_list_with_defaults: (state: State) -> AstGenericTypeListWithDefaults
	local parse_binding: (state: State) -> AstBinding
	local parse_expr: (state: State) -> AstExpr
	local parse_table: (state: State) -> AstTable
	local parse_var: (state: State) -> AstVar
	local parse_function_body: (state: State) -> AstFunctionBody
	local parse_function_args: (state: State) -> AstFunctionArgs
	local parse_function_call: (state: State, lhs: AstVar) -> AstFunctionCall
	local parse_stat: (state: State) -> AstStat | AstLastStat
	local parse_block: (state: State) -> AstBlock

	local function state_current(state: State): Token
		if state.current == nil then
			state.current = lexer_next(state)
		end

		return state.current :: Token
	end

	local function state_lookahead(state: State): Token
		if state.lookahead == nil then
			state.lookahead = lexer_next(state)
		end

		return state.lookahead :: Token
	end

	local function state_consume(state: State): Token
		local current = state_current(state)

		if state.lookahead then
			state.current = state.lookahead
			state.lookahead = nil
		else
			state.current = nil
		end

		return current
	end

	local function state_report(state: State, span: Span, message: string): never
		error({
			span = span,
			message = message,
		})
	end

	local function state_report_at_current(state: State, message: string): never
		local current = state_current(state)
		return (state_report(state, current.span, message))
	end

	local function state_expect(state: State, kind: TokenKind): Token
		local current = state_current(state)

		if current.kind == kind then
			return (state_consume(state))
		else
			local message = `expected {token_error({ kind = kind } :: any)}, but got {token_error(current)} instead`
			return (state_report_at_current(state, message))
		end
	end

	function parse_istring(state: State): AstIString
		if state_current(state).kind == "istringsimple" then
			return {
				kind = "simple",
				tok = state_consume(state) :: TokenIStringSimple,
			}
		else
			local begin = state_expect(state, "istringbegin") :: TokenIStringBegin
			local middle: AstSeparated<TokenIStringMiddle, AstExpr> = {}

			while true do
				local expr = parse_expr(state)

				if state_current(state).kind == "istringmiddle" then
					table.insert(middle, { item = expr, sep = state_consume(state) :: TokenIStringMiddle })
				else
					table.insert(middle, { item = expr, sep = nil })
					break
				end
			end

			local last = state_expect(state, "istringlast") :: TokenIStringLast

			return {
				kind = "complex",
				begin = begin,
				middle = middle,
				last = last,
			}
		end
	end

	do
		local parse_simple_type: ((state: State, allow_list_packs: false) -> AstType) & ((state: State, allow_list_packs: true) -> AstType | AstTypePackList)
		local parse_type_suffix: (state: State, type: AstType) -> AstType

		function parse_generic_type_list(state: State): AstGenericTypeList
			local open = state_expect(state, "<") :: TokenType<"<">
			local names: AstSeparated<TokenType<",">, TokenIdent> = {}
			local packs: AstSeparated<TokenType<",">, { name: TokenIdent, dots: TokenType<"..."> }> = {}

			while true do
				local name: TokenIdent

				if state_current(state).kind == "ident" and state_lookahead(state).kind == "..." then
					break
				else
					name = state_expect(state, "ident") :: TokenIdent
				end

				if state_current(state).kind == "," then
					table.insert(names, { item = name, sep = state_consume(state) :: TokenType<","> })
				else
					table.insert(names, { item = name, sep = nil })

					return {
						angles = { open = open, close = state_expect(state, ">") :: TokenType<">"> },
						names = names,
						packs = packs,
					}
				end
			end

			while true do
				local name = state_expect(state, "ident") :: TokenIdent
				local dots = state_expect(state, "...") :: TokenType<"...">

				if state_current(state).kind == "," then
					table.insert(
						packs,
						{ item = { name = name, dots = dots }, sep = state_consume(state) :: TokenType<","> }
					)
				else
					table.insert(packs, { item = { name = name, dots = dots }, sep = nil })
					break
				end
			end

			return {
				angles = { open = open, close = state_expect(state, ">") :: TokenType<">"> },
				names = names,
				packs = packs,
			}
		end

		local function parse_variadic_or_generic_type_pack(state: State): AstTypePackVariadic | AstTypePackGeneric
			if state_current(state).kind == "..." then
				local dots = state_consume(state) :: TokenType<"...">
				local type = parse_type(state)
				return { kind = "variadic" :: "variadic", dots = dots, type = type }
			elseif state_current(state).kind == "ident" and state_lookahead(state).kind == "..." then
				local name = state_consume(state) :: TokenIdent
				local dots = state_consume(state) :: TokenType<"...">
				return { kind = "generic" :: "generic", name = name, dots = dots }
			else
				return error("unreachable")
			end
		end

		function parse_generic_type_list_with_defaults(state: State): AstGenericTypeListWithDefaults
			local open = state_expect(state, "<") :: TokenType<"<">
			local names: AstSeparated<TokenType<",">, {
				name: TokenIdent,
				default: { eq: TokenType<"=">, type: AstType }?,
			}> =
				{}

			local packs: AstSeparated<TokenType<",">, {
				name: TokenIdent,
				dots: TokenType<"...">,
				default: { eq: TokenType<"=">, pack: AstTypePack }?,
			}> =
				{}

			while true do
				local name: TokenIdent

				if state_current(state).kind == "ident" and state_lookahead(state).kind == "..." then
					break
				else
					name = state_expect(state, "ident") :: TokenIdent
				end

				local default: { eq: TokenType<"=">, type: AstType }?

				if state_current(state).kind == "=" then
					local eq = state_consume(state) :: TokenType<"=">
					local type = parse_type(state)

					default = { eq = eq, type = type }
				end

				if state_current(state).kind == "," then
					table.insert(names, {
						item = { name = name, default = default },
						sep = state_consume(state) :: TokenType<",">,
					})
				else
					table.insert(names, { item = { name = name, default = default }, sep = nil })

					return {
						angles = { open = open, close = state_expect(state, ">") :: TokenType<">"> },
						names = names,
						packs = packs,
					}
				end
			end

			while true do
				local name = state_expect(state, "ident") :: TokenIdent
				local dots = state_expect(state, "...") :: TokenType<"...">
				local default: { eq: TokenType<"=">, pack: AstTypePack }?

				if state_current(state).kind == "=" then
					local eq = state_consume(state) :: TokenType<"=">
					local pack: AstTypePack

					if
						state_current(state).kind == "..."
						or (state_current(state).kind == "ident" and state_lookahead(state).kind == "...")
					then
						pack = parse_variadic_or_generic_type_pack(state)
					elseif state_current(state).kind == "(" then
						local maybe_pack = parse_simple_type(state, true)

						if maybe_pack.kind == "list" then
							pack = maybe_pack
						elseif maybe_pack.kind == "function" then
							state_report(
								state,
								ast_span_type(maybe_pack),
								"expected type pack after '=', found function type"
							)
						else
							error("unreachable")
						end
					else
						local message = `expected type pack after '=', found {token_error(state_current(state))}`
						state_report_at_current(state, message)
					end

					default = { eq = eq, pack = pack }
				end

				if state_current(state).kind == "," then
					table.insert(packs, {
						item = { name = name, dots = dots, default = default },
						sep = state_consume(state) :: TokenType<",">,
					})
				else
					table.insert(packs, { item = { name = name, dots = dots, default = default }, sep = nil })
					break
				end
			end

			return {
				angles = { open = open, close = state_expect(state, ">") :: TokenType<">"> },
				names = names,
				packs = packs,
			}
		end

		local function parse_function_type_params(state: State): (AstSeparated<TokenType<",">, {
			name: { name: TokenIdent, colon: TokenType<":"> }?,
			type: AstType,
		}>, (AstTypePackVariadic | AstTypePackGeneric)?)
			local params: AstSeparated<TokenType<",">, {
				name: { name: TokenIdent, colon: TokenType<":"> }?,
				type: AstType,
			}> =
				{}

			while true do
				if
					state_current(state).kind == "..."
					or (state_current(state).kind == "ident" and state_lookahead(state).kind == "...")
				then
					local pack = parse_variadic_or_generic_type_pack(state)
					return params, pack
				end

				local name: { name: TokenIdent, colon: TokenType<":"> }?

				if state_current(state).kind == "ident" and state_lookahead(state).kind == ":" then
					name = {
						name = state_consume(state) :: TokenIdent,
						colon = state_consume(state) :: TokenType<":">,
					}
				end

				local type = parse_type(state)

				if state_current(state).kind == "," then
					table.insert(
						params,
						{ item = { name = name, type = type }, sep = state_consume(state) :: TokenType<","> }
					)
				else
					table.insert(params, { item = { name = name, type = type }, sep = nil })
					return params, nil
				end
			end
		end

		local function parse_function_type_tail(state: State): (TokenType<"->">, AstReturnType)
			if state_current(state).kind == ":" then
				return state_report_at_current(state, "returns in function types are written after '->' instead of ':'")
			else
				local arrow = state_expect(state, "->") :: TokenType<"->">
				local returns = parse_return_type(state)

				return arrow, returns
			end
		end

		parse_simple_type = function(state: State, allow_list_pack: boolean): AstType | AstTypePackList
			local current = state_current(state)

			if current.kind == "nil" then
				state_consume(state)
				return { kind = "nil" :: "nil", tok = current }
			elseif current.kind == "true" then
				state_consume(state)
				return { kind = "true" :: "true", tok = current }
			elseif current.kind == "false" then
				state_consume(state)
				return { kind = "false" :: "false", tok = current }
			elseif current.kind == "string" then
				state_consume(state)
				return { kind = "string" :: "string", tok = current }
			elseif current.kind == "istringbegin" then
				local istring = parse_istring(state)

				local message = "interpolated string literals cannot be used as types"
				return state_report(state, ast_span_istring(istring), message)
			elseif current.kind == "ident" then
				if current.value == "typeof" then
					local typeof = state_consume(state) :: TokenIdent
					local open = state_expect(state, "(") :: TokenType<"(">
					local expr = parse_expr(state)
					local close = state_expect(state, ")") :: TokenType<")">

					return {
						kind = "typeof",
						tok = typeof :: any,
						parens = { open = open, close = close },
						expr = expr,
					}
				end

				local prefix
				local name = state_consume(state) :: TokenIdent

				if state_current(state).kind == "." then
					prefix = { name = name, dot = state_consume(state) :: TokenType<"."> }
					name = state_expect(state, "ident") :: TokenIdent
				elseif state_current(state).kind == "..." then
					local message = "unexpected ... after type name; type pack is not allowed in this context"
					return state_report_at_current(state, message)
				end

				if state_current(state).kind == "<" then
					local open, close = state_consume(state) :: TokenType<"<">, nil
					local generics: AstSeparated<TokenType<",">, AstType | AstTypePack> = {}

					if state_current(state).kind ~= ">" then
						while true do
							local generic: AstType | AstTypePack

							if
								state_current(state).kind == "..."
								or (state_current(state).kind == "ident" and state_lookahead(state).kind == "...")
							then
								generic = parse_variadic_or_generic_type_pack(state)
							elseif state_current(state).kind == "(" then
								local type = parse_simple_type(state, true)

								if type.kind == "list" then
									generic = type
								else
									generic = parse_type_suffix(state, type)
								end
							else
								generic = parse_type(state)
							end

							if state_current(state).kind == "," then
								table.insert(generics, { item = generic, sep = state_consume(state) :: TokenType<","> })
							else
								table.insert(generics, { item = generic, sep = nil })
								break
							end
						end

						close = state_expect(state, ">") :: TokenType<">">
					else
						close = state_consume(state) :: TokenType<">">
					end

					return {
						kind = "reference" :: "reference",
						prefix = prefix,
						name = name,
						generics = { angles = { open = open, close = close }, types = generics },
					}
				else
					return {
						kind = "reference" :: "reference",
						prefix = prefix,
						name = name,
						generics = nil,
					}
				end
			elseif current.kind == "{" then
				local open = state_consume(state) :: TokenType<"{">
				local had_indexer = false
				local fields: AstSeparated<TokenType<","> | TokenType<";">, {
					kind: "indexer",
					bracks: AstDelim<"[", "]">,
					key: AstType,
					colon: TokenType<":">,
					value: AstType,
				} | {
					kind: "prop",
					key: TokenIdent,
					colon: TokenType<":">,
					value: AstType,
				}> =
					{}

				while state_current(state).kind ~= "}" do
					local access: TokenIdent?
					local field: AstTypeTableField

					if state_current(state).kind == "ident" and state_lookahead(state).kind ~= ":" then
						local tok = state_current(state) :: TokenIdent

						if tok.value == "read" or tok.value == "write" then
							state_consume(state)
							access = tok
						end
					end

					if state_current(state).kind == "[" and state_lookahead(state).kind == "string" then
						local bracks_open = state_consume(state) :: TokenType<"[">
						local key = state_consume(state) :: TokenString
						local bracks_close = state_expect(state, "]") :: TokenType<"]">
						local colon = state_expect(state, ":") :: TokenType<":">
						local value = parse_type(state)

						field = {
							kind = "stringprop",
							access = access,
							bracks = { open = bracks_open, close = bracks_close },
							key = key,
							colon = colon,
							value = value,
						}
					elseif state_current(state).kind == "[" then
						local bracks_open = state_consume(state) :: TokenType<"[">
						local key = parse_type(state)
						local bracks_close = state_expect(state, "]") :: TokenType<"]">
						local colon = state_expect(state, ":") :: TokenType<":">
						local value = parse_type(state)

						if had_indexer then
							state_report(
								state,
								span_merge(bracks_open.span, bracks_close.span),
								"table types cannot have more than one indexer"
							)
						else
							had_indexer = true
						end

						field = {
							kind = "indexer",
							access = access,
							bracks = { open = bracks_open, close = bracks_close },
							key = key,
							colon = colon,
							value = value,
						}
					elseif state_current(state).kind == "ident" and state_lookahead(state).kind == ":" then
						local key = state_consume(state) :: TokenIdent
						local colon = state_expect(state, ":") :: TokenType<":">
						local value = parse_type(state)

						field = {
							kind = "nameprop",
							access = access,
							key = key,
							colon = colon,
							value = value,
						}
					elseif #fields == 0 then
						local type = parse_type(state)
						local close = state_expect(state, "}") :: TokenType<"}">

						return {
							kind = "array",
							braces = { open = open, close = close },
							type = type,
						}
					end

					if state_current(state).kind == "," or state_current(state).kind == ";" then
						table.insert(fields, { item = field, sep = state_consume(state) } :: any)
					else
						table.insert(fields, { item = field, sep = nil } :: any)
						break
					end
				end

				local close = state_expect(state, "}") :: TokenType<"}">

				return {
					kind = "table" :: "table",
					braces = { open = open, close = close },
					fields = fields :: any,
				}
			elseif current.kind == "(" or current.kind == "<" then
				local force_function_type = current.kind == "<"
				local generics: AstGenericTypeList?

				if force_function_type then
					generics = parse_generic_type_list(state)
				end

				local open = state_expect(state, "(") :: TokenType<"(">
				local params: AstSeparated<TokenType<",">, {
					name: { name: TokenIdent, colon: TokenType<":"> }?,
					type: AstType,
				}>, tail: AstTypePackTail?

				if state_current(state).kind ~= ")" then
					params, tail = parse_function_type_params(state)
				else
					params = {}
				end

				local close = state_expect(state, ")") :: TokenType<")">

				if not force_function_type then
					for _, pair in params do
						if pair.item.name then
							force_function_type = true
							break
						end
					end
				end

				local return_type_introducer = state_current(state).kind == "->" or state_current(state).kind == ":"

				if not force_function_type and not return_type_introducer then
					if allow_list_pack then
						local types: AstSeparated<TokenType<",">, AstType> = {}

						for _, pair in params do
							table.insert(types, { item = pair.item.type, sep = pair.sep })
						end

						return {
							kind = "list",
							parens = { open = open, close = close },
							types = types,
						}
					elseif #params == 1 and tail == nil then
						return {
							kind = "paren",
							parens = { open = open, close = close },
							type = params[1].item.type,
						}
					end
				end

				local arrow, returns = parse_function_type_tail(state)

				return {
					kind = "function",
					parens = { open = open, close = close },
					generics = generics,
					params = params,
					tail = tail,
					arrow = arrow,
					returns = returns,
				}
			elseif current.kind == "function" then
				local message = "using 'function' as a type is not supported, instead"
					.. "consider using a function type such as '(...any) -> ...any'"

				return state_report_at_current(state, message)
			else
				return state_report_at_current(state, `expected type, but got {token_error(current)} instead`)
			end
		end :: any

		function parse_type_suffix(state: State, current_type: AstType?): AstType
			local types: AstSeparated<TokenType<"|"> | TokenType<"&">, AstType> = {}
			local leading = if current_type then nil else state_consume(state)
			local is_union, is_intersection = false, false

			while true do
				local type: AstType
				if current_type then
					type = current_type
					current_type = nil
				else
					type = parse_simple_type(state, false)
				end

				if state_current(state).kind == "?" then
					if is_intersection then
						return state_report_at_current(state, "optional types cannot be used in intersections")
					else
						local question = state_consume(state) :: TokenType<"?">
						current_type = { kind = "optional", type = type, question = question }
						is_union = true
					end
				elseif state_current(state).kind == "|" then
					if is_intersection then
						return state_report_at_current(state, "unions and intersections cannot be mixed")
					else
						local pipe = state_consume(state) :: TokenType<"|">
						table.insert(types, { item = type, sep = pipe })
						is_union = true
					end
				elseif state_current(state).kind == "&" then
					if is_union then
						return state_report_at_current(state, "unions and intersections cannot be mixed")
					else
						local amp = state_consume(state) :: TokenType<"&">
						table.insert(types, { item = type, sep = amp })
						is_intersection = true
					end
				elseif #types == 0 and leading == nil then
					return type
				else
					table.insert(types, { item = type, sep = nil })
					break
				end
			end

			if is_union then
				return {
					kind = "union",
					leading = leading :: TokenType<"|">?,
					types = types :: AstSeparated<TokenType<"|">, AstType>,
				}
			else
				return {
					kind = "intersection",
					leading = leading :: TokenType<"&">?,
					types = types :: AstSeparated<TokenType<"&">, AstType>,
				}
			end
		end

		function parse_type(state: State): AstType
			local type

			if state_current(state).kind ~= "|" and state_current(state).kind ~= "&" then
				type = parse_simple_type(state, false)
			end

			return parse_type_suffix(state, type)
		end

		function parse_return_type(state: State): AstReturnType
			if state_current(state).kind ~= "(" then
				if
					state_current(state).kind == "..."
					or (state_current(state).kind == "ident" and state_lookahead(state).kind == "...")
				then
					return parse_variadic_or_generic_type_pack(state)
				else
					return parse_type(state)
				end
			end

			local open = state_consume(state) :: TokenType<"(">

			local params: AstSeparated<TokenType<",">, {
				name: { name: TokenIdent, colon: TokenType<":"> }?,
				type: AstType,
			}>, tail: AstTypePackTail?

			if state_current(state).kind ~= ")" then
				params, tail = parse_function_type_params(state)
			else
				params = {}
			end

			local close = state_expect(state, ")") :: TokenType<")">

			local has_named_param = false
			for _, pair in params do
				if pair.item.name then
					has_named_param = true
					break
				end
			end

			if state_current(state).kind ~= "->" and not has_named_param then
				if #params == 1 and tail == nil then
					local paren_type: AstType = {
						kind = "paren",
						parens = { open = open, close = close },
						type = params[1].item.type,
					}

					return parse_type_suffix(state, paren_type)
				else
					local types: AstSeparated<TokenType<",">, AstType> = {}

					for _, pair in params do
						table.insert(types, { item = pair.item.type, sep = pair.sep })
					end

					return {
						kind = "list",
						parens = { open = open, close = close },
						types = types,
					}
				end
			else
				local arrow, returns = parse_function_type_tail(state)

				return {
					kind = "function",
					parens = { open = open, close = close },
					params = params,
					tail = tail,
					arrow = arrow,
					returns = returns,
				}
			end
		end
	end

	function parse_binding(state: State): AstBinding
		local name = state_expect(state, "ident") :: TokenIdent

		if state_current(state).kind == ":" then
			local colon = state_consume(state) :: TokenType<":">
			local type = parse_type(state)

			return { name = name, type = { colon = colon, type = type } }
		else
			return { name = name, type = nil }
		end
	end

	do
		local function parse_simple_expr(state: State): AstExpr
			local current = state_current(state)

			if current.kind == "nil" then
				state_consume(state)
				return { kind = "nil", tok = current }
			elseif current.kind == "true" or current.kind == "false" then
				state_consume(state)
				return { kind = "boolean", tok = current }
			elseif current.kind == "number" then
				state_consume(state)
				return { kind = "number", tok = current }
			elseif current.kind == "string" then
				state_consume(state)
				return { kind = "string", tok = current }
			elseif current.kind == "..." then
				state_consume(state)
				return { kind = "varargs", tok = current }
			elseif current.kind == "istringbegin" or current.kind == "istringsimple" then
				local istring = parse_istring(state)

				return { kind = "istring", istring = istring }
			elseif current.kind == "{" then
				return { kind = "table", table = parse_table(state) }
			elseif current.kind == "function" or current.kind == "attribute" then
				local attributes: { TokenAttribute } = {}

				while state_current(state).kind == "attribute" do
					table.insert(attributes, state_consume(state) :: TokenAttribute)
				end

				local function_tok = state_consume(state) :: TokenType<"function">
				local body = parse_function_body(state)
				return { kind = "function", attributes = attributes, function_tok = function_tok, body = body }
			elseif current.kind == "if" then
				local if_tok = state_consume(state) :: TokenType<"if">
				local cond = parse_expr(state)
				local then_tok = state_expect(state, "then") :: TokenType<"then">
				local if_expr = parse_expr(state)

				local elseifs: {
					{
						elseif_tok: TokenType<"elseif">,
						condition: AstExpr,
						then_tok: TokenType<"then">,
						elseif_expr: AstExpr,
					}
				} =
					{}

				while state_current(state).kind == "elseif" do
					local elseif_tok = state_consume(state) :: TokenType<"elseif">
					local condition = parse_expr(state)
					local then_tok_ = state_expect(state, "then") :: TokenType<"then">
					local elseif_expr = parse_expr(state)

					table.insert(elseifs, {
						elseif_tok = elseif_tok,
						condition = condition,
						then_tok = then_tok_,
						elseif_expr = elseif_expr,
					})
				end

				local else_tok = state_expect(state, "else") :: TokenType<"else">
				local else_expr = parse_expr(state)

				return {
					kind = "ifelse",
					if_tok = if_tok,
					condition = cond,
					then_tok = then_tok,
					if_expr = if_expr,
					elseifs = elseifs,
					else_tok = else_tok,
					else_expr = else_expr,
				}
			else
				return { kind = "var", var = parse_var(state) }
			end
		end

		local function parse_expr_assertion(state: State): AstExpr
			local expr = parse_simple_expr(state)

			if state_current(state).kind == "::" then
				local colons = state_consume(state) :: TokenType<"::">
				local type = parse_type(state)

				return { kind = "assertion", expr = expr, colons = colons, type = type }
			else
				return expr
			end
		end

		local function token_to_unop(state: State, tok: Token): AstUnaryOp?
			if tok.kind == "+" or tok.kind == "-" or tok.kind == "not" or tok.kind == "#" then
				return tok
			elseif tok.kind == "error" and tok.value == "!" then
				return state_report_at_current(state, "unexpected '!', did you mean 'not'?")
			else
				return nil
			end
		end

		local function token_to_binop(state: State, tok: Token): AstBinaryOp?
			if
				tok.kind == "+"
				or tok.kind == "-"
				or tok.kind == "*"
				or tok.kind == "/"
				or tok.kind == "//"
				or tok.kind == "%"
				or tok.kind == "^"
				or tok.kind == ".."
				or tok.kind == "<"
				or tok.kind == "<="
				or tok.kind == ">"
				or tok.kind == ">="
				or tok.kind == "=="
				or tok.kind == "~="
				or tok.kind == "and"
				or tok.kind == "or"
			then
				return tok
			elseif tok.kind == "error" and tok.value == "!" and state_lookahead(state).kind == "=" then
				return state_report_at_current(state, "unexpected '!=', did you mean '~='?")
			elseif tok.kind == "&" and state_lookahead(state).kind == "&" then
				return state_report_at_current(state, "unexpected '&&', did you mean 'and'?")
			elseif tok.kind == "|" and state_lookahead(state).kind == "|" then
				return state_report_at_current(state, "unexpected '||', did you mean 'or'?")
			else
				return nil
			end
		end

		local function binop_priority(tok: Token): (number, number)
			if tok.kind == "+" or tok.kind == "-" then
				return 6, 6
			elseif tok.kind == "*" or tok.kind == "/" or tok.kind == "//" or tok.kind == "%" then
				return 7, 7
			elseif tok.kind == "^" then
				return 10, 9
			elseif tok.kind == ".." then
				return 5, 4
			elseif tok.kind == "==" or tok.kind == "~=" then
				return 3, 3
			elseif tok.kind == "<" or tok.kind == "<=" or tok.kind == ">" or tok.kind == ">=" then
				return 3, 3
			elseif tok.kind == "and" then
				return 2, 2
			elseif tok.kind == "or" then
				return 1, 1
			else
				error("unreachable")
			end
		end

		local function parse_expr_with_limit(state: State, limit: number): AstExpr
			local expr: AstExpr

			local unop = token_to_unop(state, state_current(state))

			if unop then
				state_consume(state)
				local rhs = parse_expr_with_limit(state, 8)

				expr = { kind = "unary", op = unop, rhs = rhs }
			else
				expr = parse_expr_assertion(state)
			end

			while true do
				local binop = token_to_binop(state, state_current(state))

				if binop == nil then
					break
				end

				local left_priority, right_priority = binop_priority(binop)

				if left_priority < limit then
					break
				end

				state_consume(state)
				local rhs = parse_expr_with_limit(state, right_priority)

				expr = { kind = "binary", lhs = expr, op = binop, rhs = rhs }
			end

			return expr
		end

		function parse_expr(state: State): AstExpr
			return parse_expr_with_limit(state, 0)
		end
	end

	function parse_table(state: State): AstTable
		local open = state_consume(state) :: TokenType<"{">
		local fields: AstSeparated<TokenType<","> | TokenType<";">, AstTableField> = {}

		while state_current(state).kind ~= "}" do
			local field: AstTableField

			if state_current(state).kind == "[" then
				local bracks_open = state_consume(state) :: TokenType<"[">
				local key = parse_expr(state)
				local bracks_close = state_expect(state, "]") :: TokenType<"]">
				local eq = state_expect(state, "=") :: TokenType<"=">
				local value = parse_expr(state)

				field = {
					kind = "exprkey",
					bracks = { open = bracks_open, close = bracks_close },
					key = key,
					eq = eq,
					value = value,
				}
			elseif state_current(state).kind == "ident" and state_lookahead(state).kind == "=" then
				local key = state_consume(state) :: TokenIdent
				local eq = state_expect(state, "=") :: TokenType<"=">
				local value = parse_expr(state)

				field = {
					kind = "namekey",
					key = key,
					eq = eq,
					value = value,
				}
			else
				local value = parse_expr(state)

				field = {
					kind = "nokey",
					value = value,
				}
			end

			if state_current(state).kind == "," or state_current(state).kind == ";" then
				table.insert(fields, { item = field, sep = state_consume(state) :: TokenType<","> | TokenType<";"> })
			else
				table.insert(fields, { item = field, sep = nil })
				break
			end
		end

		local close = state_expect(state, "}") :: TokenType<"}">

		return {
			braces = { open = open, close = close },
			fields = fields,
		}
	end

	function parse_var(state: State): AstVar
		local var: AstVar

		if state_current(state).kind == "(" then
			local open = state_consume(state) :: TokenType<"(">
			local expr = parse_expr(state)
			local close = state_expect(state, ")") :: TokenType<")">

			var = {
				kind = "expr",
				parens = { open = open, close = close },
				expr = expr,
			}
		elseif state_current(state).kind == "ident" then
			local name = state_consume(state) :: TokenIdent

			var = {
				kind = "name",
				tok = name,
			}
		else
			local message = `expected 'ident' or parenthesized expression,`
				.. ` but got {token_error(state_current(state))} instead`

			return state_report_at_current(state, message)
		end

		local line = state.line

		while true do
			local current = state_current(state)
			local next_line = state.line

			if current.kind == "." then
				local dot = state_consume(state) :: TokenType<".">
				local name = state_expect(state, "ident") :: TokenIdent

				var = {
					kind = "indexname",
					lhs = var,
					dot = dot,
					name = name,
				}
			elseif current.kind == "[" then
				local bracks_open = state_consume(state) :: TokenType<"[">
				local expr = parse_expr(state)
				local bracks_close = state_expect(state, "]") :: TokenType<"]">

				var = {
					kind = "indexexpr",
					lhs = var,
					bracks = { open = bracks_open, close = bracks_close },
					expr = expr,
				}
			elseif current.kind == "(" then
				if current.span.start.line ~= line then
					local message = "ambiguous syntax: this looks like an argument list"
						.. " for a function call, but could also be the start of a new"
						.. " statement; use ';' to separate statements"

					state_report_at_current(state, message)
				else
					var = {
						kind = "call",
						call = parse_function_call(state, var),
					}
				end
			elseif current.kind == ":" or current.kind == "{" or current.kind == "string" then
				var = {
					kind = "call",
					call = parse_function_call(state, var),
				}
			else
				break
			end

			line = next_line
		end

		return var
	end

	function parse_function_body(state: State): AstFunctionBody
		local generics: AstGenericTypeList?

		if state_current(state).kind == "<" then
			generics = parse_generic_type_list(state)
		end

		local open = state_expect(state, "(") :: TokenType<"(">
		local params: AstSeparated<TokenType<",">, AstBinding> = {}
		local varargs: { dots: TokenType<"...">, type: { colon: TokenType<":">, type: AstTypePackGeneric | AstType }? }?

		if state_current(state).kind ~= ")" then
			while true do
				if state_current(state).kind == "ident" then
					local binding = parse_binding(state)

					if state_current(state).kind == "," then
						table.insert(params, { item = binding, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(params, { item = binding, sep = nil })
						break
					end
				elseif state_current(state).kind == "..." then
					local dots = state_consume(state) :: TokenType<"...">

					if state_current(state).kind == ":" then
						local colon = state_consume(state) :: TokenType<":">
						local type: AstTypePackGeneric | AstType

						if state_current(state).kind == "ident" and state_lookahead(state).kind == "..." then
							type = {
								kind = "generic",
								name = state_consume(state) :: TokenIdent,
								dots = state_consume(state) :: TokenType<"...">,
							}
						else
							type = parse_type(state)
						end

						varargs = { dots = dots, type = { colon = colon, type = type } }
					else
						varargs = { dots = dots, type = nil }
					end

					break
				else
					local message = `expected binding, but got '{state_current(state).kind}' instead`
					return state_report_at_current(state, message)
				end
			end
		end

		local close = state_expect(state, ")") :: TokenType<")">

		local returns: { colon: TokenType<":">, type: AstReturnType }?

		if state_current(state).kind == ":" then
			local colon = state_consume(state) :: TokenType<":">
			local type = parse_return_type(state)

			returns = { colon = colon, type = type }
		end

		local block = parse_block(state)
		local end_tok = state_expect(state, "end") :: TokenType<"end">

		return {
			generics = generics,
			parens = { open = open, close = close },
			params = params,
			varargs = varargs,
			returns = returns,
			block = block,
			end_tok = end_tok,
		}
	end

	function parse_function_args(state: State): AstFunctionArgs
		local current = state_current(state)

		if current.kind == "(" then
			local open = state_consume(state) :: TokenType<"(">
			local exprs: AstSeparated<TokenType<",">, AstExpr> = {}

			if state_current(state).kind ~= ")" then
				while true do
					local expr = parse_expr(state)

					if state_current(state).kind == "," then
						table.insert(exprs, { item = expr, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(exprs, { item = expr, sep = nil })
						break
					end
				end
			end

			local close = state_expect(state, ")") :: TokenType<")">

			return {
				kind = "exprlist",
				parens = { open = open, close = close },
				exprs = exprs,
			}
		elseif current.kind == "{" then
			local table = parse_table(state)

			return {
				kind = "table",
				table = table,
			}
		elseif current.kind == "string" then
			local tok = state_consume(state) :: TokenString

			return {
				kind = "string",
				tok = tok,
			}
		else
			error("unreachable")
		end
	end

	function parse_function_call(state: State, lhs: AstVar): AstFunctionCall
		local method

		if state_current(state).kind == ":" then
			method = {
				colon = state_consume(state) :: TokenType<":">,
				name = state_expect(state, "ident") :: TokenIdent,
			}
		end

		local args = parse_function_args(state)

		return {
			lhs = lhs,
			method = method,
			args = args,
		}
	end

	do
		local function parse_stat_if(state: State): AstStatIf
			local if_tok = state_consume(state) :: TokenType<"if">
			local condition = parse_expr(state)
			local then_tok = state_expect(state, "then") :: TokenType<"then">
			local block = parse_block(state)

			local elseifs: {
				{
					elseif_tok: TokenType<"elseif">,
					condition: AstExpr,
					then_tok: TokenType<"then">,
					block: AstBlock,
				}
			} =
				{}

			while state_current(state).kind == "elseif" do
				local elseif_tok = state_consume(state) :: TokenType<"elseif">
				local condition_ = parse_expr(state)
				local then_tok_ = state_expect(state, "then") :: TokenType<"then">
				local block_ = parse_block(state)

				table.insert(elseifs, {
					elseif_tok = elseif_tok,
					condition = condition_,
					then_tok = then_tok_,
					block = block_,
				})
			end

			local else_

			if state_current(state).kind == "else" then
				local else_tok = state_consume(state) :: TokenType<"else">
				local block_ = parse_block(state)

				else_ = { else_tok = else_tok, block = block_ }
			end

			local end_tok = state_expect(state, "end") :: TokenType<"end">

			return {
				kind = "if",
				if_tok = if_tok,
				condition = condition,
				then_tok = then_tok,
				block = block,
				elseifs = elseifs,
				else_ = else_,
				end_tok = end_tok,
			}
		end

		local function parse_stat_while(state: State): AstStatWhile
			local while_tok = state_consume(state) :: TokenType<"while">
			local condition = parse_expr(state)
			local do_tok = state_expect(state, "do") :: TokenType<"do">
			local block = parse_block(state)
			local end_tok = state_expect(state, "end") :: TokenType<"end">

			return {
				kind = "while",
				while_tok = while_tok,
				condition = condition,
				do_tok = do_tok,
				block = block,
				end_tok = end_tok,
			}
		end

		local function parse_stat_do(state: State): AstStatDo
			local do_tok = state_consume(state) :: TokenType<"do">
			local block = parse_block(state)
			local end_tok = state_expect(state, "end") :: TokenType<"end">

			return {
				kind = "do",
				do_tok = do_tok,
				block = block,
				end_tok = end_tok,
			}
		end

		local function parse_stat_for(state: State): AstStatGenericFor | AstStatNumericFor
			local for_tok = state_consume(state) :: TokenType<"for">
			local binding = parse_binding(state)

			if state_current(state).kind == "=" then
				local eq = state_consume(state) :: TokenType<"=">
				local start = parse_expr(state)
				local comma = state_expect(state, ",") :: TokenType<",">
				local finish = parse_expr(state)

				local step

				if state_current(state).kind == "," then
					step = {
						comma = state_consume(state) :: TokenType<",">,
						expr = parse_expr(state),
					}
				end

				local do_tok = state_expect(state, "do") :: TokenType<"do">
				local block = parse_block(state)
				local end_tok = state_expect(state, "end") :: TokenType<"end">

				return {
					kind = "numericfor",
					for_tok = for_tok,
					binding = binding,
					eq = eq,
					start = start,
					comma = comma,
					finish = finish,
					step = step,
					do_tok = do_tok,
					block = block,
					end_tok = end_tok,
				}
			else
				local bindings: AstSeparated<TokenType<",">, AstBinding> = {}

				while true do
					if state_current(state).kind == "," then
						table.insert(bindings, { item = binding, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(bindings, { item = binding, sep = nil })
						break
					end

					binding = parse_binding(state)
				end

				local in_tok = state_expect(state, "in") :: TokenType<"in">
				local exprs: AstSeparated<TokenType<",">, AstExpr> = {}

				while true do
					local expr = parse_expr(state)

					if state_current(state).kind == "," then
						table.insert(exprs, { item = expr, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(exprs, { item = expr, sep = nil })
						break
					end
				end

				local do_tok = state_expect(state, "do") :: TokenType<"do">
				local block = parse_block(state)
				local end_tok = state_expect(state, "end") :: TokenType<"end">

				return {
					kind = "genericfor",
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

		local function parse_stat_repeat(state: State): AstStatRepeat
			local repeat_tok = state_consume(state) :: TokenType<"repeat">
			local block = parse_block(state)
			local until_tok = state_expect(state, "until") :: TokenType<"until">
			local condition = parse_expr(state)

			return {
				kind = "repeat",
				repeat_tok = repeat_tok,
				block = block,
				until_tok = until_tok,
				condition = condition,
			}
		end

		local function parse_stat_function(state: State, attributes: { TokenAttribute }): AstStatFunction
			local function_tok = state_consume(state) :: TokenType<"function">
			local names: AstSeparated<TokenType<".">, TokenIdent> = {}

			while true do
				local name = state_expect(state, "ident") :: TokenIdent

				if state_current(state).kind == "." then
					table.insert(names, { item = name, sep = state_consume(state) :: TokenType<"."> })
				else
					table.insert(names, { item = name, sep = nil })
					break
				end
			end

			local method

			if state_current(state).kind == ":" then
				method = {
					colon = state_consume(state) :: TokenType<":">,
					name = state_expect(state, "ident") :: TokenIdent,
				}
			end

			local body = parse_function_body(state)

			return {
				kind = "function",
				attributes = attributes,
				function_tok = function_tok,
				names = names,
				method = method,
				body = body,
			}
		end

		local function parse_stat_local(
			state: State,
			attributes: { TokenAttribute }
		): AstStatLocalFunction | AstStatLocalAssign
			local local_tok = state_consume(state) :: TokenType<"local">

			if state_current(state).kind == "function" then
				local function_tok = state_consume(state) :: TokenType<"function">
				local name = state_expect(state, "ident") :: TokenIdent
				local body = parse_function_body(state)

				return {
					kind = "localfunction",
					attributes = attributes,
					local_tok = local_tok,
					function_tok = function_tok,
					name = name,
					body = body,
				}
			elseif #attributes ~= 0 then
				local message = "expected 'function' after after local declaration"
					.. ` with attribute, but got {token_error(state_current(state))} instead`

				return state_report_at_current(state, message)
			else
				local bindings: AstSeparated<TokenType<",">, AstBinding> = {}

				while true do
					local binding = parse_binding(state)

					if state_current(state).kind == "," then
						table.insert(bindings, { item = binding, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(bindings, { item = binding, sep = nil })
						break
					end
				end

				if state_current(state).kind == "=" then
					local eq = state_consume(state) :: TokenType<"=">
					local exprs: AstSeparated<TokenType<",">, AstExpr> = {}

					while true do
						local expr = parse_expr(state)

						if state_current(state).kind == "," then
							table.insert(exprs, { item = expr, sep = state_consume(state) :: TokenType<","> })
						else
							table.insert(exprs, { item = expr, sep = nil })
							break
						end
					end

					return {
						kind = "localassign",
						local_tok = local_tok,
						bindings = bindings,
						values = {
							eq = eq,
							exprs = exprs,
						},
					}
				else
					return {
						kind = "localassign",
						local_tok = local_tok,
						bindings = bindings,
						values = nil,
					}
				end
			end
		end

		local function tok_ends_block(tok: Token): boolean
			return tok.kind == "end"
				or tok.kind == "else"
				or tok.kind == "elseif"
				or tok.kind == "until"
				or tok.kind == "eof"
		end

		local function parse_laststat_return(state: State): AstLastStatReturn
			local return_tok = state_consume(state) :: TokenType<"return">
			local exprs: AstSeparated<TokenType<",">, AstExpr> = {}

			if state_current(state).kind ~= ";" and not tok_ends_block(state_current(state)) then
				while true do
					local expr = parse_expr(state)

					if state_current(state).kind == "," then
						table.insert(exprs, { item = expr, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(exprs, { item = expr, sep = nil })
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

		local function tok_into_compound_op(tok: Token): AstCompoundOp?
			if
				tok.kind == "+="
				or tok.kind == "-="
				or tok.kind == "*="
				or tok.kind == "/="
				or tok.kind == "//="
				or tok.kind == "%="
				or tok.kind == "^="
				or tok.kind == "..="
			then
				return tok
			else
				return nil
			end
		end

		function parse_stat(state: State): AstStat | AstLastStat
			local current = state_current(state)

			if current.kind == "if" then
				return parse_stat_if(state)
			elseif current.kind == "while" then
				return parse_stat_while(state)
			elseif current.kind == "do" then
				return parse_stat_do(state)
			elseif current.kind == "for" then
				return parse_stat_for(state)
			elseif current.kind == "repeat" then
				return parse_stat_repeat(state)
			elseif current.kind == "function" then
				return parse_stat_function(state, {})
			elseif current.kind == "local" then
				return parse_stat_local(state, {})
			elseif current.kind == "return" then
				return parse_laststat_return(state)
			elseif current.kind == "break" then
				return {
					kind = "break",
					tok = state_consume(state) :: TokenType<"break">,
				}
			elseif current.kind == "attribute" then
				local attributes: { TokenAttribute } = {}

				while state_current(state).kind == "attribute" do
					table.insert(attributes, state_consume(state) :: TokenAttribute)
				end

				if state_current(state).kind == "function" then
					return parse_stat_function(state, attributes)
				elseif state_current(state).kind == "local" then
					return parse_stat_local(state, attributes)
				else
					local message = "expected 'function' or 'local function' after attribute, but got"
						.. ` '{token_error(state_current(state))}' instead`

					return state_report_at_current(state, message)
				end
			end

			local var = parse_var(state)

			if var.kind == "call" then
				return {
					kind = "call",
					call = var.call,
				}
			elseif state_current(state).kind == "," or state_current(state).kind == "=" then
				local lhs: AstSeparated<TokenType<",">, AstVar> = {}

				while true do
					if state_current(state).kind == "," then
						table.insert(lhs, { item = var, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(lhs, { item = var, sep = nil })
						break
					end

					var = parse_var(state)
				end

				local eq = state_expect(state, "=") :: TokenType<"=">
				local rhs: AstSeparated<TokenType<",">, AstExpr> = {}

				while true do
					local expr = parse_expr(state)

					if state_current(state).kind == "," then
						table.insert(rhs, { item = expr, sep = state_consume(state) :: TokenType<","> })
					else
						table.insert(rhs, { item = expr, sep = nil })
						break
					end
				end

				return {
					kind = "assign",
					lhs = lhs,
					eq = eq,
					rhs = rhs,
				}
			elseif tok_into_compound_op(state_current(state)) then
				local op = state_consume(state) :: AstCompoundOp
				local rhs = parse_expr(state)

				return {
					kind = "compoundassign",
					lhs = var,
					op = op,
					rhs = rhs,
				}
			elseif var.kind == "name" then
				local tok = var.tok

				if tok.value == "export" or tok.value == "type" then
					local export_tok = if tok.value == "export" then tok else nil
					local type_tok

					if export_tok then
						type_tok = state_current(state)

						if type_tok.kind ~= "ident" or type_tok.value ~= "type" then
							state_report_at_current(
								state,
								`expected 'type' after 'export', but got '{type_tok.kind}' instead`
							)
						else
							state_consume(state)
						end
					else
						type_tok = tok
					end

					local name = state_expect(state, "ident") :: TokenIdent
					local generics: AstGenericTypeListWithDefaults?

					if state_current(state).kind == "<" then
						generics = parse_generic_type_list_with_defaults(state)
					end

					local eq = state_expect(state, "=") :: TokenType<"=">
					local type = parse_type(state)

					return {
						kind = "type",
						export_tok = export_tok :: any,
						type_tok = type_tok :: any,
						name = name,
						generics = generics,
						eq = eq,
						type = type,
					}
				elseif tok.value == "continue" then
					return {
						kind = "continue",
						tok = tok :: any,
					}
				end
			end

			return state_report(state, ast_span_var(var), "incomplete statement: expected assignment or function call")
		end

		function parse_block(state: State): AstBlock
			local stats: { { stat: AstStat, semicolon: TokenType<";">? } } = {}
			local laststat: { stat: AstLastStat, semicolon: TokenType<";">? }?

			while true do
				local current = state_current(state)

				if tok_ends_block(current) then
					break
				end

				local stat = parse_stat(state)
				local semicolon = if state_current(state).kind == ";"
					then state_consume(state) :: TokenType<";">
					else nil

				if stat.kind == "return" or stat.kind == "break" or stat.kind == "continue" then
					laststat = { stat = stat, semicolon = semicolon }
				else
					table.insert(stats, { stat = stat, semicolon = semicolon })
				end
			end

			return {
				stats = stats,
				laststat = laststat,
			}
		end
	end

	function parse_ast(state: State): Ast
		local block = parse_block(state)
		local eof = state_expect(state, "eof") :: TokenType<"eof">

		return {
			block = block,
			eof = eof,
		}
	end
end

local function ast_parse(input: string): { success: true, ast: Ast } | { success: false, error: ParseError }
	local success, result = pcall(parse_ast, {
		buf = buffer.fromstring(input),
		pos = 0,

		line = 1,
		char = 0,

		brace_count = 0,
		brace_stack = {},

		current = nil,
		lookahead = nil,
	})

	if success then
		return { success = true, ast = result :: Ast }
	else
		return { success = false, error = result :: ParseError }
	end
end

local function write(self: { buf: buffer, pos: number }, str: string)
	local old_size = buffer.len(self.buf)

	if self.pos + #str >= old_size then
		local new_size = old_size + old_size / 2
		while self.pos + #str >= new_size do
			new_size = new_size + new_size / 2
		end

		local new_buf = buffer.create(new_size)
		buffer.copy(new_buf, 0, self.buf, 0, self.pos)
		self.buf = new_buf
	end

	buffer.writestring(self.buf, self.pos, str, #str)
	self.pos += #str
end

local ast_display: (Ast) -> string

do
	local visitor = visitor_new()

	function visitor.token(self: { buf: buffer, pos: number }, token: Token)
		for _, trivia in token.trivia do
			write(self, trivia.value)
		end

		if
			token.kind == "ident"
			or token.kind == "number"
			or token.kind == "string"
			or token.kind == "istringbegin"
			or token.kind == "istringmiddle"
			or token.kind == "istringlast"
			or token.kind == "attribute"
		then
			write(self, token.value)
		elseif token.kind ~= "eof" then
			write(self, token.kind)
		end
	end

	function ast_display(ast: Ast): string
		local self = { buf = buffer.create(1024), pos = 0 }
		ast_visit(self, visitor, ast)
		return buffer.readstring(self.buf, 0, self.pos)
	end
end

local ast_tokens: (Ast) -> { Token }

do
	local visitor = visitor_new()

	function visitor.token(self: { Token }, token: Token)
		table.insert(self, token)
	end

	function ast_tokens(ast: Ast): { Token }
		local self = {}
		ast_visit(self, visitor, ast)
		return self
	end
end

return {
	visitor = visitor_new,

	location = {
		byte = location_byte,
		line = location_line,
		char = location_char,
	},

	span = {
		start = span_start,
		finish = span_finish,
		merge = span_merge,
	},

	ast = {
		visit = ast_visit,
		parse = ast_parse,
		tokens = ast_tokens,
		display = ast_display,

		span = {
			istring = ast_span_istring,
			type = ast_span_type,
			type_table_field = ast_span_type_table_field,
			return_type = ast_span_return_type,
			type_pack = ast_span_type_pack,
			generic_type_list = ast_span_generic_type_list,
			generic_type_list_with_defaults = ast_span_generic_type_list_with_defaults,
			binding = ast_span_binding,
			expr = ast_span_expr,
			var = ast_span_var,
			function_call = ast_span_function_call,
			function_args = ast_span_function_args,
			table = ast_span_table,
			table_field = ast_span_table_field,
			function_body = ast_span_function_body,
			stat = ast_span_stat,
			laststat = ast_span_laststat,
			block = ast_span_block,
		},
	},
}
