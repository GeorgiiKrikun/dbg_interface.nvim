local M = {}

local DebugTarget = require "dbg_interface.DbgTarget"
local DebugArguments = require 'dbg_interface.DbgArguments'
local DebugType = require "dbg_interface.DbgType"
local DebugHistory = require "dbg_interface.DbgConfig"

---@return DbgConfig
M.generate_test_data = function()
    local target = DebugTarget:new{
        path = vim.fs.abspath("dbg_test_execs/cpp/build/target1_pointers") or "",
        alias = "pointers",
    }

    local args = DebugArguments:new{
        args = {"--hello", "world", "-d", "zalupa33"}
    }

    target:add_arguments(args)

    local args2 = DebugArguments:new{
        args = {"Double check"}
    }

    target:add_arguments(args2)

    local args3 = DebugArguments:new{
        args = {}
    }

    target:add_arguments(args3)

    local target2 = DebugTarget:new{
        path = vim.fs.abspath("dbg_test_execs/python/main.py") or "",
        alias = "py_backend",
    }

    local t2_args1 = DebugArguments:new{
        args = {"--port", "8080", "--verbose"}
    }
    target2:add_arguments(t2_args1)

    local t2_args2 = DebugArguments:new{
        args = {"--env", "development"}
    }
    target2:add_arguments(t2_args2)

    local t2_args3 = DebugArguments:new{
        args = {}
    }
    target2:add_arguments(t2_args3)


    -- Third debug target (e.g., a Rust or C binary using lldb)
    local target3 = DebugTarget:new{
        path = vim.fs.abspath("dbg_test_execs/cpp/build/target2_classes") or "",
        alias = "classes",
    }

    local t3_args1 = DebugArguments:new{
        args = {"--iterations", "1000", "-v"}
    }

    target3:add_arguments(t3_args1)

    local t3_args2 = DebugArguments:new{ args = {"--log-file", "/tmp/test.log"} }

    target3:add_arguments(t3_args2)

    local dbg_type_cpp = DebugType:new{debug_type = "cpp"}
    dbg_type_cpp:add_targets({target, target3})

    local dbg_type_python = DebugType:new{debug_type = "python"}
    dbg_type_python:add_targets({target2})

    local hist = DebugHistory:new { types = {dbg_type_cpp, dbg_type_python} }
    return hist
end

return M
