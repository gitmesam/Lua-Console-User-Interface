--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]


--[[ Base window object ]---------------------------------------------------
tgroup: tview

tgroup private members:
    tgroup._current
    tgroup._first

tgroup members:
    tgroup.scroll   -- tpoint

tgroup private methods:
    tgroup:draw_child(window)

tgroup public methods:
    tgroup:tgroup(bounds)
    tgroup:close()
    tgroup:for_each(function(window))
    tgroup:change_bounds(bounds)
    tgroup:max_bounds()     -- return bounds transformation where all windows will fit
    tgroup:scroll_to(x, y)
    tgroup:insert_before(window, next)
    tgroup:insert(window)
    tgroup:remove(child)
    tgroup:handle_event(event)
    tgroup:is_valid(data)
    tgroup:execute()
    tgroup:exec_view(window)
    tgroup:draw_window()
    tgroup:redraw(onparent)
    tgroup:refresh()
    tgroup:set_state(state_name, enable)
    tgroup:select_next(forward [, start])
    tgroup:select(child [, send_to_back])   -- send_to_back is used by select_next
    tgroup:get_data(data)
    tgroup:set_data(data)

--------------------------------------------------------------------------]]

local min, max, floor = math.min, math.max, math.floor
local assert = assert

-- load curses module
local curses = require 'cui.curses'

module 'cui'

local Point, Rect, View, Event, IdleEvent =
      Point, Rect, View, Event, IdleEvent
local message = message

local Group = View{}

-- constructor
function Group:initialize(bounds)
    View.initialize(self, bounds)

    -- options
    self.options.selectable     = true
    self.options.validate       = true

    -- event mask - enable by default on groups
    self.event[Event.ev_broadcast] = true
    self.event[Event.ev_command]   = true
    self.event[Event.ev_keyboard]  = true
    self.event[Event.ev_idle]      = true

    -- scroll position
    self.scroll = Point{0, 0}
end

function Group:close()
    self:show(false)
    while (self._first) do
        self._first:close()
    end
    View.close(self)
end

--[[ tgroup:for_each ]-------------------------------------------------------
iterate through all child windows passing them to a callback function.
if the callback returns true, the iteration is stopped

usage:
    group:for_each(function(window)
        ...
        -- do something with the window
        ...
        -- return true
    end)
--------------------------------------------------------------------------]]
function Group:for_each(fun)
    local first = self._first
    if (first) then
        local w = first
        repeat
            local next = w._next
            if (fun(w)) then break end
            w = next
        until w == nil or w == first
    end
end


function Group:change_bounds(bounds)
    local size = bounds:size()
    -- verify size limits
    local minl, maxl = self:size_limits()
    if (minl.x > size.x or minl.y > size.y or maxl.x < size.x or maxl.y < size.y) then
        return
    end
    --
    local delta = size - self.size
    self:set_bounds(bounds)
    if (delta.x == 0 and delta.y == 0) then
        self:refresh()
    else
        self:lock()
        self:for_each(function(w)
            w:change_bounds(w:calc_bounds(delta))
        end)
        self:unlock()
    end
end

function Group:max_bounds()
    local bounds = self:bounds()
    self:for_each(function(w)
        bounds:union(w._bounds)
    end)
    return bounds
end

function Group:scroll_to(x, y)
    -- check bounds
    local mb = self:max_bounds()
    if (x < 0 or y < 0 or x > mb.ex - mb.sx - self.size.x or y > mb.e.y - mb.s.y - self.size.y) then
        return false
    end

    if (x ~= self.scroll.x or y ~= self.scroll.y) then
        self.scroll = Point { x, y }
    end
    return true
end

--[[ window management ]--------------------------------------------------]]

local function remove_view(g, w)
    if (w._next == w) then
        -- the only window in the list
        g._first = nil
    else
        w._previous._next = w._next
        w._next._previous = w._previous
        if (g._first == w) then
            g._first = w._next
        end
    end

    w._next = nil
    w._previous = nil
    w.parent = nil
end

local function insert_view(g, w, next)
    if (g._first == nil) then
        w._next = w
        w._previous = w

        g._first = w
    elseif (next == nil) then
        next = g._first

        w._previous = next._previous
        w._next = next
        next._previous._next = w
        next._previous = w

        g._first = w
    else
        w._previous = next._previous
        w._next = next
        next._previous._next = w
        next._previous = w
    end
    w.parent = g
end

function Group:insert_before(window, next)
    assert(not window.parent or window.parent == self)

    self:lock()

    if (window.parent == self) then self:remove(window) end

    -- center if options are set
    local bounds = window:bounds()
    local org = Point {bounds.sx, bounds.sy}
    if (window.options.centerx) then
        org.x = floor((self.size.x - window.size.x) / 2)
    end
    if (window.options.centery) then
        org.y = floor((self.size.y - window.size.y) / 2)
    end
    bounds:move(org.x - bounds.sx, org.y - bounds.sy)
    window:set_bounds(bounds)

    insert_view(self, window, next)

    if (window.options.selectable) then
        self:select(window)
    end

    window:draw_window()
    window:show(true)

    self:unlock()
end

function Group:insert(window)
    self:insert_before(window, self._first)
end

function Group:remove(window)
    window:show(false)

    remove_view(self, window)

    if (self._current == window) then
        self._current = nil
        self:select_next()
    end
end

local function do_handle_event(group, event, phase)
    if (not group or not group._first) then return end

    if (phase < 0) then
        event.pre_event = true
        group:for_each(function(w)
            if (w.options.pre_event and w.event[event.type]) then
                w:handle_event(event)
            end
        end)
        event.pre_event = nil
    elseif (phase == 0) then
        if (event.type ~= Event.ev_broadcast and event.type ~= Event.ev_idle) then
            local current = group._current
            if (current and current.event[event.type]) then
                current:handle_event(event)
            end
        else
            group:for_each(function(w)
                if (w.event[event.type]) then
                    w:handle_event(event)
                end
            end)
        end
    elseif (phase > 0) then
        event.post_event = true
        group:for_each(function(w)
            if (w.options.post_event and w.event[event.type]) then
                w:handle_event(event)
            end
        end)
        event.post_event = nil
    end
end

function Group:handle_event(event)
    do_handle_event(self, event, -1)
    do_handle_event(self, event, 0)
    do_handle_event(self, event, 1)
end


function Group:is_valid(data)
    local current = self._current
    if (current and current.options.validate) then
        return current:is_valid(data)
    end
    return true
end


local function exec_view(window, parent, modal)
    assert(window)

    local save_current
    modal = modal or false
    --
    window:set_state('modal', modal)
    if (parent) then
        save_current = parent._current
        parent:insert(window)
    else
        window:show(true)
    end
    --
    local event
    local will_sleep
    window.modal_state = nil
    repeat
        event = window:get_event()
        if (event) then
            window:handle_event(event)
            will_sleep = false
        else
            -- idle action
            will_sleep = not message(app, IdleEvent())
        end

        --
        if (will_sleep and not window.modal_state) then
            curses.napms(50)
        end
    until window.modal_state
    --
    if (parent) then
        window:lock()
        window:show(false)
        parent:remove(window)
        parent._current = save_current
        window:unlock()
    else
        window:show(false)
    end
    window:set_state('modal', not modal)
    --
    return window.modal_state
end

-- main loop!
function Group:execute()
    return exec_view(self)
end

-- run a modal window (dialog)
function Group:exec_view(window)
    return exec_view(window, self, true)
end

-- drawing interface
function Group:draw_window()
    -- draw sub windows
    self:for_each(function(w)
        if (w.state.visible) then
            w:draw_window()
        end
    end)
end

local function draw_child(group, window)
    -- bounds check, etc etc, draw child in pad
    local gw = group.size.x
    local gh = group.size.y
    local scroll = group.scroll
    local r = window:bounds()
    local sx = r.sx - scroll.x; sx = sx > 0 and 0 or -sx
    local sy = r.sy - scroll.y; sy = sy > 0 and 0 or -sy

    r:move(-scroll.x, -scroll.y):intersect(Rect {0, 0, gw, gh})

    if (r.ex > r.sx and r.ey > r.sy) then
        -- log ('draw child ' .. window._tag .. ' in ' .. group._tag .. ' -> ' .. r)
        -- log ('-> ' .. group._tag ..','..sy..','..sx..','..r.sy..','..r.sx..','..(r.ey-1)..','..(r.ex-1))
        window._window:copy(group._window, sy, sx, r.sy, r.sx, r.ey-1, r.ex-1)
    else
        -- log ('SKIP draw child ' .. window._tag .. ' in ' .. group._tag .. ' -> ' .. r)
    end
end

function Group:redraw(onparent)
    self:lock()

    -- redraw sub windows
    self:for_each(function(w)
        if (w.state.visible) then
            -- cause groups to repaint
            w:redraw(false)
            -- draw sub window on personal window
            draw_child(self, w)
        end
    end)
    View.redraw(self, onparent)

    self:unlock()
end

function Group:refresh()
    self:lock()

    -- repaint
    self:draw_window()
    -- refresh sub windows
    self:redraw(true)

    self:unlock()
end

-- private
function Group:draw_child(window)
    self:lock()
    local first = self._first
    local bounds = window:bounds()
    local w = window
    if (w._full_redraw) then
        w._full_redraw = nil
        w = self._first
    end
    repeat
        -- check for overlapping areas
        if w.state.visible and not w:bounds():intersect(bounds):empty() then
            draw_child(self, w)
            -- if they overlap, join them. use the resulting rectangle
            -- to check for overlapping areas on the following windows
            bounds:union(w._bounds)
        end

        w = w._next
    until w == first
    self:unlock()
end

--[[ window state ]-------------------------------------------------------]]

function Group:set_state(state, enable)
    View.set_state(self, state, enable)

    if (state == 'focused') then
        if (self._current) then
            self._current:set_state(state, enable)
        end
    end
end


--[[ window selection ]---------------------------------------------------]]
function Group:select_next(forward, start, send_to_back)
    if (not self._first) then return end

    local current = start or self._current or self._first
    if (forward) then
        local next = current._next
        while (next ~= current) do
            if (next.options.selectable and next.state.visible) then
                self:select(next, send_to_back)
                break
            end
            next = next._next
        end
    else
        local next = current._previous
        while (next ~= current) do
            if (next.options.selectable and next.state.visible) then
                self:select(next, true)
                break
            end
            next = next._previous
        end
    end
end

function Group:select(child, send_to_back)
    assert(child == nil or (child.parent == self and child.options.selectable))
    local current = self._current

    if (child == current) then return end

    if (current) then
        if (self.state.focused) then
            current:set_state('focused', false)
        end
        current:set_state('selected', false)

        if (current.options.top_select and send_to_back) then
            -- send current view to the back of the list
            local first = self._first
            local next
            if (first.options.selectable) then
                next = nil
            else
                next = first
                while (next ~= first._previous and not next.options.selectable) do
                    next = next._next
                end
            end

            if (current ~= next) then
                remove_view(self, current)
                insert_view(self, current, next)
            end
        end
    end

    self._current = child

    if (child) then
        if (child.options.top_select) then
            remove_view(self, child)
            insert_view(self, child, self._first)
        end

        child:set_state('selected', true)
        if (self.state.focused) then
            child:set_state('focused', true)
        end
    end
end


--[[ data get/set ]-------------------------------------------------------]]
function Group:get_data(data)
    self:for_each(function(w)
        w:get_data(data)
    end)
end

function Group:set_data(data)
    self:for_each(function(w)
        w:set_data(data)
    end)
end

-- exports
_M.Group = Group
