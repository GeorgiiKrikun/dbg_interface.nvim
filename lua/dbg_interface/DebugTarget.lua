local DebugTarget = {}
DebugTarget.__index = DebugTarget

local function is_empty(path)
    return not path or path == ""
end

function DebugTarget:_init(kwargs)
    kwargs = kwargs or {}
    local path = kwargs.path or kwargs[1]

    if is_empty(path) then
        error("No path provided")
    end

    local cwd = vim.fn.get_cwd()
    local relpath = vim.fs.relpath(cwd, path)

    if is_empty(relpath) then
        error("Debug target outside of the repository")
    end

    self.relpath = relpath
    self.alias = kwargs.alias or vim.fs.basename(relpath)
end

-- 2. The Constructor
function DebugTarget:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

