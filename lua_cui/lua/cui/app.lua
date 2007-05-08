--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: app.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

-- dependencies
require 'cui'
require 'cui/menubar'
require 'cui/statusbar'
require 'cui/desktop'

module 'cui'

--[[ tapp ]-----------------------------------------------------------------

* what can be accessed after initialization
cui.app
cui.app.menu_bar
cui.app.menu_bar
cui.app.desktop
cui.app.desktop.background

--]]------------------------------------------------------------------------
App = Program()

function App:initialize()
    Program.initialize(self)

    -- framework interface
    self.status_bar = self:init_statusbar()
    self.menu_bar = self:init_menubar()
    self.desktop = self:init_desktop()

    if (self.status_bar) then   self:insert(self.status_bar) end
    if (self.menu_bar) then     self:insert(self.menu_bar)   end
    if (self.desktop) then      self:insert(self.desktop)    end
end

function App:init_statusbar()
    return Statusbar:create(Rect{0, self.size.y - 1, self.size.x, self.size.y},
        {
            --Key           Description     Event type      Event command   Visible
            { "AltX",       "Exit",         "ev_command",   "cm_quit",      true  },
        }
    )
end

function App:init_menubar()
    return Menubar:create(Rect{0, 0, self.size.x, 1})
end

function App:init_desktop()
    return Desktop:create(Rect{0, 1, self.size.x, self.size.y - 1})
end

function App:handle_event(event)
    Program.handle_event(self, event)

    if (event.type == Event.ev_command and event.command == Event.cm_quit) then
        self:end_modal(Event.cm_quit)
    elseif (event.type == Event.ev_keyboard) then
        local key = event.key_name
        if (key == "AltX") then
            self:end_modal(Event.cm_quit)
        elseif (key == "CtrlL") then
            self:refresh()
        end
    end
end
