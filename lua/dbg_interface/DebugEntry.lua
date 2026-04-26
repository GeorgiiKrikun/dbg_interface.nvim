local DebugEntry = {}
DebugEntry.__index = DebugEntry

function DebugEntry:_init(kwargs)
  kwargs = kwargs or {}

  self.prog = kwargs.prog or kwargs[1] or ""
  self.args = kwargs.args or kwargs[2] or ""
  self.type = kwargs.type or kwargs[3] or ""
  self.name = kwargs.name or self.prog .. " " .. self.args
  self.timestamp = kwargs.timestamp or os.time()
end

-- 2. The Constructor
function DebugEntry:new(kwargs)
  local instance = setmetatable({}, self)
  instance:_init(kwargs)
  return instance
end

function DebugEntry.from_table(tbl)
  return DebugEntry:new{
    prog = tbl.prog,
    args = tbl.args,
    type = tbl.type,
    name = tbl.name or (tbl.prog .. " " .. tbl.args),
    timestamp = tbl.timestamp
  }
end

function DebugEntry:__lt(other)
  return self.timestamp < other.timestamp
end

function DebugEntry:__eq(other)
  return self.prog == other.prog and self.args == other.args and self.type == other.type
end

function DebugEntry:__tostring()
  return "DebugEntry(name = " .. self.name .. "; type = " .. self.type .. "; prog=" .. self.prog .. "; args=" .. self.args .. ")"
end

function DebugEntry.__concat(op1, op2)
  if type(op1) == "string" then
    return op1 .. tostring(op2)
  elseif type(op2) == "string" then
    return tostring(op1) .. op2
  end
end

function DebugEntry:cmd()
  return vim.trim(self.prog .. " " .. self.args)
end


return DebugEntry
