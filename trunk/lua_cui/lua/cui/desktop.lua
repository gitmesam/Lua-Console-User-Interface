--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: desktop.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

-- dependencies
require 'cui'
require 'cui/window'
require 'cui/scrollbar'
require 'cui/listbox'

module 'cui'

-- Desktop
Desktop = Group{}

function Desktop:initialize(bounds)
    Group.initialize(self, bounds)
    self.grow.hix = true
    self.grow.hiy = true

    self.background = self:init_background()
    self:insert(self.background)
end

function Desktop:init_background()
    local bg = View:create(Rect{0, 0, self.size.x, self.size.y})
    bg.grow.hix = true
    bg.grow.hiy = true
    function bg:draw_window()
        local w = self:window()
        local len = self.size.x
        local str = curses.new_chstr(len)
        str:set_ch(0, curses.ACS_BLOCK, color_pair(curses.COLOR_BLUE, curses.COLOR_BLUE) + curses.A_BOLD, len)
        for y = 0, self.size.y - 1 do
            w:mvaddchstr(y, 0, str)
        end
    end
    return bg
end

function Desktop:list_windows()
    -- window size
    local size = self.size():subxy(20, 10)

    -- window
    local wl = Window:create(Rect{0, 0, size.x, size.y}, 'Window list')
    wl.options.centerx = true
    wl.options.centery = true

    -- scrollbar
    local sbar = Scrollbar:create(Rect {size.x - 1, 1, size.x, size.y - 1})

    -- create window list
    local list = {}
    self:for_each(function(w)
        if w.options.selectable then
            table.insert(list, 1, { w.title, window = w })
        end
    end)

    -- create list
    local listbox = Listbox:create(Rect {1, 1, size.x - 1, size.y - 1}, 1, list, sbar)
    wl:insert(listbox)
    wl:insert(sbar)
    wl:select_next(true)

    -- window handler
    function wl:handle_event(event)
        Window.handle_event(self, event)

        if (event.type == Event.ev_keyboard) then
            local key = event.key_name
            if (key == "Enter") then
                self:end_modal(Event.cm_ok)
            elseif (key == "Backspace" or key == "Esc") then
                self:end_modal(Event.cm_cancel)
            end
        end
    end

    -- show window - modal
    if (self:exec_view(wl) == Event.cm_ok) then
        local item = list[listbox.position]
        if (item and item.window) then
            self:select(item.window)
        end
    end

    -- free window
    wl:close()
end

function Desktop:handle_event(event)
    Group.handle_event(self, event)

    if (event.type == Event.ev_command) then
        if (event.command == Event.cm_prev) then
            if (self._current:is_valid(Event.cm_release_focus)) then
                self:lock()
                self:select_next(false, nil)
                self:redraw(true)
                self:unlock()
            end
        elseif (event.command == Event.cm_next) then
            local current = self._current
            if (current and current ~= self.background._next and current:is_valid(Event.cm_release_focus)) then
                self:lock()
                self:select_next(true, nil)
                self:redraw(true)
                self:unlock()
            end
        end
    elseif (event.type == Event.ev_keyboard) then
        local key = event.key_name
        if (key == 'Alt0') then
            self:list_windows()
            event.type = nil
        elseif (string.find(key, "Alt", 1, true) == 1) then -- Alt-number
            local number = tonumber(string.sub(key, 4)) or -1
            if (number >= 0 and number <= 9) then
                message(self, BroadcastEvent{ Event.be_select_window_number, number })
            end
        end
    end
end
