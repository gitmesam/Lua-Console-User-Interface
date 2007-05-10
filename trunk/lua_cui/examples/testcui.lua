require 'cui'
require 'cui/ctrls'

local curses = cui.curses
local Event = cui.Event
local View = cui.View
local Listbox = cui.Listbox
local Rect = cui.Rect
local Window = cui.Window
local App = cui.App

local color_pair = cui.color_pair

local myview = View()

function myview:initialize(bounds, s)
    View.initialize(bounds)

    -- options
    self.options.selectable = true
    self.options.validate = true
    -- event mask
    self.event[Event.ev_keyboard] = true
    -- grow
    self.grow.hix = true
    self.grow.hiy = true
    -- state
    self:setstate('cursor_visible', true)

    -- members
    self.str = ''
end

function myview:draw_window()
    local w = self:window()
    local attr = color_pair(curses.COLOR_WHITE, curses.COLOR_BLUE)
    local line = curses.new_chstr(self.size.x)
    line:set_str(0, ' ', attr, self.size.x)
    for l = 0, self.size.y - 1 do
        w:mvaddchstr(l, 0, line)
    end
    w:attrset(attr)
    w:mvaddstr(0, 0, self.str)
end

function myview:handle_event(event)
    if (event.type == Event.ev_keyboard) then
        if (event.key == 'x') then
            cui.message(cui.app, Event.ev_command, Event.cm_quit)
        elseif (event.key == "Insert") then
            self:set_state('block_cursor', not self.state.block_cursor)
            self.focus = not self.focus
        elseif (event.key == "F1") then
            self:set_state('cursor_visible', not self.state.cursor_visible)
        elseif (event.key == "Down") then
            local c = self:cursor():add(0, 1)
            self:goto(c.x, c.y)
            self:resetcursor()
        elseif (event.key == "Up") then
            local c = self:cursor():add(0, -1)
            self:goto(c.x, c.y)
            self:resetcursor()
        elseif (event.key == "Left") then
            local c = self:cursor():add(-1, 0)
            self:goto(c.x, c.y)
            self:resetcursor()
        elseif (event.key == "Right") then
            local c = self:cursor():add(1, 0)
            self:goto(c.x, c.y)
            self:resetcursor()
        else
            self.str = self.str .. " " .. event.key
            if (event.key == "Esc") then
                self.str = ''
            end
            self:refresh()
        end
    end
end

function myview:isvalid(command)
    if (command == Event.cm_quit) then
        --return false
    elseif (command == Event.cm_release_focus and self.focus) then
        return false
    end
    return true
end

local mylistbox = Listbox()

function mylistbox:initialize(bounds, columns, count, sbar)
    Listbox.initialize(self, bounds, columns, { n = count }, sbar)

    --
    self.options.single_selection = false
end

function mylistbox:get_str(item, width)
    if (item > 0 and item <= #self.list) then
        local str = tostring(item)
        return string.sub(item..string.rep(' ', width), 1, width)
    else
        return string.rep(' ', width)
    end
end

function mylistbox:selected(item)
    --return math.mod(item, 4) == 2
    return self.list[item]
end

function mylistbox:select_item(item, select)
    self.list[item] = select
end

keylog = Listbox()

function keylog:initialize(bounds, sbar)
    Listbox.initialize(self, bounds, 1, {{"begin..."}}, sbar)

    self.event[Event.ev_keyboard] = true
end

function keylog:handle_event(event)
    if event.type == Event.ev_keyboard then
        local log = self.list
        local code = event.key_code or '(none)'
        local name = event.key_name or '(noname)'
        local meta = event.key_meta and 'true' or 'false'
        log[#log+1] = {
            'code: ' .. code .. ', name: ' .. name .. ', meta: ' .. meta,
            false
        }
        self:set_position(#log)
        self:refresh()
    else
        Listbox.handle_event(self, event)
    end
end

function keylog:_draw_window()
    local w = self:window()
    local width, height = self.size.x, self.size.y
    local line = curses.new_chstr(width)
    local log = self.log
    local s
    local attr = color_pair(curses.COLOR_BLUE, curses.COLOR_WHITE)

    for i = 0, i < height do
        s = log[#log - i - 1]

        line:set_str(0, ' ', attr, width)
        line:set_str(0, s, attr)
        w:mvaddchstr(i, 0, line)
    end
end

mywindow = Window()

function mywindow:initialize(bounds, title, num)
    Window.initialize(self, bounds, title, num)

    self:insert(
        cui.Edit:create(
            cui.Rect{1, 1, self.size.x - 1, 2},
            'wefwefwefwef398493849',
            100,
            false
        )
    )
    local sbar = cui.Scrollbar:create(cui.Rect{self.size.x-2, 2, self.size.x-1, self.size.y-1}, 15, 3)
    self:insert(
        keylog:create(
            cui.Rect{1, 2, self.size.x-2, self.size.y-1},  -- bounds
            sbar    -- scrollbar
        )
    )
    self:insert(sbar)
    self:insert(cui.Button:create(cui.Rect{5, self.size.y - 1, 5 + 11, self.size.y}, 'Close', Event.cm_close))
    self:select_next(true)
end


local myblock = View()

function myblock:draw_window()
    local d = color_pair(curses.COLOR_WHITE, curses.COLOR_BLACK)
    if true and false then return end

    local w = self:window()
    local ch = 0

    math.randomseed(os.time())
    local str = curses.new_chstr(self.size.x)
    for l = 0, self.size.y - 1 do
        for c = 0, self.size.x - 1 do
            str:set_ch(c, ch, d*math.random(0,1) + curses.A_BOLD*math.random(0,1))
            ch = (ch == 255) and 0 or (ch + 1)
        end
        w:mvaddchstr(l, 0, str)
    end
end

local MyDesktop = cui.Desktop()

function MyDesktop:init_background()
    return myblock:create(Rect{0, 0, self.size.x, self.size.y})
end

local myapp = App()

function myapp:initialize()
    App.initialize(self)

    local desk = self.desktop

    -- insert the clock
    self:insert(cui.Clock:create(cui.Rect{self.size.x-8, 0, self.size.x, 1}))
    -- insert memory information
    self:insert(cui.Memory:create(cui.Rect{self.size.x-20, self.size.y-1, self.size.x, self.size.y}))

---[[
    local r = cui.Rect{1, 1, 70, 20}
    desk:insert(cui.Window:create(r, 'Window 1', 1))
    r:move(2, 2) desk:insert(cui.Window:create(r, 'Window 2', 2))
    r:move(2, 2) desk:insert(cui.Window:create(r, 'Window 3', 3))
    r:move(2, 2) desk:insert(cui.Window:create(r, 'Window 4', 4))
    r:move(2, 2) desk:insert(cui.Window:create(r, 'Window 5', 5))
    r:move(5, 5) desk:insert(mywindow:create(r, 'Window 6', 6))
--]]
end

function myapp:init_desktop()
    return MyDesktop:create(Rect{0, 1, self.size.x, self.size.y - 1})
end

function myapp:init_menubar()
    return cui.Menubar:create(cui.Rect{0, 0, self.size.x, 1})
end

local r = cui.Rect{1, 1, 40, 15}
local window_number = 1
function myapp:handle_event(event)
    App.handle_event(self, event)

    if (event.type == Event.ev_command and event.command == Event.cm_new) then
        self.desktop:insert(cui.Window:create(r, 'Window', window_number))
        r:move(2, 2) window_number = window_number + 1
    end
end

function myapp:init_statusbar()
    return cui.Statusbar:create(cui.Rect{0, self.size.y - 1, self.size.x, self.size.y},
        {
        --    Key           Description     Event type      Event command   Show
            { "AltX",       "Exit",         "ev_command",   "cm_quit",      true    },
            { "F3",         "New",          "ev_command",   "cm_new",       true    },
            { "F4",         "Close",        "ev_command",   "cm_close",     true    },
            { "F6",         "Previous",     "ev_command",   "cm_prev",      true    },
            { "F7",         "Next",         "ev_command",   "cm_next",      true    },
        }
    )
end

local app
local function run()
    app = myapp:create()
    app:run()
    app:close()
end

local ok, msg = xpcall(run, debug.traceback)

if (not ok) then
    if (not curses.isdone()) then
        curses.done()
    end
    print(msg)
end
