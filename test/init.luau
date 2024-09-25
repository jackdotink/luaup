local fs = require("@lune/fs")

local luaup = require("../lib")
local old = require("../old")

local code = fs.readFile("lib.luau")

local start = os.clock()
local result = luaup.ast.parse(code)
local finish = os.clock()

print(`new: parsed in {finish - start} seconds, {#code / (finish - start) / 1000} kilobytes per second`)

local start = os.clock()
local result = old.ast.parse(code)
local finish = os.clock()

print(`old: parsed in {finish - start} seconds, {#code / (finish - start) / 1000} kilobytes per second`)
