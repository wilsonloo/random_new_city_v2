package.cpath = package.cpath..";lib/?.so"

local Map = require("map")
local PrintR = require("print_r")
local Exporter = require("lib.imgexporter.exporter")

local outdir = ...

local W = 1000
local H = 1000

local REGION_BORDER_COLOR = {r=255, g=0, b=0}
local BLOCK_COLOR = {r=0, g=255, b=0}

local exp = Exporter.new(W, H, "exp")

local exported_regions = {}
local function do_export_region_border(region)
    if not exported_regions[region.rid] then
        exp:rect_color(REGION_BORDER_COLOR, region.x, region.y, region.w, region.h, tostring(region.rid))
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

-- math.randomseed(os.time())

local blocks = {
    {
        y = 772,
        h = 200,
        w = 200,
        x = 238,
    },
    {
        y = 215,
        h = 200,
        w = 200,
        x = 176,
    },
    {
        y = 68,
        h = 200,
        w = 200,
        x = 678,
    },
    {
        y = 755,
        h = 200,
        w = 200,
        x = 591,
    },
    {
        y = 9,
        h = 200,
        w = 200,
        x = 101,
    },
    {
        y = 399,
        h = 200,
        w = 200,
        x = 680,
    },
    {
        y = 547,
        h = 200,
        w = 200,
        x = 50,
    },
}

local map = Map.new(W, H)
for _, b in ipairs(blocks) do
    map:add_node(b.x, b.y, b.w, b.h)
    exp:rect_color(BLOCK_COLOR, b.x, b.y, b.w, b.h)
end
export_region_borders(map.region)
exp:write(outdir.."/0.json")

for k = 1, 2 do
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", k)
    
    local node = map:random(200, 200)
    if node == nil then
        -- node = map:random_cross(200, 200)
        if node == nil then
            break
        end
    end

    PrintR.print_r(k, node)
    exp:rect(node.x, node.y, node.w, node.h)

    -- PrintR.print_r("map:", map)
    export_region_borders(map.region)
    exp:write(outdir.."/"..k..".json")
end