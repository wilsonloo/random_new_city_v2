local mrandom = math.random
local mmin = math.min
local mmax = math.max
local mceil = math.ceil
local tsort = table.sort
local tinsert = table.insert

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
    if w >= cell_w and h >= cell_h then
        local cell_x = mrandom(x, x + w - cell_w)
        local cell_y = mrandom(y, y + h - cell_h)
        return cell_x, cell_y
    end
end

local split_region
local add_node_into_region_list
local function add_node(region, nx, ny, nw, nh)
    if region.node ~= nil then
        split_region(region)
    end
    
    region.node = {
        x = nx,
        y = ny,
        w = nw,
        h = nh,
    }
    region.size = region.size + nw*nh
end

add_node_into_region_list = function(region, node)
    local nx = node.x
    local ny = node.y
    local nw = node.w
    local nh = node.h
    local halfw = region.w/2
    local halfh = region.h/2
    local halfx = region.x + halfw
    local halfy = region.y + halfh
    if nx < halfx and ny < halfy then
        local rbx = mmin(nx+nw, halfx)
        local rby = mmin(ny+nh, halfy) 
        add_node(region.list[RID_LT], nx, ny, rbx-nx, rby-ny)
    end
    if nx+nw >= halfx and ny < halfy then
        local lbx = mmax(nx, halfx)
        local lby = mmin(ny+nh, halfy)
        add_node(region.list[RID_RT], lbx, ny, nx+nw-lbx, lby-ny)
    end
    if nx < halfx and ny+nh >= halfy then
        local rtx = mmin(nx+nw, halfx)
        local rty = mmax(ny, halfy)
        add_node(region.list[RID_LB], nx, rty, rtx-nx, ny+nh-rty)
    end
    if nx+nx >= halfx and ny+nh >= halfy then
        local ltx = mmax(nx, halfx)
        local lty = mmax(ny, halfy)
        add_node(region.list[RID_RB], ltx, lty, nx+nw-ltx, ny+nh-lty)
    end
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

split_region = function(region)
    local node = region.node
    region.node = nil

    local halfw = mceil(region.w/2)
    local halfh = mceil(region.h/2)
    region.list = {
        [RID_LT] = create_region(region.x, region.y, halfw, halfh),
        [RID_RT] = create_region(region.x+halfw, region.y, halfw, halfh),
        [RID_LB] = create_region(region.x, region.y+halfh, halfw, halfh),
        [RID_RB] = create_region(region.x+halfw, region.y+halfh, halfw, halfh),
    }
    
    if node then
        region.size = region.size - node.w*node.h
        add_node_into_region_list(region, node)
    end
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

local function calc_cross_space(region, x, y, w, h)
    if region.list then
        local sum = 0
        for _, r in ipairs(region.list) do
            sum = sum + calc_cross_space(r, x, y, w, h)
        end
        return sum
    elseif region.node then
        local w_min = mmax(region.node.x, x)
        local w_max = mmin(region.node.x+region.node.w, x+w)
        if w_max <= w_min then
            return 0
        end

        local h_min = mmax(region.node.y, y)
        local h_max = mmin(region.node.y+region.node.h, y+h)
        if h_max <= h_min then
            return 0
        end

        return (w_max-w_min)*(h_max-h_min)
    else
        return 0    
    end
end

local mt = {}
mt.__index = mt

function mt:init()
    self.region = create_region(0, 0, self.w, self.h)
end

function mt:check_can_fill(x, y, w, h)
    if x+w > self.region.x+self.region.w then
        return false
    elseif y+h > self.region.y+self.region.h then
        return false
    end

    local space = calc_cross_space(self.region, x, y, w, h)
    return space == 0
end


function mt:random_with_small_region(region, cell_w, cell_h)
    print("random_with_small_region:", region.rid)
    if region.list then
        for _, r in ipairs(region.list) do
            local found = self:random_with_small_region(r, cell_w, cell_h)
            if found then
                return found
            end
        end
    end

    local xlist = {}
    local ylist = {}
    tinsert(xlist, region.x)
    tinsert(ylist, region.y)
    if region.node then
        if region.node.x > region.x then
            tinsert(xlist, region.node.x)
        end
        if region.node.x+region.node.w < region.x+region.w then
            tinsert(xlist, region.node.x+region.node.w)
        end

        if region.node.y > region.y then
            tinsert(ylist, region.node.y)
        end
        if region.node.y+region.node.h < region.y+region.h then
            tinsert(ylist, region.node.y+region.node.h)
        end
    end

    PrintR.print_r("xlist:", xlist)
    PrintR.print_r("ylist:", ylist)
    for _, x in ipairs(xlist) do
        for _, y in ipairs(ylist) do
            print("scaning:", x, y)
            if self:check_can_fill(x, y, cell_w, cell_h) then
                return {
                    x = x,
                    y = y,
                    w = cell_w,
                    h = cell_h,
                }
            end
        end
    end
end

function mt:random_amound_list(region_list, cell_w, cell_h)
    local cell_size = cell_w*cell_h
    local list = sort_regions(region_list)
    -- PrintR.print_r("sorted:", list)
    for _, region in ipairs(list) do
        print("try sorted region:", region.rid)
        local node = self:do_random(region, cell_w, cell_h)
        if node ~= nil then
            return node
        end
    end
end

function mt:do_random(region, cell_w, cell_h)
    assert(cell_w > 0)
    assert(cell_h > 0)
    assert(region ~= nil)
    local found = nil
    local cell_size = cell_w*cell_h
    if region.list then
        print("random amound regions:", 
            region.list[1].rid, 
            region.list[2].rid, 
            region.list[3].rid,
            region.list[4].rid)

        found = self:random_amound_list(region.list, cell_w, cell_h)
    elseif region.node then
        local node = region.node
        local remain = region.cap - region.size
        if remain < cell_size then
            return
        end
        
        if region.w*region.h < cell_w*cell_h then
            print("sub region:", region.rid, "too small to split")
            return
        end

        split_region(region)
        print("split region:", region.rid, "to:",
            region.list[1].rid, 
            region.list[2].rid, 
            region.list[3].rid,
            region.list[4].rid)

        found = self:do_random(region, cell_w, cell_h)
        if found == nil then
            -- currenly smallest region
            -- maybe region.node too small
            found = self:random_with_small_region(region, cell_w, cell_h)
            if found ~= nil then
                PrintR.print_r("small found:", found)
                add_node_into_region_list(region, found)
            end
        end
    else
        -- currenly empty region
        print("pure empty region")
        if region.w*region.w < cell_size then
            print("region empty but too small")
            return
        end

        local cell_x, cell_y = rand_cell(region.x, region.y, region.w, region.h, cell_w, cell_h)
        if cell_x == nil then
            print("region empty but too small-2")
            return            
        end

        -- add first node
        print("add first node")
        found = {
            x = cell_x,
            y = cell_y,
            w = cell_w,
            h = cell_h,
        }
        region.node = found
    end

    if found then
        region.size = region.size + (cell_w * cell_h)
        return found
    end
end

function mt:random(cell_w, cell_h)
    return self:do_random(self.region, cell_w, cell_h)
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