package.cpath = package.cpath..";lib/?.so"

local Map = require("map")
local PrintR = require("print_r")
local Exporter = require("lib.imgexporter.exporter")

local outdir = ...

local W = 1000
local H = 1000

local REGION_BORDER_COLOR = {r=255, g=0, b=0}
local BLOCK_COLOR = {r=0, g=255, b=0}

-- math.randomseed(os.time())
local EXPORT_REGION_RID = true

local exp = Exporter.new(W, H, "exp")

local exported_regions = {}
local function do_export_region_border(region)
    if not exported_regions[region.rid] then
        local rid = nil
        if EXPORT_REGION_RID and region.rid then
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

local map = Map.new(W, H)
local blocks = {
    {
        y = 285,
        x = 602,
        w = 200,
        h = 200,
    },
    {
        y = 63,
        x = 91,
        w = 200,
        h = 200,
    },
    {
        y = 741,
        x = 272,
        w = 200,
        h = 200,
    },
    {
        y = 555,
        x = 616,
        w = 200,
        h = 200,
    }
}

blocks = {}
for _, b in ipairs(blocks) do
    map:add_node(b.x, b.y, b.w, b.h)
    exp:rect_color(BLOCK_COLOR, b.x, b.y, b.w, b.h)
end
export_region_borders(map.region)
exp:write(outdir.."/0.json")

for k = 1, 100 do
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", k)

    local node = map:random(200, 200)
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