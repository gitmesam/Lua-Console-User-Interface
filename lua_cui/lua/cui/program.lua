
require 'cui'
module 'cui'

--[[ tprogram ]-------------------------------------------------------------

tprogram: tgroup

Members:
    tprogram

Methods:
    tprogram:tprogram()
    tprogram:close()
    tprogram:set_bounds(bounds)
    tprogram:run()
    tprogram:get_event()
    tprogram:put_event()
--------------------------------------------------------------------------]]
local main_window
local event_queue = {}          -- event queue
local key_map
local key_translate

Program = Group{}

-- create main window group - should be the only group without a parent
function Program:initialize()
    -- curses initialization
    main_window = curses.init()
    curses.echo(false)
    curses.cbreak(true)
    curses.nl(false)
    curses.map_output(true)
    curses.map_keyboard(true)
    if (curses.has_colors()) then curses.start_color() end
    init_keymap()

    -- main window will be used to set the screen cursor and to handle
    -- keyboard events
    main_window:leaveok(false)
    main_window:keypad(true)
    main_window:nodelay(true)
    main_window:meta(true)
    --main_window:notimeout(true)

    --[[library initialization done]]

    -- set main view object
    app = self

    -- ancestor construction
    Group.initialize(self, Rect {0, 0, curses.columns(), curses.lines()})
    self:set_state('selected', true)
    self:set_state('focused', true)
end

function Program:close()
    -- dispose all windows
    Group.close(self)

    -- unset main view object
    app = nil

    --[[library finalization]]

    -- (attempt to) make sure the screen will be cleared
    -- if not restored by the curses driver
    main_window:clear()
    main_window:noutrefresh()
    curses.doupdate()
    assert(not curses.isdone())
    curses.done()
end

function Program:set_bounds(bounds)
    --if (bounds:equal(trect:new(0, 0, _cui.columns(), _cui.lines()))) then
        Group.set_bounds(self, bounds)
    --else
    --    error('can not set the main application bounds')
    --end
end

function Program:run()
    return self:execute()
end

function Program:get_event()
    -- check event queue
    local event = event_queue[1]
    if (event) then
        table.remove(event_queue, 1)
        return event
    end

    -- check keyboard
    local key_code, key_name, key_meta = get_key()
    if (key_code) then
        if (key_name == "Resize" or key_name == "CtrlL") then
            self:change_bounds(Rect{0, 0, curses.columns(), curses.lines()})
            self:refresh()
        elseif key_name == "Refresh" then
            self:refresh()
        else
            return KeyboardEvent{key_code, key_name, key_meta}
        end
    end

    -- nothing to return...
    -- return
end

function Program:put_event(event)
    table.insert(event_queue, event)
end


--[[ lookup table to translate keys to string names ]---------------------]]
-- this is the time limit in ms within Esc-key sequences are detected as
-- Alt-letter sequences. useful when we can't generate Alt-letter sequences
-- directly. sometimes this pause may be longer than expected since the
-- curses driver may also pause waiting for another key (ncurses-5.3)
local esc_delay = 400

function init_keymap()
    key_map =
    {
        -- ctrl-letter codes
        [ 1] = "CtrlA", [ 2] = "CtrlB", [ 3] = "CtrlC",
        [ 4] = "CtrlD", [ 5] = "CtrlE", [ 6] = "CtrlF",
        [ 7] = "CtrlG", [ 8] = "CtrlH", [ 9] = "CtrlI",
        [10] = "CtrlJ", [11] = "CtrlK", [12] = "CtrlL",
        [13] = "CtrlM", [14] = "CtrlN", [15] = "CtrlO",
        [16] = "CtrlP", [17] = "CtrlQ", [18] = "CtrlR",
        [19] = "CtrlS", [20] = "CtrlT", [21] = "CtrlU",
        [22] = "CtrlV", [23] = "CtrlW", [24] = "CtrlX",
        [25] = "CtrlY", [26] = "CtrlZ",

        [  8] = "Backspace",
        [  9] = "Tab",
        [ 10] = "Enter",
        [ 13] = "Enter",
        [ 27] = "Esc",
        [ 31] = "CtrlBackspace",
        [127] = "Backspace",

        [curses.KEY_DOWN        ] = "Down",
        [curses.KEY_UP          ] = "Up",
        [curses.KEY_LEFT        ] = "Left",
        [curses.KEY_RIGHT       ] = "Right",
        [curses.KEY_HOME        ] = "Home",
        [curses.KEY_END         ] = "End",
        [curses.KEY_NPAGE       ] = "PageDown",
        [curses.KEY_PPAGE       ] = "PageUp",
        [curses.KEY_IC          ] = "Insert",
        [curses.KEY_DC          ] = "Delete",
        [curses.KEY_BACKSPACE   ] = "Backspace",
        [curses.KEY_F1          ] = "F1",
        [curses.KEY_F2          ] = "F2",
        [curses.KEY_F3          ] = "F3",
        [curses.KEY_F4          ] = "F4",
        [curses.KEY_F5          ] = "F5",
        [curses.KEY_F6          ] = "F6",
        [curses.KEY_F7          ] = "F7",
        [curses.KEY_F8          ] = "F8",
        [curses.KEY_F9          ] = "F9",
        [curses.KEY_F10         ] = "F10",
        [curses.KEY_F11         ] = "F11",
        [curses.KEY_F12         ] = "F12",

        [curses.KEY_RESIZE      ] = "Resize",
        [curses.KEY_REFRESH     ] = "Refresh",

        [curses.KEY_BTAB        ] = "ShiftTab",
        [curses.KEY_SDC         ] = "ShiftDelete",
        [curses.KEY_SIC         ] = "ShiftInsert",
        [curses.KEY_SEND        ] = "ShiftEnd",
        [curses.KEY_SHOME       ] = "ShiftHome",
        [curses.KEY_SLEFT       ] = "ShiftLeft",
        [curses.KEY_SRIGHT      ] = "ShiftRight",
    }
end

function get_key()
    local ch = main_window:getch()
    if (not ch) then return end

    local alt = ch == 27

    if (alt) then
        ch = main_window:getch()
        if (not ch) then
            -- since there is no way to know the time with millisecond precision
            -- we pause the the program until we get a key or the time limit
            -- is reached
            local t = 0
            repeat
                ch = main_window:getch()
                if ch or t >= esc_delay then
                    break
                end

                curses.napms(0) t = t + 10
            until false
            -- nothing was typed... return Esc
            if (not ch) then return 27, "Esc", false end
        end
        if (ch > 96 and ch < 123) then ch = ch - 32 end
    end

    local k = key_map[ch]
    local key_name
    if (k) then
        key_name = alt and "Alt"..k or k
    elseif (ch < 256) then
        key_name = alt and "Alt"..string.char(ch) or string.char(ch)
    else
        return ch, '(noname)', alt
    end
    return ch, key_name, alt
end

function Program._test()
    local function run()
        log ('--------------------------------- test start')

        log 'define Program'

        local Prg = Program()

        function Prg:handle_event(event)
            Program.handle_event(self, event)
            if event.type == Event.ev_keyboard then
                self:end_modal(Event.cm_quit or CommandEvent.cm_quit)
            elseif event.type == Event.ev_idle then
                -- self:end_modal(true)
            end
        end

        log 'create View'
        local v = View{
            draw_window = function(self)
                log 'draw v'
                local w = self:window()
                w:mvaddstr(0, 0, 'hello')
                w:mvaddstr(1, 1, 'world')
            end
        }

        log 'create View'
        local w = View{
            draw_window = function(self)
                log 'draw w'
                local w = self:window()
                w:mvaddstr(0, 0, '!')
                w:mvaddstr(1, 1, '!')
            end
        }

        log 'create Prg'
        local prg = Prg:create()

        log 'insert v'
        prg:insert(v:create(Rect {0, 0, 5, 2}))
        log 'insert w'
        prg:insert(w:create(Rect {2, 2, 4, 4}))
        log 'run'
        prg:run()
        log 'close'
        prg:close()
        log 'test finished'
    end

    local ok, msg = xpcall(run, debug.traceback)

    if (not ok) then
        if (not curses.isdone()) then
            curses.done()
        end
        print(msg)
    end
end
