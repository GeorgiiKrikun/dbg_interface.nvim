local Class = require('pl.class')
local Path = require('pl.path')
local stringx = require('pl.stringx')

local DebugEntry = Class() 

function DebugEntry:_init(kwargs)
  self.prog = kwargs.prog or ""
  self.args = kwargs.args or ""
  self.type = kwargs.type or ""
  self.timestamp = os.time()
end

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
  return "DebugEntry(type = " .. self.type .. "; prog=" .. self.prog .. "; args=" .. self.args .. ")"
end

function DebugEntry:cmd()
  return stringx.strip(self.prog .. " " .. self.args)
end

function DebugEntry.__concat(op1, op2)
  if type(op1) == "string" then
    return op1 .. tostring(op2)
  elseif type(op2) == "string" then
    return tostring(op1) .. op2
  end
end


-- Test stuff
function DebugEntry.test()
  local entry1 = DebugEntry:new{prog = "p1", args = "a1 a2", type = "t1"}
  os.execute("sleep 1") -- Simulate a delay to ensure different timestamps
  local entry2 = DebugEntry:new{prog = "p1", args = "a2 a3", type = "t1"}
  local entry3 = DebugEntry:new{"p2", "5 6"}
  assert(entry1 < entry2, "entry1 timestamp" .. entry1.timestamp .. " should be less than entry2 timestamp " .. entry2.timestamp)
  vim.notify("concaterate test " .. entry1 .. " test2", vim.log.levels.DEBUG)
end

function DebugEntry.reload()
  local current_file, _ = Path.splitext(Path.basename(debug.getinfo(1, "S").source:sub(2)))
  package.loaded[current_file] = nil
  return require(current_file)
end

return DebugEntry
