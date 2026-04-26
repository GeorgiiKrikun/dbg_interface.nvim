local MiniTest = require('mini.test')
local expect = MiniTest.expect

-- Require the modules you are testing
local DebugHistory = require('dbg_interface.DebugHistory')
local DebugEntry = require('dbg_interface.DebugEntry')

-- Create a main test set
local T = MiniTest.new_set({
  hooks = {
    -- This runs before every single test case, ensuring a clean state
    pre_case = function()
      DebugHistory.history_storage = '/tmp/test_debug_history.json'
      os.remove(DebugHistory.history_storage) -- clean up from previous runs
    end,
  },
})

T['add_entry'] = function()
  local dh = DebugHistory.new{}
  local entry1 = DebugEntry:new{prog = "p1", args ="a1 a2"}
  local entry2 = DebugEntry:new{prog = "p1", args ="a2 a3"}
  local entry3 = DebugEntry:new{prog = "p1", args ="a1 a2"}

  dh:add_entry(entry1)
  dh:add_entry(entry2)

  expect.equality(entry1, entry3)
  expect.equality(dh:size(), 2)

  -- Adding a duplicate shouldn't increase size
  dh:add_entry(entry3)
  expect.equality(dh:size(), 2)

  -- Check if entries exist
  expect.equality(dh:contains(entry3), true)
  expect.equality(dh:contains(entry1), true)
  expect.equality(dh:contains(entry2), true)
end

T['save and load history'] = function()
  local dh = DebugHistory.new{}
  local entry1 = DebugEntry:new{prog = "p1", args ="a1 a2"}
  local entry2 = DebugEntry:new{prog = "p2", args ="b1 b2"}
  dh:add_entry(entry1)
  dh:add_entry(entry2)

  -- Save to the temp file
  dh:save_history()

  -- Load from the temp file
  local loaded_dh = DebugHistory.load_history()
  
  expect.equality(loaded_dh:size(), dh:size())

  -- Deep compare each entry
  for i, entry in ipairs(loaded_dh.entries) do
    expect.equality(entry, dh.entries[i])
  end
end

return T
