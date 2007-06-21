--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: label.lua,v 1.2 2004/05/22 17:17:26 tngd Exp $
--------------------------------------------------------------------------]]

local tonumber = tonumber
local string = string

local curses = require 'cui.curses'

require 'cui.view'
module 'cui'

--[[ tlabel ]---------------------------------------------------------------
Members:
    tlabel.text
    tlabel.attr
Methods:
    tlabel:tlabel(bounds, text, attr)
    tlabel:set_text(text, attr)
    tlabel:draw_window()
--]]------------------------------------------------------------------------
Label = View()

function Label:initialize(bounds, text, attr)
    View.initialize(self, bounds)
    self:set_text(text, attr)
end

function Label:set_text(text, attr)
    self.text = text or ''
    self.attr = tonumber(attr) or curses.A_NORMAL
    self:refresh()
end

function Label:draw_window()
    local w = self:window()
    local width = self.size.x
    local str = curses.new_chstr(width)
    local len = #self.text

    str:set_str(0, string.sub(self.text, 1, width)..string.rep(' ', width-len), self.attr)
    w:mvaddchstr(0, 0, str)
end
