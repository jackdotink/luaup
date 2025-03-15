local cst = require("./cst")
local visit = require("./visit")

local module = {}

do
	local visitor = visit.visitor()

	local buf = buffer.create(1024)
	local pos = 0

	local function write(string: string)
		local bytes = #string
		local new_pos = (pos + bytes) :: number
		local old_len = buffer.len(buf)

		if new_pos >= old_len then
			local new_len = old_len * 2
			while new_pos >= new_len do
				new_len = new_len * 2
			end

			local new_buf = buffer.create(new_len)
			buffer.copy(new_buf, 0, buf, 0, pos)
			buf = new_buf
		end

		buffer.writestring(buf, pos, string, bytes)
		pos = new_pos
	end

	function visitor.visit_token(_, token)
		for _, trivia in token.trivia do
			write(trivia.text)
		end

		if (token :: any).text then
			write((token :: any).text :: any)
		elseif token.kind ~= "eof" then
			write(token.kind)
		end
	end

	function module.tostring(cst: cst.Cst)
		pos = 0
		visit.visit(visitor, nil, cst)
		return buffer.readstring(buf, 0, pos)
	end
end

do
	local visitor = visit.visitor()

	local lines: { string } = {}

	for key in visitor :: any do
		(visitor :: any)[key] = function()
			table.insert(lines, key)
		end
	end

	function module.visited(cst: cst.Cst)
		table.clear(lines)
		visit.visit(visitor, nil, cst)
		return table.concat(lines, "\n")
	end
end

return module