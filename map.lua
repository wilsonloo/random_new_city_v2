local mrandom = math.random
local mmin = math.min
local mmax = math.max
local tsort = table.sort

local PrintR = require("print_r")

local RID_LT = 1
local RID_RT = 2
local RID_RB = 3
local RID_LB = 4

local g_rid = 0
local function gen_rid()
    g_rid = g_rid + 1
    return g_rid
end

local function shuffle_rids()
    local list = {RID_LT, RID_RT, RID_RB, RID_LB}
    for k = 1, 2 do
        local a = mrandom(1, 4)
        local b = mrandom(1, 4)
        if a == b then
            b = (b+1) % 4 + 1
        end
        list[a], list[b] = list[b], list[a]
    end
    return list
end

local function rand_cell(x, y, w, h, cell_w, cell_h)
    local cell_x = mrandom(x, x + cell_w)
    local cell_y = mrandom(y, y + cell_h)
    return cell_x, cell_y
end

local function add_node(region, nx, ny, nw, nh)
    assert(region.node == nil)
    region.node = {
        x = nx,
        y = ny,
        w = nw,
        h = nh,
    }
    region.size = region.size + nw*nh
end

local function create_region(x, y, w, h)
    local region = {
        rid = gen_rid(),
        x = x,
        y = y,
        w = w,
        h = h,
        cap = w * h,
        size = 0,
        -- list = nil,
        -- node = nil,
    }
    return region
end

local function split_region(region)
    local halfw = region.w/2
    local halfh = region.h/2
    local region_list = {
        [RID_LT] = create_region(region.x, region.y, halfw, halfh),
        [RID_RT] = create_region(region.x+halfw, region.y, halfw, halfh),
        [RID_LB] = create_region(region.x, region.y+halfh, halfw, halfh),
        [RID_RB] = create_region(region.x+halfw, region.y+halfh, halfw, halfh),
    }
    if region.node then
        local nx = region.node.x
        local ny = region.node.y
        local nw = region.node.w
        local nh = region.node.h
        local halfx = region.x + halfw
        local halfy = region.y + halfh
        if nx < halfx and ny < halfy then
            local rbx = mmin(nx+nw, halfx)
            local rby = mmin(ny+nh, halfy) 
            add_node(region_list[RID_LT], nx, ny, rbx-nx, rby-ny)
        end
        if nx+nw >= halfx and ny < halfy then
            local lbx = mmax(nx, halfx)
            local lby = mmin(ny+nh, halfy)
            add_node(region_list[RID_RT], lbx, ny, nx+nw-lbx, lby-ny)
        end
        if nx < halfx and ny+nh >= halfy then
            local rtx = mmin(nx+nw, halfx)
            local rty = mmax(ny, halfy)
            add_node(region_list[RID_LB], nx, rty, rtx-nx, ny+nh-rty)
        end
        if nx+nx >= halfx and ny+nh >= halfy then
            local ltx = mmax(nx, halfx)
            local lty = mmax(ny, halfy)
            add_node(region_list[RID_RB], ltx, lty, nx+nw-ltx, ny+nh-lty)
        end
    end
    return region_list
end

local function find_rb(region)
    if region.list then
        local rb = region.list[RID_RB]
        return find_rb(rb)
    end
    if region.node then
        local rbx = region.node.x + region.node.w
        local rby = region.node.y + region.node.h
        return rbx, rby, region.x+region.w-rbx, region.y+region.h-rby
    end
    return region.x, region.y, region.w, region.h
end

local function sort_regions(region_list)
    local list = 
    {   
        region_list[RID_LT], 
        region_list[RID_RT], 
        region_list[RID_RB], 
        region_list[RID_LB],
    }
    
    tsort(list, function(a, b)
        local ar = a.cap - a.size
        local br = b.cap - b.size
        if ar > br then
            return true
        elseif ar < br then
            return false
        end
        return a.rid < b.rid
    end)
    return list
end

local random
local function random_amound_list(region_list, cell_w, cell_h)
    local cell_size = cell_w*cell_h
    local list = sort_regions(region_list)
    PrintR.print_r("sorted:", list)
    for _, region in ipairs(list) do
        local node = random(region, cell_w, cell_h)
        if node ~= nil then
            return node
        end
    end
end

random = function(region, cell_w, cell_h)
    assert(cell_w > 0)
    assert(cell_h > 0)
    assert(region ~= nil)
    local cell_size = cell_w*cell_h
    if region.list then
        PrintR.print_r("random amound list", region.list)
        return random_amound_list(region.list, cell_w, cell_h)
    elseif region.node then
        local remain = region.cap - region.size
        if remain < cell_size then
            return
        end
        print("split region:", region.rid)
        region.list = split_region(region)
        region.node = nil
        return random(region, cell_w, cell_h)
    else
        -- add first node
        print("add first node")
        local cell_x, cell_y = rand_cell(region.x, region.y, region.w, region.h, cell_w, cell_h)
        assert(cell_x)
        assert(cell_y)
        local node = {
            x = cell_x,
            y = cell_y,
            w = cell_w,
            h = cell_h,
        }
        region.size = region.size + (cell_w * cell_h)
        region.node = node
        return node
    end
end

local mt = {}
mt.__index = mt

function mt:init()
    self.region = create_region(0, 0, self.w, self.h)
end

function mt:random(cell_w, cell_h)
    return random(self.region, cell_w, cell_h)
end

local M = {}
function M.new(map_width, map_heigh)
    local map = {
        w = map_width,
        h = map_heigh,
    }

    map = setmetatable(map, mt)
    map:init()
    return map
end

return M