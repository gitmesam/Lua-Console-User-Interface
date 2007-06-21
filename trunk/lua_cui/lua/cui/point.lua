
local type = type

module('cui')

--[=[
Object: Point

Members:
    x - the x coordinate (column)
    y - the y coordinate (row)

Derived From:
    Object

See Also:
    <Rect>
--]=]

local Point = Object{
   _init = { "x"; "y" },
}

--[=[
Method: addxy

Arguments:
    x - x delta
    y - y delta
--]=]
function Point:addxy(x, y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

function Point:add(p)
    return self:addxy(p.x, p.y)
end

function Point:subxy(x, y)
    return self:addxy(-x, -y)
end

function Point:sub(p)
    return self:addxy(-p.x, -p.y)
end

function Point:__add(p)
    local np = self()
    np.x = np.x + p.x
    np.y = np.y + p.y
    return np
end

function Point:__sub(p)
    local np = self()
    np.x = np.x - p.x
    np.y = np.y - p.y
    return np
end

function Point:__unm()
    local p = self()
    p.x = -p.x
    p.y = -p.y
    return p
end

function Point:__eq(p)
    return self.x == p.x and self.y == p.y
end


function Point:__tostring()
    return '(' .. self.x .. ',' .. self.y .. ')'
end

function Point.__concat(op1, op2)
    if type(op1) == 'string' then
        return op1 .. op2:__tostring()
    elseif type(op2) == 'string' then
        return op1:__tostring() .. op2
    else
        return op1:__tostring() .. op2:__tostring()
    end
end

-- exports
_M.Point = Point
