package.cpath = package.cpath..";lib/?.so"

local Map = require("map")
local PrintR = require("print_r")
local Exporter = require("lib.imgexporter.exporter")

local outdir = ...

local W = 200
local H = 200

local REGION_BORDER_COLOR = {r=255, g=0, b=0}
local exp = Exporter.new(W, H, "exp")

local exported_regions = {}
local function do_export_region_border(region)
    if not exported_regions[region.rid] then
        exp:rect_color(REGION_BORDER_COLOR, region.x, region.y, region.w, region.h)
        exported_regions[region.rid] = true
        print("region border:", region.rid)
    end
end
local function export_region_borders(region)
    do_export_region_border(region)

    if region.list then
        for _, r in pairs(region.list) do
            export_region_borders(r)
        end
    end
end

local map = Map.new(W, H)
for k = 1, 10 do
    local node = map:random(40, 40)
    PrintR.print_r(k, node)
    exp:rect(node.x, node.y, node.w, node.h)

    PrintR.print_r("map:", map)
    export_region_borders(map.region)
    exp:write(outdir.."/"..k..".json")
end