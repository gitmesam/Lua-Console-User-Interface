--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]


--[=[
Section: globals
    Utility functions.
--]=]

local io = io
local min, max = math.min, math.max
local error, tostring = error, tostring
local pairs, type = pairs, type

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

-- import some of the curses functions
local curses_imports = {
    'isalnum', 'isalpha', 'iscntrl', 'isdigit',
    'isgraph', 'islower', 'isprint', 'ispunct',
    'isspace', 'isupper', 'isxdigit',

    'beep'
}
for _, f in pairs(curses_imports) do
    _M[f] = curses[f]
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
function map_color(name)
        if name == 'black' then     return curses.COLOR_BLACK
    elseif name == 'red' then       return curses.COLOR_RED
    elseif name == 'green' then     return curses.COLOR_GREEN
    elseif name == 'yellow' then    return curses.COLOR_YELLOW
    elseif name == 'blue' then      return curses.COLOR_BLUE
    elseif name == 'magenta' then   return curses.COLOR_MAGENTA
    elseif name == 'cyan' then      return curses.COLOR_CYAN
    elseif name == 'white' then     return curses.COLOR_WHITE
    else                            return curses.COLOR_BLACK
    end
end

function map_attr(name)
        if name == 'normal' then    return curses.A_NORMAL
    elseif name == 'standout' then  return curses.A_STANDOUT
    elseif name == 'underline' then return curses.A_UNDERLINE
    elseif name == 'reverse' then   return curses.A_REVERSE
    elseif name == 'blink' then     return curses.A_BLINK
    elseif name == 'dim' then       return curses.A_DIM
    elseif name == 'bold' then      return curses.A_BOLD
    elseif name == 'protect' then   return curses.A_PROTECT
    elseif name == 'invis' then     return curses.A_INVIS
    elseif name == 'alt' then       return curses.A_ALTCHARSET
    else                            return curses.A_NORMAL
    end
end

function acs(char)
        if char == 'block' then     return curses.ACS_BLOCK
    elseif char == 'board' then     return curses.ACS_BOARD
    elseif char == 'btee' then      return curses.ACS_BTEE
    elseif char == 'bullet' then    return curses.ACS_BULLET
    elseif char == 'ckboard' then   return curses.ACS_CKBOARD
    elseif char == 'darrow' then    return curses.ACS_DARROW
    elseif char == 'degree' then    return curses.ACS_DEGREE
    elseif char == 'diamond' then   return curses.ACS_DIAMOND
    elseif char == 'gequal' then    return curses.ACS_GEQUAL
    elseif char == 'hline' then     return curses.ACS_HLINE
    elseif char == 'lantern' then   return curses.ACS_LANTERN
    elseif char == 'larrow' then    return curses.ACS_LARROW
    elseif char == 'lequal' then    return curses.ACS_LEQUAL
    elseif char == 'llcorner' then  return curses.ACS_LLCORNER
    elseif char == 'lrcorner' then  return curses.ACS_LRCORNER
    elseif char == 'ltee' then      return curses.ACS_LTEE
    elseif char == 'nequal' then    return curses.ACS_NEQUAL
    elseif char == 'pi' then        return curses.ACS_PI
    elseif char == 'plminus' then   return curses.ACS_PLMINUS
    elseif char == 'plus' then      return curses.ACS_PLUS
    elseif char == 'rarrow' then    return curses.ACS_RARROW
    elseif char == 'rtee' then      return curses.ACS_RTEE
    elseif char == 's1' then        return curses.ACS_S1
    elseif char == 's3' then        return curses.ACS_S3
    elseif char == 's7' then        return curses.ACS_S7
    elseif char == 's9' then        return curses.ACS_S9
    elseif char == 'sterling' then  return curses.ACS_STERLING
    elseif char == 'ttee' then      return curses.ACS_TTEE
    elseif char == 'uarrow' then    return curses.ACS_UARROW
    elseif char == 'ulcorner' then  return curses.ACS_ULCORNER
    elseif char == 'urcorner' then  return curses.ACS_URCORNER
    elseif char == 'vline' then     return curses.ACS_VLINE
    elseif type(char) == 'string' and #char == 1 then
        return char
    else
        return ' '
    end
end

local map_attr = map_attr
function calc_attr(attrs)
    local atype = type(attrs)

    if atype == 'number' then
        return attrs
    elseif atype == 'string' then
        return map_attr(attrs)
    elseif atype == 'table' then
        local set = {}
        local v = 0

        for _, a in pairs(attrs) do
            if not set[a] and a then
                set[a] = true

                if type(a) == 'number' then
                    v = v + a
                else
                    v = v + map_attr(a)
                end
            end
        end

        return v
    else
        return 0
    end
end


local map_color = map_color
function color_pair(fg, bg)
    fg = map_color(fg)
    bg = map_color(bg)

    local idx = fg .. ':' .. bg

    if colors[idx] then
        return colors[idx]
    end

    if (not curses.has_colors()) then return 0 end

    ncolors = ncolors + 1
    if (not curses.init_pair(ncolors, fg, bg)) then
        error('failed to initialize color pair ('..ncolors..','..fg..','..bg..')')
    end

    local attr = curses.color_pair(ncolors)
    colors[idx] = attr
    return attr
end

