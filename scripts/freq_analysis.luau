local net = require("@lune/net")

local files = {
	"https://raw.githubusercontent.com/jackdotink/luaup/main/lib.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/untrack.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/trace.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/throw.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/switch.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/spring.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/source.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/show.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/read.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/mount.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/maps.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/init.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/graph.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/flags.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/effect.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/derive.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/defaults.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/create.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/cleanup.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/changed.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/bind.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/batch.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/apply.luau",
	"https://raw.githubusercontent.com/centau/vide/main/src/action.luau",
	"https://raw.githubusercontent.com/centau/ecr/main/src/ecr.luau",
	"https://raw.githubusercontent.com/Ukendio/jecs/main/src/init.luau",
	"https://raw.githubusercontent.com/Data-Oriented-House/Squash/main/src/init.luau",
	"https://raw.githubusercontent.com/1Axen/blink/main/src/Parser.luau",
}

local tokens = {
	-- Keywords
	["and"] = 0,
	["break"] = 0,
	["do"] = 0,
	["else"] = 0,
	["elseif"] = 0,
	["end"] = 0,
	["false"] = 0,
	["for"] = 0,
	["function"] = 0,
	["if"] = 0,
	["in"] = 0,
	["local"] = 0,
	["nil"] = 0,
	["not"] = 0,
	["or"] = 0,
	["repeat"] = 0,
	["return"] = 0,
	["then"] = 0,
	["true"] = 0,
	["until"] = 0,
	["while"] = 0,
	-- Symbols
	["+="] = 0,
	["-="] = 0,
	["*="] = 0,
	["/="] = 0,
	["//="] = 0,
	["%="] = 0,
	["^="] = 0,
	["..="] = 0,
	["+"] = 0,
	["-"] = 0,
	["*"] = 0,
	["/"] = 0,
	["//"] = 0,
	["%"] = 0,
	["^"] = 0,
	[".."] = 0,
	["<"] = 0,
	["<="] = 0,
	[">"] = 0,
	[">="] = 0,
	["=="] = 0,
	["~="] = 0,
	["#"] = 0,
	["..."] = 0,
	["&"] = 0,
	["|"] = 0,
	["?"] = 0,
	[":"] = 0,
	["::"] = 0,
	["->"] = 0,
	["="] = 0,
	[","] = 0,
	[";"] = 0,
	["."] = 0,
	-- Delims
	["("] = 0,
	[")"] = 0,
	["{"] = 0,
	["}"] = 0,
	["["] = 0,
	["]"] = 0,
}

local function lex(buf: buffer): (number?, string?)
	local pos = 0
	local line = 1

	local function char(c: string)
		return string.byte(c)
	end

	local function is_whitespace(c: number)
		return c == char(" ") or c == char("\t") or c == char("\n") or c == char("\r")
	end

	local function is_digit(c: number)
		return char("0") <= c and c <= char("9")
	end

	local function is_alpha(c: number)
		return (char("a") <= c and c <= char("z")) or (char("A") <= c and c <= char("Z"))
	end

	local function first()
		if pos >= buffer.len(buf) then
			return 0
		else
			return buffer.readu8(buf, pos)
		end
	end

	local function second()
		if pos + 1 >= buffer.len(buf) then
			return 0
		else
			return buffer.readu8(buf, pos + 1)
		end
	end

	local function bump()
		if first() == char("\n") then
			line += 1
		end

		pos = pos + 1
	end

	while true do
		local c = first()

		if c == 0 then
			return nil, nil
		elseif is_whitespace(c) then
			while true do
				if not is_whitespace(c) then
					break
				end

				bump()
				c = first()
			end
		elseif is_alpha(c) or c == char("_") then
			local start = pos

			while is_alpha(c) or is_digit(c) or c == char("_") do
				bump()
				c = first()
			end

			local value = buffer.readstring(buf, start, pos - start)

			if tokens[value] then
				tokens[value] += 1
			end
		elseif is_digit(c) or (c == char(".") and is_digit(second())) then
			while is_digit(c) or is_alpha(c) or c == char("_") or c == char(".") do
				bump()
				c = first()
			end

			if c == char("e") or c == char("E") then
				bump()
				c = first()

				if c == char("+") or c == char("-") then
					bump()
					c = first()
				end

				while is_digit(c) or is_alpha(c) or c == char("_") do
					bump()
					c = first()
				end
			end
		elseif c == char('"') or c == char("'") then
			local quote = c
			bump()

			while true do
				c = first()

				if c == 0 or c == char("\n") then
					return line, "unterminated string 1"
				elseif c == quote then
					bump()
					break
				elseif c == char("\\") then
					bump()

					if first() == char("\r") then
						bump()

						if first() == char("\n") then
							bump()
						end
					elseif first() == char("z") then
						bump()

						while is_whitespace(first()) do
							bump()
						end
					else
						bump()
					end
				else
					bump()
				end
			end
		elseif c == char("`") then
			bump()

			while true do
				c = first()

				if c == 0 or c == char("`") then
					bump()
					break
				elseif c == char("\n") then
					return line, "unterminated string 2"
				elseif c == char("\\") then
					bump()

					if first() == char("\r") then
						bump()

						if first() == char("\n") then
							bump()
						end
					elseif first() == char("z") then
						bump()

						while is_whitespace(first()) do
							bump()
						end
					else
						bump()
					end
				else
					bump()
				end
			end
		elseif c == char("-") and second() == char("-") then
			bump()
			bump()

			local eqs: number?

			if first() == char("[") and (second() == char("[") or second() == char("=")) then
				bump()
				local count = 0

				while first() == char("=") do
					count += 1
					bump()
				end

				if first() == char("[") then
					eqs = count
					bump()
				end
			end

			while true do
				c = first()

				if c == 0 then
					return line, "unfinished comment"
				elseif c == char("\n") and eqs == nil then
					bump()
					break
				elseif first() == char("]") and eqs then
					bump()

					local count = 0

					while first() == char("=") do
						count += 1
						bump()
					end

					if count == eqs and first() == char("]") then
						bump()
						break
					end
				else
					bump()
				end
			end
		elseif c == char("+") then
			bump()

			if first() == char("=") then
				bump()
				tokens["+="] += 1
			else
				tokens["+"] += 1
			end
		elseif c == char("-") then
			bump()

			if first() == char("=") then
				bump()
				tokens["-="] += 1
			elseif first() == char(">") then
				bump()
				tokens["->"] += 1
			else
				tokens["-"] += 1
			end
		elseif c == char("*") then
			bump()

			if first() == char("=") then
				bump()
				tokens["*="] += 1
			else
				tokens["*"] += 1
			end
		elseif c == char("/") then
			bump()

			if first() == char("=") then
				bump()
				tokens["/="] += 1
			elseif first() == char("/") then
				bump()

				if first() == char("=") then
					bump()
					tokens["//="] += 1
				else
					tokens["//"] += 1
				end
			else
				tokens["/"] += 1
			end
		elseif c == char("%") then
			bump()

			if first() == char("=") then
				bump()
				tokens["%="] += 1
			else
				tokens["%"] += 1
			end
		elseif c == char("^") then
			bump()

			if first() == char("=") then
				bump()
				tokens["^="] += 1
			else
				tokens["^"] += 1
			end
		elseif c == char(".") then
			bump()

			if first() == char(".") then
				bump()

				if first() == char("=") then
					bump()
					tokens["..="] += 1
				elseif first() == char(".") then
					bump()
					tokens["..."] += 1
				else
					tokens[".."] += 1
				end
			else
				tokens["."] += 1
			end
		elseif c == char("<") then
			bump()

			if first() == char("=") then
				bump()
				tokens["<="] += 1
			else
				tokens["<"] += 1
			end
		elseif c == char(">") then
			bump()

			if first() == char("=") then
				bump()
				tokens[">="] += 1
			else
				tokens[">"] += 1
			end
		elseif c == char("=") then
			bump()

			if first() == char("=") then
				bump()
				tokens["=="] += 1
			else
				tokens["="] += 1
			end
		elseif c == char("~") then
			bump()

			if first() == char("=") then
				bump()
				tokens["~="] += 1
			else
				return line, "'~' but no '='"
			end
		elseif c == char("#") then
			bump()
			tokens["#"] += 1
		elseif c == char("&") then
			bump()
			tokens["&"] += 1
		elseif c == char("|") then
			bump()
			tokens["|"] += 1
		elseif c == char("?") then
			bump()
			tokens["?"] += 1
		elseif c == char(":") then
			bump()

			if first() == char(":") then
				bump()
				tokens["::"] += 1
			else
				tokens[":"] += 1
			end
		elseif c == char(",") then
			bump()
			tokens[","] += 1
		elseif c == char(";") then
			bump()
			tokens[";"] += 1
		elseif c == char("(") then
			bump()
			tokens["("] += 1
		elseif c == char(")") then
			bump()
			tokens[")"] += 1
		elseif c == char("{") then
			bump()
			tokens["{"] += 1
		elseif c == char("}") then
			bump()
			tokens["}"] += 1
		elseif c == char("[") then
			bump()

			if first() == char("[") or first() == char("=") then
				local eqs = 0

				while first() == char("=") do
					eqs += 1
					bump()
				end

				if first() == char("[") then
					bump()
				else
					return line, "long string error 1"
				end

				while true do
					c = first()

					if c == 0 then
						return line, "long string error 2"
					elseif c == char("]") then
						bump()

						local count = 0

						while first() == char("=") do
							count += 1
							bump()
						end

						if count == eqs and first() == char("]") then
							bump()
							break
						end
					else
						bump()
					end
				end
			else
				tokens["["] += 1
			end
		elseif c == char("]") then
			bump()
			tokens["]"] += 1
		else
			return line, "unknown character " .. c .. " " .. string.char(c)
		end
	end
end

for _, url in files do
	print("downloading " .. url)
	local response = net.request(url)
	print("downloaded " .. url)

	if response.statusCode == 200 then
		print("lexing " .. url)
		local line, err = lex(buffer.fromstring(response.body))

		if line and err then
			print("error: " .. err .. " at line " .. line)
		else
			print("lexed " .. url)
		end
	else
		print("error: " .. response.statusCode .. " " .. response.statusMessage)
	end
end

local keys = {}

for key in tokens do
	table.insert(keys, key)
end

table.sort(keys, function(a, b)
	return tokens[a] > tokens[b]
end)

for _, key in keys do
	print(key, tokens[key])
end
