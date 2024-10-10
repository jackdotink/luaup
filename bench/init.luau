local datetime = require("@lune/datetime")
local process = require("@lune/process")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local fs = require("@lune/fs")

local log_color = stdio.color("yellow")
local err_color = stdio.color("red")
local time_color = stdio.color("cyan")

stdio.write(log_color)

local function has_flag(flag: string)
	return table.find(process.args, flag) ~= nil
end

if not fs.isDir("bench/temp") then
	stdio.write("Directory 'bench/temp' not found, creating...\n")
	fs.writeDir("bench/temp")
end

local function download_luau()
	stdio.write("Finding latest Luau version...\n")
	local response = net.request("https://api.github.com/repos/luau-lang/luau/releases/latest")
	local latest = serde.decode("json", response.body).tag_name

	stdio.write("Downloading Luau...\n")
	if process.os == "windows" then
		local response = net.request(`https://github.com/luau-lang/luau/releases/download/{latest}/luau-windows.zip`)
		fs.writeFile("bench/temp/luau.zip", response.body)

		stdio.write("Extracting Luau...\n")

		process.spawn("Expand-Archive", { "-Path", "bench/temp/luau.zip", "-DestinationPath", "bench/temp/" })
		process.spawn("Move-Item", { "-Path", "bench/temp/luau.exe", "-Destination", "bench/temp/luau" })

		stdio.write("Cleaning up...\n")

		process.spawn("Remove-Item", { "-Path", "bench/temp/luau.zip" })
		process.spawn("Remove-Item", { "-Path", "bench/temp/luau-analyze.exe" })
		process.spawn("Remove-Item", { "-Path", "bench/temp/luau-ast.exe" })
		process.spawn("Remove-Item", { "-Path", "bench/temp/luau-compile.exe" })
	elseif process.os == "linux" then
		local response = net.request(`https://github.com/luau-lang/luau/releases/download/{latest}/luau-ubuntu.zip`)
		fs.writeFile("bench/temp/luau.zip", response.body)

		stdio.write("Extracting Luau...\n")

		process.spawn("unzip", { "-o", "bench/temp/luau.zip", "luau", "-d", "bench/temp/" })
		process.spawn("chmod", { "+x", "bench/temp/luau" })

		stdio.write("Cleaning up...\n")

		process.spawn("rm", { "-f", "bench/temp/luau.zip" })
	elseif process.os == "macos" then
		error("I'm lazy and don't have a macos device, so you get to contribute macos support!")
	end
end

if not fs.isFile("bench/temp/luau") then
	stdio.write("Luau not found, downloading...\n")
	download_luau()
elseif has_flag(".download") then
	stdio.write("Downloading Luau...\n")
	download_luau()
else
	local metadata = fs.metadata("bench/temp/luau")
	local create_time = metadata.createdAt

	if create_time and datetime.now().unixTimestamp - create_time.unixTimestamp > (60 * 60 * 24) then
		stdio.write("Luau could potentially be outdated, downloading...\n")
		download_luau()
	elseif create_time == nil then
		stdio.write("Luau could potentially be outdated; to redownload run with flag '.download'\n")
	end
end

fs.writeFile("bench/temp/lossless.luau", fs.readFile("lib/lossless.luau"))
-- fs.writeFile("bench/temp/lossy.luau", fs.readFile("lib/lossy.luau"))

fs.writeFile("bench/cases/lossless.luau", fs.readFile("lib/lossless.luau"))
-- fs.writeFile("bench/cases/lossy.luau", fs.readFile("lib/lossy.luau"))

local runner = [[
local luaup = require("./%s")
local code = [===[%s]===]

local start = os.clock()
local result = luaup.ast.parse(code)
local time = os.clock() - start

print(time)
]]

local codegen = if has_flag(".codegen") then true elseif has_flag(".no-codegen") then false else true

local function benchmarks(name: string)
	stdio.write(`Benchmarks for {name} without codegen:\n`)
	for _, path in fs.readDir("bench/cases") do
		local code = fs.readFile("bench/cases/" .. path)
		fs.writeFile("bench/temp/runner.luau", runner:format(`{name}`, code))
		local child = process.spawn("bench/temp/luau", { "bench/temp/runner.luau", "-O2" })
		local time = tonumber(child.stdout)

		if time then
			stdio.write(time_color)
			stdio.write(
				`{path}: {if has_flag(".time") then `{math.round(time * 1_000_000)}us, ` else ""}{math.round(
					#code / time / 1000
				)} KB/s\n`
			)
		else
			stdio.write(err_color)
			stdio.write(`{path}: {child.stderr}\n`)
		end
	end

	if codegen then
		stdio.write(log_color)
		stdio.write(`Benchmarks for {name} with codegen:\n`)
		for _, path in fs.readDir("bench/cases") do
			local code = fs.readFile("bench/cases/" .. path)
			fs.writeFile("bench/temp/runner.luau", runner:format(`{name}`, code))
			local child = process.spawn("bench/temp/luau", { "bench/temp/runner.luau", "-O2", "--codegen" })
			local time = tonumber(child.stdout)

			if time then
				stdio.write(time_color)
				stdio.write(
					`{path}: {if has_flag(".time") then `{math.round(time * 1_000_000)}us, ` else ""}{math.round(
						#code / time / 1000
					)} KB/s\n`
				)
			else
				stdio.write(err_color)
				stdio.write(`{path}: {child.stderr}\n`)
			end
		end
	end
end

if has_flag(".lossless") then
	benchmarks("lossless")
elseif has_flag(".lossy") then
	-- benchmarks("lossy")
else
	benchmarks("lossless")
	-- benchmarks("lossy")
end
