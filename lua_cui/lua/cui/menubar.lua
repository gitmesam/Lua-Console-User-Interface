--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

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
    self.color = color_pair('red', 'white')
end

function Menubar:draw_window()
    local c = self:canvas()

    c:attr(self.color):move(0, 0):write(string.rep(' ', self.size.x*self.size.y))

    c:move(1, 0):write('Menu Bar')
end

function Menubar:handle_event(event)
    View.handle_event(self, event)

end
