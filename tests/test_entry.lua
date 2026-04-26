local DebugEntry = require('dbg_interface.DebugEntry')
local MiniTest = require('mini.test')

-- 1. Initialize the test set
local T = MiniTest.new_set({
    localize = false, -- Set to true if you want tests to run in a separate process
})

-- 2. Define a nested set for organizational clarity
T['DebugEntry Properties'] = MiniTest.new_set()

T['DebugEntry Properties']['initialization'] = function()
    local entry = DebugEntry:new({ prog = "p1", args = "a1 a2", type = "t1" })

    MiniTest.expect.equality(entry.prog, "p1")
    MiniTest.expect.equality(entry.args, "a1 a2")
    MiniTest.expect.equality(entry.name, "p1 a1 a2") -- Checking the auto-name logic
end

T['DebugEntry Properties']['array shorthand'] = function()
    local entry = DebugEntry:new({prog = "p2", args = "5 6"})
    MiniTest.expect.equality(entry.prog, "p2")
    MiniTest.expect.equality(entry.args, "5 6")
end

T['Metamethods'] = MiniTest.new_set()

T['Metamethods']['comparison (__lt)'] = function()
    local entry1 = DebugEntry:new({ prog = "p1", timestamp = 100 })
    local entry2 = DebugEntry:new({ prog = "p2", timestamp = 200 })
    MiniTest.expect.equality(entry1.timestamp, 100)
    MiniTest.expect.equality(entry2.timestamp, 200)
    MiniTest.expect.equality((entry1 < entry2), true)
end

T['Metamethods']['concatenation (__concat)'] = function()
    local entry = DebugEntry:new({ name = "test_entry" })
    local result = "Result: " .. entry
    MiniTest.expect.equality(result, "Result: " .. tostring(entry))
    MiniTest.expect.equality(tostring(entry) .. " is finished", entry .. " is finished")
end

return T

