
local min, max = math.min, math.max
local type = type

module('cui')

--[=[
Object: Rect

Members:
    sx - the left most column
    sy - the top most row
    ex - the right most column
    ey - the bottom most column

See Also:
    <Point>
--]=]
local Rect = Object{
    _init = { "sx", "sy", "ex", "ey" }
}

--[=[
Method: size
    Get the rect size.

Returns:
    <Point> value with the rect dimensions
--]=]
function Rect:size()
    return Point {
        self.ex - self.sx,
        self.ey - self.sy
    }
end

-- @func Rect:__len: get rect size
-- @returns
--   @param Point with area size
function Rect:__len()
    return self:size()
end

-- @func Rect:move: move the rect
--   @param deltax: x delta
--   @param deltay: y delta
-- @returns
--    @param self
function Rect:move(deltax, deltay)
    self.sx = self.sx + deltax
    self.sy = self.sy + deltay
    self.ex = self.ex + deltax
    self.ey = self.ey + deltay
    return self
end

-- @func Rect:move: move top right corner of the rect
--   @param deltax: x delta
--   @param deltay: y delta
-- @returns
--    @param self
function Rect:moves(deltax, deltay)
    self.sx = self.sx + deltax
    self.sy = self.sy + deltay
    return self
end

-- @func Rect:move: move bottom left corner of the rect
--   @param deltax: x delta
--   @param deltay: y delta
-- @returns
--    @param self
function Rect:movee(deltax, deltay)
    self.ex = self.ex + deltax
    self.ey = self.ey + deltay
    return self
end

-- @func Rect:grow: expand rect area
--   @param delta: Point object
-- @returns
--   @param self
function Rect:grow(deltax, deltay)
    self.sx = self.sx - deltax
    self.sy = self.sy - deltay
    self.ex = self.ex + deltax
    self.ey = self.ey + deltay
    return self
end

-- @func Rect:intersect: set rect with shared area between this rect and a given rect
--   @param r: Rect object
-- @returns
--   @param self
function Rect:intersect(r)
    self.sx = max(self.sx, r.sx)
    self.sy = max(self.sy, r.sy)
    self.ex = min(self.ex, r.ex)
    self.ey = min(self.ey, r.ey)
    return self
end

-- @func Rect:intersect: get rect with shared area between two rects
--   @param r: Rect object
-- @returns
--   @param new rect object
function Rect:__div(r)
    return self():intersect(r)
end

function Rect:union(r)
    self.sx = min(self.sx, r.sx)
    self.sy = min(self.sy, r.sy)
    self.ex = max(self.ex, r.ex)
    self.ey = max(self.ey, r.ey)
    return self
end

function Rect:__concat(r)
    return self():union(r)
end

function Rect:__eq(r)
    return
        self.sx == r.sx and
        self.sy == r.sy and
        self.ex == r.ex and
        self.ey == r.ey
end

function Rect:contains(x, y)
    return x >= self.sx and x < self.ex and y >= self.sy and y < self.ey
end

function Rect:empty()
    return self.sx >= self.ex or self.sy >= self.ey
end

function Rect:notempty()
    return not self:empty()
end

function Rect:__tostring()
    if self:empty() then
        return '[empty]'
    end
    return '[(' .. self.sx .. ',' .. self.sy .. '),(' .. self.ex .. ',' .. self.ey .. ')]'
end

function Rect.__concat(op1, op2)
    if type(op1) == 'string' then
        return op1 .. op2:__tostring()
    elseif type(op2) == 'string' then
        return op1:__tostring() .. op2
    else
        return op1:__tostring() .. op2:__tostring()
    end
end

-- exports
_M.Rect = Rect
