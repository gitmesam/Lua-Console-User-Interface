--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: scrollbar.lua,v 1.3 2004/05/23 21:19:29 tngd Exp $
--------------------------------------------------------------------------]]

-- dependencies
require 'cui'
require 'cui/label'
require 'cui/window'

module 'cui'

--[[ tscrollbar ]----------------------------------------------------------
position = 1..limit where limit > 0

members:
    tscrollbar.position
    tscrollbar.limit
    tscrollbar.page_step
methods:
    tscrollbar:tscrollbar(bounds, [limit, [page_step] ])
    tscrollbar:change_bounds(bounds)
    tscrollbar:draw_window()
    tscrollbar:handle_event(event)
    tscrollbar:set_limit(limit, page_step)
    tscrollbar:set_position(position)

Keys:
    Up          -- current = current - 1
    Down        -- current = current + 1
    PageUp      -- current = current - page_step
    PageDown    -- current = current + page_step
    Space       -- show indicator window
--]]------------------------------------------------------------------------

Scrollbar = View()

function Scrollbar:initialize(bounds, limit, page_step)
    View.initialize(self, bounds)

    -- options
    self.options.selectable = true
    -- event mask
    self.event[Event.ev_keyboard] = true
    -- grow
    self.grow.hix = not vertical
    self.grow.hiy = vertical
    -- state
    self:set_state('cursor_visible', true)  -- for 'focus' tracking

    -- initialization
    self.vertical = bounds:size().x == 1
    self:set_limit(limit or 1, page_step or 1)
    self:set_position(1)
end

function Scrollbar:change_bounds(bounds)
    View.change_bounds(self, bounds)
    -- update indicator
    self:set_position(self.position)
end

function Scrollbar:set_limit(limit, page_step)
    self.limit = limit > 1 and limit or 1
    self.page_step = page_step > 0 and page_step or (-page_step)
    if ((self.position or 1) > self.limit) then
        self:set_position(self.limit)
    end
end

function Scrollbar:set_position(position)
    local r_position
    local limit = self.limit

    if (position < 1) then
        position = 1
    elseif (position > limit) then
        position = limit
    end

    if (position == 1) then
        r_position = 1
    else
        r_position = math.ceil((position * (self.size.y - 2)) / limit)
    end

    self.position = position
    self.r_position = r_position

    if (limit > 1) then
        if (self.vertical) then
            self:goto(0, r_position)
        else
            self:goto(r_position, 0)
        end
    else
        self:goto(self.size.x - 1, self.size.y - 1)
    end
end

function Scrollbar:draw_window()
    local w = self:window()
    local attr = color_pair(curses.COLOR_WHITE, curses.COLOR_BLUE)
    local pos = self.r_position

    if (self.vertical) then
        w:mvaddch(0, 0, curses.ACS_UARROW + attr)
        for y = 2, self.size.y - 1 do
            w:mvaddch(y-1, 0, 32 + attr)
            if (pos == y - 1 and self.limit > 1) then
                w:mvaddch(y-1, 0, string.byte('#') + attr)
            end
        end
        w:mvaddch(self.size.y - 1, 0, curses.ACS_DARROW + attr)
    else
        w:mvaddch(0, 0, curses.ACS_LARROW + attr)
        for x = 2, self.size.x - 1 do
            w:mvaddch(0, x-1, 32 + attr)
            if (pos == x - 1 and self.limit > 1) then
                w:mvaddch(0, x-1, string.byte('#') + attr)
            end
        end
        w:mvaddch(0, self.size.x - 1, curses.ACS_RARROW + attr)
    end
end

local ScrollIndicator -- forward declaration
local function show_indicator(sbar)
    local parent = app.desktop or app
    local si = ScrollIndicator:create(sbar)
    parent:exec_view(si)
    si:close()
end

function Scrollbar:handle_event(event)
    View.handle_event(self, event)

    if (event.type == Event.ev_keyboard) then
        local key = event.key_name
        if (key == "Up" or key == "Right") then
            self:set_position(self.position - 1)
        elseif (key == "Down" or key == "Left") then
            self:set_position(self.position + 1)
        elseif (key == "PageUp") then
            self:set_position(self.position - self.page_step)
        elseif (key == "PageDown") then
            self:set_position(self.position + self.page_step)
        elseif (key == " ") then
            show_indicator(self)
            return
        else
            return
        end
        self:refresh()
        message(self.parent, BroadcastEvent{ Event.be_scrollbar_changed, self })
    end
end


--[[ tscroll_indicator ]----------------------------------------------------
display the position/limit of the scrollbar in a window (in desktop area)
--]]------------------------------------------------------------------------
ScrollIndicator = Window()

function ScrollIndicator:initialize(sbar)
    -- calc bounds
    local str = sbar.position .. ':' .. sbar.limit
    local r = Rect{ 0, 0, #str, 1 }:move(1, 1)
    local label = Label:create(r, str, color_pair(curses.COLOR_BLUE, curses.COLOR_WHITE))
    r:move(-1, -1):grow(1, 1)

    --
    Window.initialize(self, r)

    self.options.centerx = true
    self.options.centery = true

    -- event mask
    self.event[Event.ev_keyboard] = true

    -- initialize
    self:insert(label)
end

function ScrollIndicator:handle_event(event)
    if (event.type == Event.ev_keyboard) then
        self:end_modal(event.key_name)
    end
end
