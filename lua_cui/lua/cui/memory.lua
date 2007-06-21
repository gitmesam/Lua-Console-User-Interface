--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local tostring, collectgarbage =
      tostring, collectgarbage

local ceil = math.ceil
local time = os.time

-- dependencies
module 'cui'

local Event, View =
      Event, View

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

local Memory = View()

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
    self.color = color_pair('blue', 'white')

    self:update()
end

function Memory:handle_event(event)
    if (event.type == Event.ev_idle) then
        self:update()
    end
end

function Memory:draw_window()
    local c = self:canvas()
    local line = c:line(self.size.x)
    local info = tostring(ceil(collectgarbage('count')*1024))
    local pad = self.size.x - #info

    line:str(0, ' ', self.color, pad):str(pad, info, self.color)
    c:move(0, 0):write(line)
end

function Memory:update()
    local t = time()
    if (t ~= self.last_time) then
        self.last_time = t
        self:refresh()
    end
end

_M.Memory = Memory
