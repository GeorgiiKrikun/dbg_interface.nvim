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

-- Test stuff
function DebugHistory.test()
  DebugHistory.history_storage = '/tmp/test_debug_history.json'
  local dh = DebugHistory.new{}
  local entry1 = DebugEntry:new{prog = "p1", args ="a1 a2"}
  local entry2 = DebugEntry:new{prog = "p1", args ="a2 a3"}
  local entry3 = DebugEntry:new{prog = "p1", args ="a1 a2"}
  dh:add_entry(entry1)
  dh:add_entry(entry2)
  assert(entry1 == entry3, "entry1 should be equal to entry3")
  assert(dh:size() == 2, "DebugHistory should have 2 entries")
  dh:add_entry(entry3)
  assert(dh:size() == 2, "DebugHistory should still have 2 entries after adding entry3 again")
  assert(dh:contains(entry3), "DebugHistory should contain entry3")
  assert(dh:contains(entry1), "DebugHistory should contain entry1")
  assert(dh:contains(entry2), "DebugHistory should contain entry2")
  os.execute("sleep 1")

  local entry4 = DebugEntry:new{prog = "p1", args ="a1 a2"}
  dh:upd_ts(entry4)
  local entry5 = DebugEntry:new{prog = "p2", args ="a2 a3"}
  assert(dh:contains(entry4), "DebugHistory should contain entry4 after updating timestamp")
  dh:add_entry(entry5)
  assert(dh.entries[1].ts == entry4.ts, "Timestamp should be updated")
  local sorted_dh = dh:sorted_recent()
  local ts1 = sorted_dh.entries[1].timestamp
  local ts2 = sorted_dh.entries[2].timestamp
  assert(ts1 >= ts2, "Sorted entries should be in descending order by timestamp")

  -- test saving and loading history
  dh:save_history()
  local loaded_dh = DebugHistory.load_history()
  assert(loaded_dh:size() == dh:size(), "Loaded DebugHistory should have the same size as original")
  for i, entry in ipairs(loaded_dh.entries) do
    assert(entry == dh.entries[i], "Loaded entry " .. entry .. "should match original entry " .. dh.entries[i])
  end
end

return DebugHistory

