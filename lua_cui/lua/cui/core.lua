
--[=[
Section: globals
    Utility functions.
--]=]

local io = io
local min, max = math.min, math.max
local error, tostring = error, tostring

local curses = require 'cui.curses'

module('cui')

-- internals
local colors = {}
local ncolors = 0

-- debugging utils
function log(...)
    do return end

    local f = io.open('cui.log', 'a')
    for i = 1, arg.n do
        if (i > 1) then f:write('\t') end
        f:write(tostring(arg[i]))
    end
    f:write('\n')
    f:close()
end


--[=[
Function: enum
    Enumerate values.

Arguments:
    t - where the enumerated labels will be saved
    list - list of enumerations
        the last label is used as a marker for the last value used
        when we want to add more elements to the enumeration

Example:
    > local colors = {}
    > enum(colors, { 'blue', 'red', 'max_color' })

    colors == { blue = 1, red = 2, max_color = 3 }

    > enum(colors, { 'green', 'max_color' })

    colors == { blue = 1, red = 2, green = 3, max_color = 4 }

--]=]
function enum(t, list)
    local index = (t[list[#list]] or 1) - 1
    for i = 1, #list do
        t[list[i]] = i + index
    end
end

--[=[
Function: range
    Make sure a given value is within a minimum and maximum limits.

Parameters:
    value - the value to limit
    min - the minimum value allowed
    max - the maximum value allowed
--]=]
function range(value, min_value, max_value)
    return min(max_value, max(value, min_value))
end

--[=[
Function: color_pair
    Get the color attribute for the given color pair.

Parameters:
    fg - foreground color
    bg - background color
--]=]
function color_pair(fg, bg)
    if (not curses.has_colors()) then return 0 end
    local idx = fg .. ':' .. bg

    if colors[idx] then
        return colors[idx]
    end

    ncolors = ncolors + 1
    if (not curses.init_pair(ncolors, fg, bg)) then
        error('failed to initialize color pair ('..ncolors..','..fg..','..bg..')')
    end

    local attr = curses.color_pair(ncolors)
    colors[idx] = attr
    return attr
end
