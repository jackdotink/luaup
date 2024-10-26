local luau = require("@lune/luau")
local fs = require("@lune/fs")

local lossless = require("../lib/lossless")

local bytecode = luau.compile([[
local luaup, code = ...

local start = os.clock()
local result = luaup.ast.parse(code)
local stop = os.clock()

return stop - start, result
]], {
	optimizationLevel = 2,
	coverageLevel = 0,
	debugLevel = 1,
})

local bytecode_runner = luau.load(bytecode, {
	codegenEnabled = false,
})

local native_runner = luau.load(bytecode, {
	codegenEnabled = true,
})

local output: { { string } } = {}

local function print_output()
	local longest_name = 0
	for _, row in output do
		longest_name = math.max(longest_name, #row[1])
	end

	local longest_err = 6
	for _, row in output do
		longest_err = math.max(longest_err, #row[5])
	end

	print("| Name"..(" "):rep(longest_name - 4).." | Size KB | Time ms | Speed KB/s | Result |")

	for _, row in output do
		print(`| {row[1]}{(" "):rep(longest_name - #row[1])} | {row[2]} KB | {row[3]} ms | {row[4]} KB/s | {row[5]}{(" "):rep(longest_err - #row[5])} |`)
	end
end

local function run(runner: (...any) -> ...any, source: string, name: string)
	local time: number, result: any = runner(lossless, source)

	table.insert(output, {
		name, ("%04d"):format(#source / 1000), ("%04d"):format(time * 1000), ("%05d"):format((#source / 1000) / time),
		if result.success then "OK" else `{result.error.span.start}:{result.error.span.finish} {result.error.message}`,
	})
end

print("Running benchmarks to warm up...")

run(bytecode_runner, fs.readFile("lib/lossless.luau"), "lossless")

for _, name in fs.readDir("bench/cases") do
	run(bytecode_runner, fs.readFile(`bench/cases/{name}`), name)
end

run(native_runner, fs.readFile("lib/lossless.luau"), "lossless")

for _, name in fs.readDir("bench/cases") do
	run(native_runner, fs.readFile(`bench/cases/{name}`), name)
end

output = {}

print("Running bytecode benchmarks...")

run(bytecode_runner, fs.readFile("lib/lossless.luau"), "lossless")

for _, name in fs.readDir("bench/cases") do
	run(bytecode_runner, fs.readFile(`bench/cases/{name}`), name)
end

print_output()
output = {}

print("Running native benchmarks...")

run(native_runner, fs.readFile("lib/lossless.luau"), "lossless")

for _, name in fs.readDir("bench/cases") do
	run(native_runner, fs.readFile(`bench/cases/{name}`), name)
end

print_output()
output = {}