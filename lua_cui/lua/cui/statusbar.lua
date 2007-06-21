--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local string = string
local ipairs = ipairs

module 'cui'

local message, color_pair = message, color_pair
local Event, View = Event, View

--[[ tstatusbar ]----------------------------------------------------------

--]]------------------------------------------------------------------------

local Statusbar = View{}

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

    self.key_attr = color_pair('red', 'white')
    self.text_attr = color_pair('black', 'white')
end

function Statusbar:draw_window()
    local w = self:canvas()
    local x = 0
    local tattr = self.text_attr
    local kattr = self.key_attr

    w:move(0, 0)

    for _, e in ipairs(self.command_table) do
        if (e[5]) then
            w:attr(kattr):write(' '..e[1]):attr(tattr):write(' '..e[2])
            x = x + #e[1] + #e[2] + 2
        end
    end

    if (x < self.size.x) then
        w:attr(tattr):write(string.rep(' ', self.size.x - x))
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

-- exports
_M.Statusbar = Statusbar
