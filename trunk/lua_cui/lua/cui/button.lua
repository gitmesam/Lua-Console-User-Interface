--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local math, string = math, string

module 'cui'

local message, calc_attr, color_pair = message, calc_attr, color_pair
local Event, CommandEvent, View =
      Event, CommandEvent, View

--[[ tbutton ]--------------------------------------------------------------
tbutton: tview

Members:
    tbutton.label
    tbutton.command

Methods:
    tbutton:tbutton(bounds, label, command)
    tbutton:draw_window()
    tbutton:handle_event(event)

on press: message(parent, ev_command, cm_xxxx, self)
--]]------------------------------------------------------------------------
local Button = View()

function Button:initialize(bounds, label, command)
    View.initialize(self, bounds)

    -- options
    self.options.selectable = true
    -- event mask
    self.event[Event.ev_keyboard] = true
    -- state
    self:set_state('cursor_visible', true) -- track focus

    -- initialization
    self.label = label
    self.command = command
    self.fcolor = calc_attr{ color_pair('yellow', 'green'), 'bold' }
    self.ncolor = calc_attr{ color_pair('white', 'blue'), 'bold' }
    self:goto(math.floor((self.size.x - #self.label) / 2), 0)
end

function Button:draw_window()
    local c = self:canvas()
    local attr = self.state.focused and self.fcolor or self.ncolor
    local line = c:line(self.size.x)

    line:str(0, '['..string.rep(' ', self.size.x - 2)..']', attr)
    line:str(math.floor((self.size.x - #self.label) / 2), self.label, attr)
    c:move(0, 0):write(line)
end

function Button:handle_event(event)
    View.handle_event(self, event)

    if (event.type == Event.ev_keyboard) then
        local key = event.key_name
        if (key == 'Enter' or key == ' ') then
            message(self.parent, CommandEvent{ self.command, self })
        end
    end
end

function Button:set_state(state, enable)
    View.set_state(self, state, enable)

    if (state == "focused") then
        self:refresh()
    end
end

-- exports
_M.Button = Button
