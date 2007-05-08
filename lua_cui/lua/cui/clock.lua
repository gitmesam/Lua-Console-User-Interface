--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: clock.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

-- dependencies
require 'cui'
module 'cui'

--[[ tclock ]---------------------------------------------------------------
tclock:tview

Members:
    tclock.last_time
    tclock.color
Methods:
    tclock:tclock(bounds)
    tclock:handle_event(event)
    tclock:draw_window()
    tclock:update()
--]]------------------------------------------------------------------------
Clock = View()

function Clock:initialize(bounds)
    View.initialize(self, bounds)

    -- grow flags
    self.grow.lox = true
    self.grow.hix = true

    -- event mask
    self.event[Event.ev_idle] = true

    -- members
    self.last_time = 0
    self.color = color_pair(curses.COLOR_BLUE, curses.COLOR_WHITE)

    self:update()
end

function Clock:handle_event(event)
    if (event.type == Event.ev_idle) then
        self:update()
    end
end

function Clock:draw_window()
    local w = self:window()
    local str = curses.new_chstr(self.size.x)
    str:set_str(0, os.date('%H:%M:%S', self.last_time), self.color)
    self:window():mvaddchstr(0, 0, str)
end

function Clock:update()
    local t = os.time()
    if (t ~= self.last_time) then
        self.last_time = t
        self:refresh()
    end
end
