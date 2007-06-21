--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local floor = math.floor

module 'cui'

local color_pair, calc_attr = color_pair, calc_attr
local Event, View = Event, View

--[[ tframe ]---------------------------------------------------------------
TODO: bounds check (probable truncate) title and print window number

tframe: tview

Members:
    tframe.title
    tframe.attr

Methods:
    tframe:tframe(bounds, title, attr)
    tframe:set_title(title, attr)
    tframe:draw_window()
    tframe:handle_event(event)

draws a border around (inside) the window
--]]------------------------------------------------------------------------

local Frame = View{}

function Frame:initialize(bounds, title, attr)
    View.initialize(self, bounds)

    -- grow
    self.grow.hix = true
    self.grow.hiy = true
    -- event mask
    self.event[Event.ev_broadcast] = true

    self:set_title(title, attr)
end

function Frame:set_title(title, attr)
    self.title = title
    self.attr = attr
    self:refresh()
end

function Frame:draw_window()
    local c = self:canvas()
    local focused = self.parent and self.parent.state.focused
    local attr = calc_attr({ self.attr, focused and 'bold' })

    c:clear():attr(attr):border()

    if self.title then
        local len = #self.title
        local title = c:line(len + 4)

        title:str(1, ' '..self.title..' ', attr)
        if (focused) then
            title:acs(0, 'rtee', attr)
            title:acs(len+3, 'ltee', attr)
        else
            title:acs(0, 'hline', attr)
            title:acs(len+3, 'hline', attr)
        end
        local x = floor((self.size.x - len - 4) / 2)
        c:move(x > 0 and x or 0, 0):write(title)
    end
end

function Frame:handle_event(event)
    View.handle_event(self, event)

    if (event.type == Event.ev_broadcast) then
        if (event.command == Event.be_focused and event.extra.window == self.parent) then
            self:refresh()
        end
    end
end

-- exports
_M.Frame = Frame
