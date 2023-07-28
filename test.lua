package.cpath = package.cpath..";lib/?.so"

local Map = require("map")
local PrintR = require("print_r")
local Exporter = require("lib.imgexporter.exporter")
local Config = require "config"

local outdir = ...

local REGION_BORDER_COLOR = {r=255, g=0, b=0}
local BLOCK_COLOR = {r=0, g=255, b=0}

if Config.RANDOM_SEED then
    math.randomseed(Config.RANDOM_SEED)
end

local exp = Exporter.new(Config.MAP_WIDTH, Config.MAP_HEIGH, "exp")

local exported_regions = {}
local function do_export_region_border(region)
    if not exported_regions[region.rid] then
        local rid = nil
        if Config.EXPORT_REGION_RID and region.rid then
            rid = tostring(region.rid)
        end
        exp:rect_color(REGION_BORDER_COLOR, region.x, region.y, region.w, region.h, rid)
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

local map = Map.new(Config.MAP_WIDTH, Config.MAP_HEIGH)

if Config.blocks and #Config.blocks > 0 then
    for _, b in ipairs(Config.blocks) do
        map:add_node(b.x, b.y, b.w, b.h)
        exp:rect_color(BLOCK_COLOR, b.x, b.y, b.w, b.h)
    end
    export_region_borders(map.region)
    exp:write(outdir.."/0.json")
end

for k = 1, 100 do
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> round:", k)

    local node = map:random(Config.CELL_WIDTH, Config.CELL_HEIGH)
    if node == nil then
        print("no any more")
        break
    end

    PrintR.print_r(k, node)
    exp:rect(node.x, node.y, node.w, node.h)

    -- PrintR.print_r("map:", map)
    export_region_borders(map.region)
    exp:write(outdir.."/"..k..".json")
end