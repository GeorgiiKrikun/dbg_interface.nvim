local Enum = require('dbg_interface.Enum')
local utils = require('dbg_interface.utils')
local DebugArguments = require 'dbg_interface.DbgArguments'

---@class DbgTarget
---@field relpath          string           path to the executable relative to cwd
---@field alias            string           display name shown in pickers
---@field executable_type  string           value from Enum.executable_type (BINARY or PYTHON)
---@field args             DbgArguments[]   registered argument presets
local DebugTarget = {}
DebugTarget.__index = DebugTarget

local function is_empty(path)
    return not path or path == ""
end

---@param path string  absolute or relative path to the executable
---@return string      one of Enum.executable_type values
function DebugTarget.determine_executable_type(path)
    if string.sub(path, #path - 2, #path) == ".py" then
        return Enum.executable_type.PYTHON
    else
        return Enum.executable_type.BINARY
    end
end

---@return table|nil  uv stat result, or nil if the file does not exist
function DebugTarget:exists()
    return vim.uv.fs_stat(self.relpath)
end

---@param tbl table
---@return DbgTarget
function DebugTarget.from_table(tbl)
    if type(tbl) ~= "table" then
        error("DbgTarget: expected a JSON object, got " .. type(tbl))
    end
    if not tbl.relpath or tbl.relpath == "" then
        error("DbgTarget: missing required field 'relpath'")
    end
    if tbl.args == nil then
        error("DbgTarget '" .. tbl.relpath .. "': missing required field 'args'")
    end
    if type(tbl.args) ~= "table" then
        error("DbgTarget '" .. tbl.relpath .. "': 'args' must be an array, got " .. type(tbl.args))
    end
    setmetatable(tbl, DebugTarget)
    for i,_ in ipairs(tbl.args) do
        tbl.args[i] = DebugArguments.from_table(tbl.args[i])
    end
    return tbl
end

---@param kwargs { path: string, alias: string|nil }
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
    if kwargs.alias and kwargs.alias ~= "" then
        self.alias = kwargs.alias
    else
        self.alias = vim.fs.basename(relpath)
    end
    self.executable_type = self.determine_executable_type(path)
    self.args = {}
end

---@param kwargs { path: string, alias: string|nil }
---@return DbgTarget
function DebugTarget:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

--- Returns a plain table template suitable for editing before constructing a real instance.
---@return { path: string, alias: string }
function DebugTarget.barebones()
    local new_target = {
        path = "path/to/debug/target",
        alias = ""
    }
    return new_target
end

---@return string  pretty-printed JSON representation
function DebugTarget:to_json()
    local raw_json = utils.json_encode(self)
    return utils.beautify_json(raw_json)
end

---@param args DbgArguments
function DebugTarget:add_arguments(args)
    utils.append_to_list(self.args, args)
end

---@param args DbgArguments
---@return DbgArguments[]
function DebugTarget:remove_arguments(args)
    return utils.remove_from_list(self.args, args)
end

return DebugTarget
