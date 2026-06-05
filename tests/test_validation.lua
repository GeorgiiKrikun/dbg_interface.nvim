local DbgArguments = require('dbg_interface.DbgArguments')
local DbgTarget = require('dbg_interface.DbgTarget')
local DbgType = require('dbg_interface.DbgType')
local DbgConfig = require('dbg_interface.DbgConfig')
local MiniTest = require('mini.test')

local T = MiniTest.new_set({ localize = false })

-- ── DbgArguments.from_table ───────────────────────────────────────────────────

T['DbgArguments'] = MiniTest.new_set()

T['DbgArguments']['from_table happy path'] = function()
    local a = DbgArguments.from_table({ args = { "--foo", "bar" }, alias = "foo" })
    MiniTest.expect.equality(a.alias, "foo")
    MiniTest.expect.equality(a.args, { "--foo", "bar" })
end

T['DbgArguments']['from_table: missing args'] = function()
    MiniTest.expect.error(function()
        DbgArguments.from_table({ alias = "foo" })
    end, "missing required field 'args'")
end

T['DbgArguments']['from_table: args not array'] = function()
    MiniTest.expect.error(function()
        DbgArguments.from_table({ args = "not a table", alias = "foo" })
    end, "'args' must be an array")
end

T['DbgArguments']['from_table: not a table'] = function()
    MiniTest.expect.error(function()
        DbgArguments.from_table("oops")
    end, "expected a JSON object")
end

-- ── DbgTarget.from_table ──────────────────────────────────────────────────────

T['DbgTarget'] = MiniTest.new_set()

T['DbgTarget']['from_table happy path'] = function()
    local t = DbgTarget.from_table({
        relpath = "some/binary",
        alias = "bin",
        executable_type = "BINARY",
        args = {},
    })
    MiniTest.expect.equality(t.relpath, "some/binary")
    MiniTest.expect.equality(t.alias, "bin")
end

T['DbgTarget']['from_table: missing relpath'] = function()
    MiniTest.expect.error(function()
        DbgTarget.from_table({ alias = "bin", args = {} })
    end, "missing required field 'relpath'")
end

T['DbgTarget']['from_table: missing args'] = function()
    MiniTest.expect.error(function()
        DbgTarget.from_table({ relpath = "some/binary", alias = "bin" })
    end, "missing required field 'args'")
end

T['DbgTarget']['from_table: args not array'] = function()
    MiniTest.expect.error(function()
        DbgTarget.from_table({ relpath = "some/binary", alias = "bin", args = 42 })
    end, "'args' must be an array")
end

T['DbgTarget']['from_table: not a table'] = function()
    MiniTest.expect.error(function()
        DbgTarget.from_table(123)
    end, "expected a JSON object")
end

-- ── DbgType.from_table ────────────────────────────────────────────────────────

T['DbgType'] = MiniTest.new_set()

T['DbgType']['from_table happy path'] = function()
    local t = DbgType.from_table({ debug_type = "cpp", targets = {} })
    MiniTest.expect.equality(t.debug_type, "cpp")
    MiniTest.expect.equality(t.targets, {})
end

T['DbgType']['from_table: missing debug_type'] = function()
    MiniTest.expect.error(function()
        DbgType.from_table({ targets = {} })
    end, "missing required field 'debug_type'")
end

T['DbgType']['from_table: empty debug_type'] = function()
    MiniTest.expect.error(function()
        DbgType.from_table({ debug_type = "", targets = {} })
    end, "missing required field 'debug_type'")
end

T['DbgType']['from_table: missing targets'] = function()
    MiniTest.expect.error(function()
        DbgType.from_table({ debug_type = "cpp" })
    end, "missing required field 'targets'")
end

T['DbgType']['from_table: targets not array'] = function()
    MiniTest.expect.error(function()
        DbgType.from_table({ debug_type = "cpp", targets = "oops" })
    end, "'targets' must be an array")
end

T['DbgType']['from_table: not a table'] = function()
    MiniTest.expect.error(function()
        DbgType.from_table(true)
    end, "expected a JSON object")
end

-- ── DbgConfig.from_table ──────────────────────────────────────────────────────

T['DbgConfig'] = MiniTest.new_set()

T['DbgConfig']['from_table happy path'] = function()
    local c = DbgConfig.from_table({ types = {} })
    MiniTest.expect.equality(c.types, {})
end

T['DbgConfig']['from_table with nested data'] = function()
    local c = DbgConfig.from_table({
        types = {
            {
                debug_type = "python",
                targets = {
                    { relpath = "script.py", alias = "s", executable_type = "PYTHON", args = {} },
                },
            },
        },
    })
    MiniTest.expect.equality(c.types[1].debug_type, "python")
    MiniTest.expect.equality(c.types[1].targets[1].relpath, "script.py")
end

T['DbgConfig']['from_table: missing types'] = function()
    MiniTest.expect.error(function()
        DbgConfig.from_table({})
    end, "missing required field 'types'")
end

T['DbgConfig']['from_table: types not array'] = function()
    MiniTest.expect.error(function()
        DbgConfig.from_table({ types = "nope" })
    end, "'types' must be an array")
end

T['DbgConfig']['from_table: not a table'] = function()
    MiniTest.expect.error(function()
        DbgConfig.from_table(nil)
    end, "expected a JSON object")
end

T['DbgConfig']['from_table: propagates DbgType error'] = function()
    MiniTest.expect.error(function()
        DbgConfig.from_table({ types = { { targets = {} } } })
    end, "missing required field 'debug_type'")
end

T['DbgConfig']['from_table: propagates DbgTarget error'] = function()
    MiniTest.expect.error(function()
        DbgConfig.from_table({
            types = { { debug_type = "cpp", targets = { { alias = "x", args = {} } } } }
        })
    end, "missing required field 'relpath'")
end

return T
