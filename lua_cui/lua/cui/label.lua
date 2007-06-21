--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id$
--------------------------------------------------------------------------]]

local rep, sub = string.rep, string.sub

require 'cui'
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
    self:set_text(text, attr, false)
end

function Label:set_text(text, attr, norefresh)
    self.text = text or ''
    self.attr = attr
    if not norefresh then
        self:refresh()
    end
end

function Label:draw_window()
    local c = self:canvas()
    local width = self.size.x
    local len = #self.text

    c:attr(self.attr):move(0, 0):write(sub(self.text, 1, width)..rep(' ', width-len), self.attr)
end
