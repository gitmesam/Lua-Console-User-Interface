--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: menubar.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

local curses = require 'cui.curses'

local string = string

module 'cui'

--[[ tmenubar ]------------------------------------------------------------

--]]------------------------------------------------------------------------

Menubar = View{}

function Menubar:initialize(bounds)
    View.initialize(self, bounds)

    -- grow
    self.grow.hix = true
    -- options
    self.options.pre_event = true
    -- event mask
    self.event[Event.ev_keyboard] = true

    -- members
    self.color = color_pair(curses.COLOR_RED, curses.COLOR_WHITE)
end

function Menubar:draw_window()
    local w = self:window()
    w:attrset(self.color)
    w:mvaddstr(0, 0, string.rep(' ', self.size.x*self.size.y))

    w:mvaddstr(0, 0, 'Menu Bar')
end

function Menubar:handle_event(event)
    View.handle_event(self, event)

end
