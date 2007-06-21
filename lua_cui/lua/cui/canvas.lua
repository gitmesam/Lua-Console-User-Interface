--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tiago.dionizio AT gmail.com)
$Id$
--------------------------------------------------------------------------]]

module('cui')

Canvas = Object()

function Canvas:create(view, window)
    -- create instance
    self = self()

    self._view = view
    self._window = window

    return self
end

function Canvas:get_window()
    return self._window
end

function Canvas:clear()
    self._window:clear()
    return self
end

function Canvas:move(x, y)
    self._window:move(y, x)
    return self
end

function Canvas:write(str, attr)
    self._window:addchstr(str, attr)
    return self
end

function Canvas:box(rect)

end
