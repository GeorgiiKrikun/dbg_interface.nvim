local DebugTarget = require('dbg_interface.DebugTarget')
local Enum = require('dbg_interface.Enum')
local MiniTest = require('mini.test')

-- 1. Initialize the test set
local T = MiniTest.new_set({
    localize = false, -- Set to true if you want tests to run in a separate process
})

-- 2. Define a nested set for organizational clarity
T['DebugTarget'] = MiniTest.new_set()

T['DebugTarget']['init_py'] = function()
    local target = DebugTarget:new({
        path = vim.fs.abspath("./dbg_test_execs/python/target1_loops.py"),
        alias = "custom_debug_target"
    })
    MiniTest.expect.equality(target.relpath, "dbg_test_execs/python/target1_loops.py")
    MiniTest.expect.equality(target.alias, "custom_debug_target")
    MiniTest.expect.equality(target.type, Enum.executable_type.PYTHON)
end


T['DebugTarget']['init_py_wo_alias'] = function()
    local target = DebugTarget:new({
        path = vim.fs.abspath("./dbg_test_execs/python/target1_loops.py"),
    })
    MiniTest.expect.equality(target.relpath, "dbg_test_execs/python/target1_loops.py")
    MiniTest.expect.equality(target.alias, "target1_loops.py")
    MiniTest.expect.equality(target.type, Enum.executable_type.PYTHON)
end

T['DebugTarget']['init_bin'] = function() 
    local target = DebugTarget:new({
        path = vim.fs.abspath("dbg_test_execs/cpp/build/target1_pointers"),
        alias = "pointers"
    })
    MiniTest.expect.equality(target.relpath, "dbg_test_execs/cpp/build/target1_pointers")
    MiniTest.expect.equality(target.alias, "pointers")
    MiniTest.expect.equality(target.type, Enum.executable_type.BINARY)
end

return T


