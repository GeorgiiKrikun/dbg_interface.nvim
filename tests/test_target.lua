local DebugTarget = require('dbg_interface.DebugTarget')
local MiniTest = require('mini.test')

-- 1. Initialize the test set
local T = MiniTest.new_set({
    localize = false, -- Set to true if you want tests to run in a separate process
})

-- 2. Define a nested set for organizational clarity
T['DebugTarget'] = MiniTest.new_set()

T['DebugTarget']['initialization'] = function()
    local entry = DebugTarget:new({path = "~/software/dbg_test_execs/python/target1_loops.py"})

    MiniTest.expect.equality(entry.prog, "p1")
    MiniTest.expect.equality(entry.args, "a1 a2")
    MiniTest.expect.equality(entry.name, "p1 a1 a2") -- Checking the auto-name logic
end

T['DebugTarget']['array shorthand'] = function()
    local entry = DebugEntry:new({prog = "p2", args = "5 6"})
    MiniTest.expect.equality(entry.prog, "p2")
    MiniTest.expect.equality(entry.args, "5 6")
end

return T


