--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local date, time = os.date, os.time

-- dependencies
require 'cui'
module 'cui'

local color_pair = color_pair
local View, Event = View, Event

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
local Clock = View()

function Clock:initialize(bounds)
    View.initialize(self, bounds)

    -- grow flags
    self.grow.lox = true
    self.grow.hix = true

    -- event mask
    self.event[Event.ev_idle] = true

    -- members
    self.last_time = 0
    self.color = color_pair('blue', 'white')

    self:update()
end

function Clock:handle_event(event)
    if (event.type == Event.ev_idle) then
        self:update()
    end
end

function Clock:draw_window()
    local c = self:canvas()
    local line = c:line(self.size.x)
    line:str(0, date('%H:%M:%S', self.last_time), self.color)
    c:move(0, 0):write(line)
end

function Clock:update()
    local t = time()
    if (t ~= self.last_time) then
        self.last_time = t
        self:refresh()
    end
end

-- exports
_M.Clock = Clock
