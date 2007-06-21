--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]


local sub = string.sub

require 'cui'
module 'cui'

local calc_attr, color_pair, acs = calc_attr, color_pair, acs
local isprint, beep = isprint, beep

local Event = Event

--[[ tedit ]----------------------------------------------------------------
Members:
    tedit.text      -- text entered
    tedit.maxlen    -- maximum length of text
    tedit.startsel  -- selection start
    tedit.endsel    -- selection end
    tedit.start     -- offset of text to draw on window
Methods:
    tedit:tedit(bounds, text, maxlen, readonly)
    tedit:get_text()
    tedit:set_text(text, startsel, endsel)
    tedit:get_maxlen()
    tedit:set_maxlen(maxlen)
    tedit:get_selection()
    tedit:set_selection(startsel, endsel)
--]]------------------------------------------------------------------------


local super = View
local Edit = super()

local function edit_forward(self)
    local cursor = self:cursor()
    if (cursor.x + self.start - 1 < #self.text) then
        if (cursor.x < self.size.x - 1) then
            self:goto(cursor.x + 1, cursor.y)
        else
            self.start = self.start + 1
        end
    end
end

local function edit_backward(self)
    local cursor = self:cursor()
    if (cursor.x > 1 or self.start > 0) then
        if (cursor.x > 1) then
            self:goto(cursor.x - 1, cursor.y)
        else
            self.start = self.start - 1
        end
    end
end

function Edit:initialize(bounds, text, maxlen, readonly)
    super.initialize(self, bounds)

    -- options
    self.options.selectable = true
    -- events
    self.event[Event.ev_keyboard] = true
    -- state
    self:set_state('cursor_visible', true)

    -- initialize
    self.maxlen = maxlen or 0
    self.readonly = readonly or false
    self.start = 0
    self.position = 0
    self:set_text(text, 1, #text + 1)
end

function Edit:draw_window()
    local c = self:canvas()
    local line = c:line(self.size.x)
    local start = self.start
    local text = self.text
    local len = #text
    local ss = self.startsel
    local es = self.endsel
    local nattr, sattr

    if self.state.focused then
        nattr = calc_attr{ color_pair('white', 'green'), 'bold' }
        sattr = calc_attr{ color_pair('cyan', 'green'), 'bold' }
    else
        nattr = calc_attr(color_pair('white', 'blue'))
        sattr = calc_attr(color_pair('cyan', 'blue'))
    end

    if (self.size.x > 0) then
        line:ch(0, self.start == 0 and ' ' or acs('larrow'), nattr)
        line:ch(self.size.x - 1, (self.start + self.size.x - 2 >= len) and ' ' or acs('rarrow'), nattr)
    end

    for i = 1, self.size.x - 2 do
        local idx = i + start
        if (idx <= len) then
            local ch = sub(text, idx, idx)

            if (idx >= ss and idx < es) then
                line:str(i, ch, sattr)
            else
                line:str(i, ch, nattr)
            end
        else
            line:ch(i, ' ', nattr)
        end
    end

    c:move(0, 0):write(line)
end

function Edit:handle_event(event)
    super.handle_event(self, event)

    if (event.type == Event.ev_keyboard) then
        local key = event.key_name
        local key_code = event.key_code
        local meta = event.key_meta
        local cursor = self:cursor()

        if (key == "Left") then
            edit_backward(self)
        elseif (key == "Right") then
            edit_forward(self)
        elseif (key == "CtrlB") then
            self:set_selection(self.start + cursor.x, self.endsel)
        elseif (key == "CtrlE") then
            self:set_selection(self.startsel, self.start + cursor.x)
        elseif (key == "Home") then
            self.start = 0
            self:goto(1, 0)
        elseif (key == "End") then
            local len = #self.text
            local start = len - self.size.x + 2
            self.start = start < 0 and 0 or start
            self:goto(len - self.start + 1, 0)
        elseif (self.readonly) then
            -- stop processing keysif read only control
        elseif (key == "Backspace") then
            local idx = self.start + cursor.x - 1
            if (idx > 0) then
                local text = self.text
                self.text = sub(text, 1, idx - 1) .. sub(text, idx + 1)
                edit_backward(self)
            end
            self:set_selection(0, 0)
        elseif (key == "Delete") then
            if (self.startsel ~= self.endsel) then
                local text = self.text
                self.text = sub(text, 1, self.startsel - 1) .. sub(text, self.endsel)
                if (self.startsel <= self.start) then
                    self.start = self.startsel - 1
                end
                self:goto(self.startsel - self.start, 0)
            else
                local idx = self.start + cursor.x - 1
                local text = self.text
                if (idx < #text) then
                    self.text = sub(text, 1, idx) .. sub(text, idx + 2)
                    --tedit_backward(self)
                end
            end
            self:set_selection(0, 0)
        elseif (isprint(key_code) and #key == 1 and not meta) then
            local idx = self.start + cursor.x - 1

            local text = self.text
            if (#text < self.maxlen) then
                self.text = sub(text, 1, idx) ..key.. sub(text, idx + 1)
                edit_forward(self)
            else
                beep()
            end

            self:set_selection(0, 0)
        else
            return
        end
        self:refresh()
    end
end

function Edit:get_text()
    return self.text
end

function Edit:set_text(text, startsel, endsel)
    -- check maxlen
    if (self.maxlen > 0 and #text > self.maxlen) then
        text = sub(text, 1, self.maxlen)
    end
    self.text = text

    -- set visible index
    local len = #text
    if (len > self.size.x - 2) then
        self.start = len - self.size.x + 2
    else
        self.start = 0
    end
    self:goto(len - self.start + 1, 0)

    self:set_selection(startsel, endsel)
end

function Edit:get_maxlen()
    return self.maxlen
end

function Edit:set_maxlen(maxlen)
    self.maxlen = maxlen or 0
    self:set_text(self.text, self.startsel, self.endsel)
end

function Edit:get_selection()
    return self.startsel, self.endsel
end

function Edit:set_selection(startsel, endsel)
    startsel = startsel or self.startsel
    endsel = endsel or startsel or self.endsel

    local len = #self.text
    if (startsel > endsel or startsel > len or endsel > len + 1) then
        startsel = 0
        endsel = 0
    end

    self.startsel = startsel
    self.endsel = endsel
end

function Edit:set_state(state, enable)
    super.set_state(self, state, enable)

    if state == 'focused' then
        self:refresh()
    end
end

_M.Edit = Edit
