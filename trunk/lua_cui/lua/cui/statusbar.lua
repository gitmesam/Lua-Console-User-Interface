--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: statusbar.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

local curses = require 'cui.curses'

local string = string
local ipairs = ipairs

module 'cui'

--[[ tstatusbar ]----------------------------------------------------------

--]]------------------------------------------------------------------------

Statusbar = View{}

function Statusbar:initialize(bounds, command_table)
    View.initialize(self, bounds)

    -- grow
    self.grow.loy = true
    self.grow.hiy = true
    self.grow.hix = true
    -- options
    self.options.pre_event = true
    -- event mask
    self.event[Event.ev_keyboard] = true

    -- members
    self.command_table = command_table

    self.key_attr = color_pair(curses.COLOR_RED, curses.COLOR_WHITE)
    self.text_attr = color_pair(curses.COLOR_BLACK, curses.COLOR_WHITE)
end

function Statusbar:draw_window()
    local w = self:window()
    local x = 0
    local tattr = self.text_attr
    local kattr = self.key_attr

    for _, e in ipairs(self.command_table) do
        if (e[5]) then
            w:attrset(kattr)
            w:addstr(' '..e[1])
            w:attrset(tattr)
            w:addstr(' '..e[2])
            x = x + #e[1] + #e[2] + 2
        end
    end

    if (x < self.size.x) then
        w:attrset(tattr)
        w:addstr(string.rep(' ', self.size.x - x))
    end
end

function Statusbar:handle_event(event)
    View.handle_event(self, event)

    if (event.type == Event.ev_keyboard) then
        local key = event.key_name
        for _, e in ipairs(self.command_table) do
            if (e[1] == key) then
                message(self.parent, Event{ Event[e[3]], Event[e[4]] })
                event.type = nil
            end
        end
    end
end
