--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tiago.dionizio AT gmail.com)
$Id$
--------------------------------------------------------------------------]]

local type = type

local curses = require 'cui.curses'

module 'cui'

local calc_attr, acs = calc_attr, acs
local Object = Object

local Canvas = Object()
local Line = Object()


function Canvas:create(view, window)
    -- create instance
    self = self()

    self._view = view
    self._window = window

    self:attr()
    return self
end

function Canvas:clear()
    self._window:clear()
    return self
end

function Canvas:move(x, y)
    self._window:move(y, x)
    return self
end

function Canvas:border()
    self._window:border()
    return self
end

function Canvas:write_ch(ch)
    self._window:addch(ch)
    return self
end

function Canvas:write_acs(ch)
    return self:write_ch(acs(ch))
end

function Canvas:write(str, len)
    if type(str) == 'string' then
        self._window:addstr(str, len)
    else
        self._window:addchstr(str._line, len)
    end
    return self
end

function Canvas:attr(attrs, modify)
    local w = self._window
    local apply = w.attron
    local attr = calc_attr(attrs)

    if modify == nil then
        w:attrset(attr)
    elseif modify == false then
        w:attroff(attr)
    else
        w:attron(attr)
    end

    apply(w, attr)

    return self
end

function Canvas:line(length)
    return Line:create(length)
end


function Line:create(length)
    self = self()
    self._length = length
    self._line = curses.new_chstr(length)
    return self
end

function Line:__len()
    return self._length
end

function Line:ch(offset, char, attrs, length)
    self._line:set_ch(offset, char, attrs and calc_attr(attrs), length)
    return self
end

function Line:acs(offset, char, attrs, length)
    return self:ch(offset, acs(char), attrs, length)
end

function Line:str(offset, str, attrs, rep)
    self._line:set_str(offset, str, calc_attr(attrs), rep)
    return self
end

_M.Canvas = Canvas
