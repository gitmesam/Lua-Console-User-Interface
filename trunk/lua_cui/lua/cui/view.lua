--[[ Base window object ]---------------------------------------------------
tview private members:
    tview._tag          -- internal/debug

    tview._bounds       -- trect
    tview._cursor       -- tpoint
    tview._window       -- curses window
    tview._full_redraw  -- [used internaly for drawing operations]
    tview._next
    tview._previous

tview public members:
    tview.size      -- tpoint

    -- flags
    tview.state.visible
    tview.state.cursor_visible
    tview.state.block_cursor
    tview.state.selected
    tview.state.focused
    tview.state.disabled
    tview.state.modal

    -- grow flags
    tview.grow.lox
    tview.grow.loy
    tview.grow.hix
    tview.grow.hiy

    -- options
    tview.options.selectable
    tview.options.top_select
    tview.options.pre_event
    tview.options.post_event
    tview.options.centerx
    tview.options.centery
    tview.options.validate

    -- event mask - wich commands to process
    tview.event[type]


tview methods:
    tview:tview(bounds)
    tview:close()
    tview:set_bounds(bounds)
    tview:bounds()          -- return _bounds:clone()
    tview:size_limits()     -- return tpoint, tpoint
    tview:calc_bounds(delta)    -- return trect
    tview:change_bounds(bounds)
    tview:handle_event(event)
    tview:get_event(event)
    tview:put_event(event)
    tview:is_valid(data)
    tview:end_modal(data)
    tview:window()
    tview:draw_window()
    tview:refresh()
    tview:redraw(onparent)
    tview:lock()
    tview:unlock()
    tview:goto(x, y)
    tview:cursor()  -- return tpoint
    tview:reset_cursor()
    tview:show(visible)
    tview:set_state(state_name, enable)
    tview:get_data(table)
    tview:set_data(table)
--------------------------------------------------------------------------]]

require 'cui'
module 'cui'

local cursor_visibility         -- cursor state
local cursor = Point { 0, 0 }   -- cursor position in screen
local screen_lock = 0           -- screen lock/update counter
local min, max = math.min, math.max

--[=[
Object: View
    base class.

About:
    Base class.

--]=]

View = Object{}

local _tag_num = 0

-- construction helper
function View:create(...)
    local v = self()
    v:initialize(...)
    return v
end

-- constructor
function View:initialize(bounds)
    assert(type(bounds) == 'table')

    -- flags
    self.state = Object{}
    self.state.visible          = false     -- window visibility
    self.state.cursor_visible   = false     -- cursor visibility
    self.state.block_cursor     = false     -- block cursor
    self.state.selected         = false     -- current selected window inside group
    self.state.focused          = false     -- true if parent is also focused
    self.state.disabled         = false     -- window state
    self.state.modal            = false     -- modal window

    -- grow flags
    self.grow = Object{}
    self.grow.lox               = false     --
    self.grow.loy               = false     --
    self.grow.hix               = false     --
    self.grow.hiy               = false     --

    -- options
    self.options = Object{}
    self.options.selectable     = false     -- true if window can be selected
    self.options.top_select     = false     -- if true, selecting window will bring it to front
    self.options.pre_event      = false     -- receive event before focused window
    self.options.post_event     = false     -- receive event after focused window
    self.options.centerx        = false     -- center horizontaly when inserting in parent
    self.options.centery        = false     -- center verticaly when inserting in parent
    self.options.validate       = false     -- validate

    -- event mask - wich commands to process
    self.event = Object{}

    -- cursor coords
    self._cursor = Point{0, 0}

    -- pad creation
    self:set_bounds(bounds)

    -- debug helper
    self._tag = _tag_num
    _tag_num = _tag_num + 1
end

function View:close()
    if (self.parent) then
        self.parent:remove(self)
    end
    self._window:close()
    self._window = nil
end

-- set window bounds
function View:set_bounds(bounds)
    --assert(bounds.s.x >= 0 and bounds.s.y >= 0)
    --assert(bounds.e.x > bounds.s.x and bounds.e.y > bounds.s.y)

    if (self._window) then
        self._window:close()
    end

    self._bounds = bounds()
    self.size = bounds:size()
    local s = self.size

    self._window = curses.new_pad(s.y > 0 and s.y or 1, s.x > 0 and s.x or 1)
    self._window:leaveok(true)
    self._full_redraw = true
end

function View:bounds()
    return self._bounds()
end

function View:size_limits()
    return Point{1, 1}, Point{1000, 1000}
end

function View:calc_bounds(delta)
    local bounds = self:bounds()
    local g = self.grow

    if (self.grow.lox) then bounds:moves(delta.x, 0) end
    if (self.grow.hix) then bounds:movee(delta.x, 0) end

    if (self.grow.loy) then bounds:moves(0, delta.y) end
    if (self.grow.hiy) then bounds:movee(0, delta.y) end

    local minl, maxl = self:size_limits()
    bounds.ex = bounds.sx + range(bounds.ex-bounds.sx, minl.x, maxl.x)
    bounds.ey = bounds.sy + range(bounds.ey-bounds.sy, minl.y, maxl.y)

    return bounds
end

function View:change_bounds(bounds)
    self:set_bounds(bounds)
    self:refresh()
end

-- abstract function -- handle an event
function View:handle_event(event)
end

function View:get_event()
    return self.parent and self.parent:get_event()
end

function View:put_event(event)
    return self.parent and self.parent:put_event(event)
end

function View:is_valid(data)
    return true
end

function View:end_modal(data)
    -- try to find modal window, else, use the top window
    local w = self
    while (not w.state.modal and w.parent) do
        w = w._next
    end
    if (not w.state.modal) then
        w = self
    end
    if (w:is_valid(data)) then
        w.modal_state = data
    end
end

function View:window()
    return self._window
end

-- return the focused window
local function top_window()
    local w = app
    while (w._current) do
        w = w._current
    end
    return w
end

local function update_screen()
    if (app and app.state.visible) then
        local main_window = curses.main_window()

        --io.stderr:write(_TRACEBACK('update screen'), '\n')

        -- update screen
        app._window:copy(main_window, 0, 0, 0, 0, app.size.y-1, app.size.x-1)

        local topw = top_window()
        local cvis

        if (not topw.state.cursor_visible) then
            cvis = 0
        elseif (topw.state.block_cursor) then
            cvis = 2
        else
            cvis = 1
        end

        local cursor = topw:cursor()
        local tcursor
        if (cvis ~= 0) then
            local w = topw
            while (w.parent) do
                -- make update coords
                cursor:addxy(w._bounds.sx, w._bounds.sy)
                cursor:sub(w.parent.scroll)

                -- is cursor visible?
                if (cursor.x < 0 or cursor.y < 0 or cursor.x >= w.parent.size.x or cursor.y >= w.parent.size.y) then
                    cvis = 0
                    break
                end
                w = w.parent
            end

        end

        if (cursor_visibility ~= cvis) then
            cursor_visibility = cvis;
            curses.cursor_set(cvis)
        end
        if (cvis ~= 0) then
            main_window:move(cursor.y, cursor.x)
        else
            main_window:move(app.size.y-1, app.size.x-1)
        end
        main_window:noutrefresh()

        curses.doupdate()
    end
end

function View:unlock()
    assert(screen_lock > 0)
    screen_lock = screen_lock - 1
    if (screen_lock == 0) then
        update_screen()
    end
end

--
function View:draw_window()
    self:window():clear()
end

-- print self in parent window
function View:refresh()
    self:draw_window()
    self:redraw(true)
end

function View:redraw(onparent)
    if (onparent and self.parent) then
        self:lock()
        local w = self
        while (w.parent) do
            w.parent:draw_child(w)
            w = w.parent
        end
        self:unlock()
    end
end


function View:lock()
    screen_lock = screen_lock + 1
end

--[[ cursor handling ]----------------------------------------------------]]

-- move cursor
function View:goto(x, y)
    self._cursor = Point{range(0, x, self.size.x-1), range(y, 0, self.size.y-1)}
end

function View:cursor()
    return self._cursor()
end

function View:reset_cursor()
    self:lock()
    self:unlock()
end


--[[ window state ]-------------------------------------------------------]]

function View:show(visible)
    if (self.state.visible ~= visible) then
        self:set_state('visible', visible)
    end
end

function View:set_state(state, enable)
    enable = enable or false
    self.state[state] = enable
    if (state == 'visible') then
        self._full_redraw = true
        self:redraw(true)
    elseif (state == 'selected') then
        message(self.parent, BroadcastEvent{Event.be_selected, { window = self, enable = enable }})
    elseif (state == 'focused') then
        message(self.parent, BroadcastEvent{Event.be_focused, { window = self, enable = enable }})
        self:reset_cursor()
    elseif (state == 'cursor_visible') then
        self:reset_cursor()
    elseif (state == 'block_cursor' and self.state.cursor_visible) then
        self:reset_cursor()
    end
end

--[[ data get/set ]-------------------------------------------------------]]
function View:get_data(data)
end

function View:set_data(data)
end

