--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local floor = math.floor

local curses = require 'cui.curses'

module 'cui'

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

Frame = View{}

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
    self.attr = attr or curses.A_NORMAL
    self:refresh()
end

function Frame:draw_window()
    local w = self:window()
    local focused = self.parent and self.parent.state.focused
    local attr = self.attr + (focused and curses.A_BOLD or 0)

    w:attrset(attr)
    w:clear()
    w:border()
    if (self.title) then
        local len = #self.title
        local title = curses.new_chstr(len + 4)
        title:set_str(1, ' '..self.title..' ', attr)
        if (focused) then
            title:set_ch(0, curses.ACS_RTEE, attr)
            title:set_ch(len+3, curses.ACS_LTEE, attr)
        else
            title:set_ch(0, curses.ACS_HLINE, attr)
            title:set_ch(len+3, curses.ACS_HLINE, attr)
        end
        local x = floor((self.size.x - len - 4) / 2)
        w:mvaddchstr(0, x > 0 and x or 0, title)
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
