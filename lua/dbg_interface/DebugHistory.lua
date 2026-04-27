local DebugEntry = require('dbg_interface.DebugEntry')

-- Define the class table and its metatable operations
local DebugHistory = {}
DebugHistory.__index = DebugHistory

-- Metamethod for tostring
function DebugHistory:__tostring()
  local strs = {}
  for i, entry in ipairs(self.entries) do
    table.insert(strs, tostring(i) .. ": " .. tostring(entry))
  end
  return table.concat(strs, "\n")
end

-- Configuration constants
DebugHistory.history_storage = vim.fn.stdpath('data') .. '/debug_configs_history.json'

--- Constructor
function DebugHistory.new(kwargs)
  local self = setmetatable({}, DebugHistory)
  self.entries = (kwargs and kwargs.init) or {}
  return self
end

--- Helper function to find the index of an entry
local function find_index(list, target_entry)
  for i, entry in ipairs(list) do
    if entry == target_entry then
      return i
    end
  end
  return nil
end

function DebugHistory.load_history()
  local file = io.open(DebugHistory.history_storage, "r")
  if file then
    local content = file:read("*a")
    file:close()
    
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == "table" then
      local entries = {}
      for _, item in ipairs(data) do
        table.insert(entries, DebugEntry.from_table(item))
      end
      return DebugHistory.new{init = entries}
    end
  end
  return DebugHistory.new{}
end

function DebugHistory:save_history()
  local file = io.open(self.history_storage, "w")
  if file then
    file:write(vim.json.encode(self.entries))
    file:close()
  end
end

function DebugHistory:contains(entry)
  return find_index(self.entries, entry) ~= nil
end

function DebugHistory:add_entry(entry)
  local idx = find_index(self.entries, entry)
  if not idx then
    table.insert(self.entries, entry)
  else
    self:upd_ts(self.entries[idx])
  end
end

function DebugHistory:remove_entry(entry)
  local idx = find_index(self.entries, entry)
  if idx then
    table.remove(self.entries, idx)
  else
    vim.notify("Entry " .. tostring(entry) .. " not found in history, cannot remove", vim.log.levels.WARN)
  end
end

function DebugHistory:upd_ts(entry)
  local idx = find_index(self.entries, entry)
  vim.notify("Updating timestamp for entry: " .. tostring(entry), vim.log.levels.DEBUG)
  if idx then
    self.entries[idx].ts = entry.ts
  else
    vim.notify("Entry " .. tostring(entry) .. " not found in history, cannot update timestamp", vim.log.levels.WARN)
  end
end

function DebugHistory:size()
  return #self.entries
end

function DebugHistory:sorted_recent_by_type(type)
  local filtered_entries = {}
  
  -- Filter
  for _, entry in ipairs(self.entries) do
    if entry.type == type then
      table.insert(filtered_entries, entry)
    end
  end
  
  -- Sort and reverse (assuming DebugEntry implements the __lt metamethod)
  -- By checking `b < a`, we achieve a reverse (descending) sort natively.
  table.sort(filtered_entries, function(a, b)
    return b < a 
  end)
  
  return DebugHistory.new{init = filtered_entries}
end

return DebugHistory

