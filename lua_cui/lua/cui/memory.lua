--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: memory.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

-- dependencies
require 'cui'
module 'cui'

--[[ tmemory ]--------------------------------------------------------------
tmemory:tview

Members:
    tmemory.last_time
    tmemory.color
Methods:
    tmemory:tmemory(bounds)
    tmemory:handle_event(event)
    tmemory:draw_window()
    tmemory:update()
--]]------------------------------------------------------------------------

Memory = View()

function Memory:initialize(bounds)
    View.initialize(self, bounds)

    -- grow flags
    self.grow.lox = true
    self.grow.hix = true
    self.grow.loy = true
    self.grow.hiy = true

    -- event mask
    self.event[Event.ev_idle] = true

    -- members
    self.last_time = 0
    self.color = color_pair(curses.COLOR_BLUE, curses.COLOR_WHITE)

    self:update()
end

function Memory:handle_event(event)
    if (event.type == Event.ev_idle) then
        self:update()
    end
end

function Memory:draw_window()
    local w = self:window()
    local str = curses.new_chstr(self.size.x)
    local info = tostring(math.ceil(collectgarbage('count')*1024))
    local pad = self.size.x - #info
    str:set_str(0, ' ', self.color, pad)
    str:set_str(pad, info, self.color)
    self:window():mvaddchstr(0, 0, str)
end

function Memory:update()
    local t = os.time()
    if (t ~= self.last_time) then
        self.last_time = t
        self:refresh()
    end
end
