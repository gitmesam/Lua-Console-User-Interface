--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: window.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

require 'cui'
require 'cui/frame'

module 'cui'

--[[ twindow ]--------------------------------------------------------------
TODO:
    make frame optional
    window flags (frame, move, resize)
    event handling:
        move, resize

members:
    twindow.frame
    twindow.title
    twindow.window_number

methods:
    twindow:twindow(bounds, title, number)
    twindow:handle_event(event)
    twindow:is_valid(data)
    twindow:init_frame() virtual
    twindow:set_title(title)

--]]------------------------------------------------------------------------

Window = Group()

function Window:initialize(bounds, title, number)
    Group.initialize(self, bounds)

    -- new options
    self.options.can_move       = true  -- move window using keyboard
    self.options.can_resize     = true  -- resize window using keyboard
    -- options
    self.options.top_select     = true
    -- members
    self.title = title
    self.window_number = number

    self.frame = self:init_frame()
    if (self.frame) then self:insert(self.frame) end
end

function Window:set_title(title)
    self.title = title
    if (self.frame) then self.frame:set_title(title) end
end

function Window:init_frame()
    local frame = Frame()
    frame:initialize(
        Rect{0, 0, self.size.x, self.size.y},
        self.title,
        color_pair(curses.COLOR_WHITE, curses.COLOR_BLUE)
    )
    return frame
end

function Window:handle_event(event)
    Group.handle_event(self, event)

    if (event.type == Event.ev_broadcast) then
        if (event.command == Event.be_select_window_number) then
            if (event.extra == self.window_number) then
                self.lock()
                self.parent:select(self) self:refresh()
                self:unlock()
            end
        end
    elseif (event.type == Event.ev_command) then
        if (event.command == Event.cm_close) then
            if (self.state.modal) then
                self:end_modal(Event.cm_close)
            elseif (self:is_valid(Event.cm_close)) then
                self:close()
            end
        end
    elseif (event.type == Event.ev_keyboard) then
        local key = event.key_name
        if (key == "Tab") then
            self:select_next(true)
        elseif (key == "ShiftTab") then
            self:select_next(false)
        end
    end
end

function Window:is_valid(data)
    if (not Group.is_valid(self, data) or
        (self.state.modal and (data == Event.cm_release_focus or data == Event.cm_quit))) then
            return false
    end
    return true
end
