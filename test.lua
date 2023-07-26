package.cpath = package.cpath..";lib/?.so"

local Map = require("map")
local PrintR = require("print_r")
local Exporter = require("lib.imgexporter.exporter")

local outdir = ...

local W = 200
local H = 200
local exp = Exporter.new(W, H, "exp")

local map = Map.new(W, H)
for k = 1, 10 do
    local node = map:random(40, 40)
    PrintR.print_r(k, node)
    exp:rect(node.x, node.y, node.w, node.h)
    exp:write(outdir.."/"..k..".json")
end