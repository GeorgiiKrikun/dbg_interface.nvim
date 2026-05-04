local Enum = require('dbg_interface.Enum')
local utils = require('dbg_interface.utils')
local DebugArguments = require 'dbg_interface.DbgArguments'

local DebugTarget = {}
DebugTarget.__index = DebugTarget

local function is_empty(path)
    return not path or path == ""
end

function DebugTarget.determine_executable_type(path) 
    if string.sub(path, #path - 2, #path) == ".py" then
        return Enum.executable_type.PYTHON
    else 
        return Enum.executable_type.BINARY
    end
end

function DebugTarget:exists()
    return vim.uv.fs_stat(self.relpath)
end

function DebugTarget.from_table(tbl)
    setmetatable(tbl, DebugTarget)
    for i,_ in ipairs(tbl.args) do
        tbl.args[i] = DebugArguments.from_table(tbl.args[i])
    end
    return tbl
end

function DebugTarget:_init(kwargs)
    kwargs = kwargs or {}

    local path = kwargs.path

    if is_empty(path) then
        error("No path provided")
    end

    local cwd = vim.fn.getcwd()
    local relpath = vim.fs.relpath(cwd, path)

    if is_empty(relpath) then
        error("Debug target outside of the repository")
    end

    self.relpath = relpath
    self.alias = kwargs.alias or vim.fs.basename(relpath)
    self.executable_type = self.determine_executable_type(path)
    self.args = {}
end

function DebugTarget:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

function DebugTarget.barebones()
    local new_target = {
        path = "path/to/debug/target",
        alias = "name"
    }
    return new_target
end

function DebugTarget:to_json()
    local raw_json = vim.json.encode(self)
    return utils.beautify_json(raw_json)
end

function DebugTarget:add_arguments(args)
    utils.append_to_list(self.args, args)
end

function DebugTarget:remove_arguments(args)
    return utils.remove_from_list(self.args, args)
end

return DebugTarget
