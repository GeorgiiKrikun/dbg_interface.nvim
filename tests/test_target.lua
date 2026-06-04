local DebugTarget = require('dbg_interface.DbgTarget')
local DebugArguments = require('dbg_interface.DbgArguments')
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
        alias = "custom_debug_target",
        debug_type = "python"
    })
    MiniTest.expect.equality(target.relpath, "dbg_test_execs/python/target1_loops.py")
    MiniTest.expect.equality(target.alias, "custom_debug_target")
    MiniTest.expect.equality(target.executable_type, Enum.executable_type.PYTHON)
    -- MiniTest.expect.equality(target.debug_type, "python")
end


T['DebugTarget']['init_py_wo_alias'] = function()
    local target = DebugTarget:new({
        path = vim.fs.abspath("./dbg_test_execs/python/target1_loops.py"),
        debug_type = "python"
    })
    MiniTest.expect.equality(target.relpath, "dbg_test_execs/python/target1_loops.py")
    MiniTest.expect.equality(target.alias, "target1_loops.py")
    MiniTest.expect.equality(target.executable_type, Enum.executable_type.PYTHON)
    -- MiniTest.expect.equality(target.debug_type, "python")
end

T['DebugTarget']['init_bin'] = function() 
    local target = DebugTarget:new({
        path = vim.fs.abspath("dbg_test_execs/cpp/build/target1_pointers"),
        alias = "pointers",
        debug_type = "cpp"
    })
    MiniTest.expect.equality(target.relpath, "dbg_test_execs/cpp/build/target1_pointers")
    MiniTest.expect.equality(target.alias, "pointers")
    MiniTest.expect.equality(target.executable_type, Enum.executable_type.BINARY)
    -- MiniTest.expect.equality(target.debug_type, "cpp")
end

T['DebugTarget']['args'] = function() 
    local target = DebugTarget:new({
        path = vim.fs.abspath("dbg_test_execs/cpp/build/target1_pointers"),
        alias = "pointers",
        debug_type = "cpp"
    })

    local args = DebugArguments:new({
        args = {"--hello", "world", "-d", "zalupa33"}
    })

    target:add_arguments(args)
    MiniTest.expect.equality(#(target.args), 1)
    MiniTest.expect.equality(target.args[1], args)

    local args2 = DebugArguments:new({
        args = {"Double check"}
    })

    target:add_arguments(args2)
    MiniTest.expect.equality(#(target.args), 2)
    MiniTest.expect.equality(target.args[2], args2)

    target:remove_arguments(args)
    MiniTest.expect.equality(#(target.args), 1)
    MiniTest.expect.equality(target.args[1], args2)

    target:remove_arguments(args2)
    MiniTest.expect.equality(#(target.args), 0)
end

return T


