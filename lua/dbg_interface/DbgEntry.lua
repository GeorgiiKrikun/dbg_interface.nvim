local DbgEntry = {}
DbgEntry.__index = DbgEntry

function DbgEntry:_init(kwargs)
  kwargs = kwargs or {}
  
  self.target = kwargs.target
  self.args = kwargs.args
  self.type = kwargs.type or kwargs[3] or ""
  self.name = kwargs.name or self.prog .. " " .. self.args
  self.timestamp = kwargs.timestamp or os.time()
end

-- 2. The Constructor
function DbgEntry:new(kwargs)
  local instance = setmetatable({}, self)
  instance:_init(kwargs)
  return instance
end

function DbgEntry.from_table(tbl)
  return DbgEntry:new{
    prog = tbl.prog,
    args = tbl.args,
    type = tbl.type,
    name = tbl.name or (tbl.prog .. " " .. tbl.args),
    timestamp = tbl.timestamp
  }
end

function DbgEntry:__lt(other)
  return self.timestamp < other.timestamp
end

function DbgEntry:__eq(other)
  return self.prog == other.prog and self.args == other.args and self.type == other.type
end

function DbgEntry:__tostring()
  return "DbgEntry(name = " .. self.name .. "; type = " .. self.type .. "; prog=" .. self.prog .. "; args=" .. self.args .. ")"
end

function DbgEntry.__concat(op1, op2)
  if type(op1) == "string" then
    return op1 .. tostring(op2)
  elseif type(op2) == "string" then
    return tostring(op1) .. op2
  end
end

function DbgEntry:cmd()
  return vim.trim(self.prog .. " " .. self.args)
end


return DbgEntry

