
local setmetatable, getmetatable = setmetatable, getmetatable
local pairs = pairs

module('cui')

--[=[
Object: Object

About:
    Taken from 'std' library: http://luaforge.net/projects/stdlib/

Usage:
  > Create an object/class:
  >   object/class = parent {value, ...; field = value ...}
  >   An object's metatable is itself.
  >   In the initialiser, unnamed values are assigned to the fields
  >   given by _init (assuming the default _clone).
  >   Private fields and methods start with "_"
  >
  > Access an object field: object.field
  > Call an object method: object:method (...)
  > Call a class method: class.method (self, ...)
  >
  > Add a field: object.field = x
  > Add a method: function object:method (...) ... end
--]=]

-- @func permute: Permute some indices of a table
--   @param p: table {oldindex=newindex ...}
--   @param t: table to permute
-- @returns
--   @param u: permuted table
local function permute (p, t)
  local u = {}
  for i, v in pairs (t) do
    if p[i] ~= nil then
      u[p[i]] = v
    else
      u[i] = v
    end
  end
  return u
end

-- @func clone: Make a shallow copy of a table, including any
-- metatable
--   @param t: table
-- @returns
--   @param u: copy of table
local function clone (t)
  local u = setmetatable ({}, getmetatable (t))
  for i, v in pairs (t) do
    u[i] = v
  end
  return u
end

-- @func merge: Merge two tables
-- If there are duplicate fields, u's will be used. The metatable of
-- the returned table is that of t
--   @param t, u: tables
-- @returns
--   @param r: the merged table
local function merge (t, u)
  local r = clone (t)
  for i, v in pairs (u) do
    r[i] = v
  end
  return r
end


-- Root object
local Object = {
  -- List of fields to be initialised by the
  -- constructor: assuming the default _clone, the
  -- numbered values in an object constructor are
  -- assigned to the fields given in _init
  _init = {},
}
setmetatable (Object, Object)

-- @func Object:_clone: Object constructor
--   @param values: initial values for fields in
--   _init
-- @returns
--   @param object: new object
function Object:_clone (values)
  local object = merge(self, permute(self._init, values or {}))
  return setmetatable (object, object)
end

--- Group: metamethods

--- Method: call
---     Sugar instance creation
function Object.__call (...)
  return (...)._clone (...)
end

-- exports
_M.Object = Object
