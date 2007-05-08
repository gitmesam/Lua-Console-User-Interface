
module('cui')

--[[ Basic Event class ]----------------------------------------------------
Members:
    tevent.type
    tevent.command
    tevent.extra
Other:
    message(receiver, type, command, extra)
--------------------------------------------------------------------------]]

--[=[
Object: Event
--]=]
Event = Object{
    _init = { "type", "command", "extra" }
}

-- event types
enum(Event, {
    'ev_keyboard',
    'ev_mouse',
    'ev_command',
    'ev_broadcast',
    'ev_idle',
    'ev_max'
})

-- Events
KeyboardEvent = Object{
    -- keyname = key name
    -- keycode = key code
    -- keymeta = ALT key was pressed
    _init = { "key_code", "key_name", "key_meta" },
    type = Event.ev_keyboard,
}
MouseEvent = Object {
    _init = {},
    type = Event.ev_mouse,
}
CommandEvent = Object{
    _init = { "command", "extra" },
    type = Event.ev_command,
}
BroadcastEvent = Object{
    _init = { "command", "extra" },
    type = Event.ev_broadcast,
}
IdleEvent = Object{
    _init = {},
    type = Event.ev_idle,
}

--[[ Event defines ]--------------------------------------------------------
enumerated *constants*
--------------------------------------------------------------------------]]
-- known command event (ev_command)
enum(Event, {
    -- application
    'cm_quit',      -- quit application

    -- window
    'cm_prev',      -- previous window
    'cm_next',      -- next window
    'cm_new',       -- new window
    'cm_close',     -- close window

    -- general commands
    'cm_ok',
    'cm_cancel',
    'cm_yes',
    'cm_no',

    -- view selection TODO
    'cm_leave',     -- unselect view
    'cm_enter',     -- select view

    --
    'cm_max'
})
-- known broadcast events (ev_broadcast)
enum(Event, {
    -- view
    'be_selected',  -- after select view
    'be_focused',   -- after focus view

    -- window
    'be_resize',    -- resize window
    'be_select_window_number',  -- send to select window number

    -- scroll bar
    'be_scrollbar_changed', -- extra = scrollbar

    --
    'be_max'
})
--  known keyboard events (ev_keyboard)
enum(Event, { 'ke_max' })


--[=[
Function: message
    Send an event to a <View>.

Arguments:
    receiver - <View> to which the event will be sent to
    event - the <Event> to send

Returns:
    The value of *event.result* after the event has been handled.
    It is up to the *receiver* to set that value.
--]=]
function message(receiver, event)
    if (receiver) then
        receiver:handle_event(event)
        return event.result
    end
end

