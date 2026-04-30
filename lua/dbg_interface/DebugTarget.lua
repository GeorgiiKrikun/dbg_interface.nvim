local Enum = require('dbg_interface.Enum')

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

    local debug_type = kwargs.debug_type
    if is_empty(debug_type) then
        error("Debug type field is missing for the given executable")
    end

    self.relpath = relpath
    self.alias = kwargs.alias or vim.fs.basename(relpath)
    self.executable_type = self.determine_executable_type(path)
    self.debug_type = debug_type
end

function DebugTarget:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

function DebugTarget:to_json()
    local raw_json = vim.json.encode(self)
    if vim.fn.executable("jq") == 1 then
        return vim.fn.system("jq .", raw_json)
    end

    return raw_json
end


function DebugTarget:open_float_with_json()
    local json = self:to_json()
    local lines = vim.split(json, "\n")



end

return DebugTarget
