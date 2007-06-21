--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: button.lua,v 1.3 2004/05/23 21:19:29 tngd Exp $
--------------------------------------------------------------------------]]

local math, string = math, string

local curses = require 'cui.curses'

module 'cui'

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
Button = View()

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
    self.fcolor = color_pair(curses.COLOR_YELLOW, curses.COLOR_GREEN) + curses.A_BOLD
    self.ncolor = color_pair(curses.COLOR_WHITE, curses.COLOR_BLUE) + curses.A_BOLD
    self:goto(math.floor((self.size.x - #self.label) / 2), 0)
end

function Button:draw_window()
    local w = self:window()
    local attr = self.state.focused and self.fcolor or self.ncolor
    local str = curses.new_chstr(self.size.x)
    str:set_str(0, '['..string.rep(' ', self.size.x - 2)..']', attr)
    str:set_str(math.floor((self.size.x - #self.label) / 2), self.label, attr)
    w:mvaddchstr(0, 0, str)
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
