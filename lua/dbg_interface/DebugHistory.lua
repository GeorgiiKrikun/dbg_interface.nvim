local DebugEntry = require('dbg_interface.DebugEntry')
local Class = require('pl.class')
local Path = require('pl.path')
local List = require('pl.List')
local tablex = require('pl.tablex')
local DebugHistory = Class()

DebugHistory.history_storage = vim.fn.stdpath('data') .. '/debug_configs_history.json'

function DebugHistory.load_history()
    local file = io.open(DebugHistory.history_storage, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local ok, data = pcall(vim.json.decode, content)
        if ok and type(data) == "table" then
          entries = tablex.map(DebugEntry.from_table, data)
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

function DebugHistory:_init(kwargs)
  if kwargs and kwargs.init then 
    self.entries = List(kwargs.init)
  else
    self.entries = List()
  end
end

function DebugHistory:contains(entry)
  if self.entries:contains(entry) then
    return true
  else
    return false
  end
end

function DebugHistory:add_entry(entry)
  if not self:contains(entry) then
    self.entries:append(entry)
  else
    local i  = tablex.find(self.entries, entry)
    self:upd_ts(self.entries[i])
  end
end

function DebugHistory:remove_entry(entry)
  local idx = self.entries:index(entry)
  if idx then
    self.entries:remove(idx)
  else
    vim.notify("Entry " .. entry .. " not found in history, cannot remove", vim.log.levels.WARN)
  end
end

function DebugHistory:upd_ts(entry)
  local idx = self.entries:index(entry)
  vim.notify("Updating timestamp for entry: " .. entry, vim.log.levels.DEBUG)
  if idx then
    self.entries[idx].ts = entry.ts
  else
    vim.notify("Entry " .. entry .. " not found in history, cannot update timestamp", vim.log.levels.WARN)
  end
end

function DebugHistory:size()
  return #self.entries
end

function DebugHistory.new(kwargs)
  local instance = DebugHistory(kwargs)
  return instance
end

function DebugHistory:sorted_recent_by_type(type)
  local filtered_entries = self.entries:filter(function(entry) return entry.type == type end)
  local sorted_entries = filtered_entries:sort():reverse()
  return DebugHistory.new{init = sorted_entries}
end

function DebugHistory:__tostring()
  local strs = {}
  for i, entry in ipairs(self.entries) do
    table.insert(strs, tostring(i) .. ": " .. tostring(entry))
  end
  return table.concat(strs, "\n")
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

function DebugHistory.reload()
	local current_file, _ = Path.splitext(Path.basename(debug.getinfo(1, "S").source:sub(2)))
	package.loaded[current_file] = nil
	return require(current_file)
end

return DebugHistory

