---@class DbgArguments
---@field args string[]
---@field alias string
---@field prog string
local DebugArguments = {}
DebugArguments.__index = DebugArguments

---@param kwargs {args?: string[], alias?: string}
function DebugArguments:_init(kwargs)
    self.args = kwargs.args or {}
    if #self.args > 0 then
        self:force_args_to_string()
        self.alias = kwargs.alias or table.concat(kwargs.args, " ")
    else
        self.alias = "no args"
    end
end

-- 2. The Constructor
---@param kwargs {args?: string[], alias?: string}
---@return DbgArguments
function DebugArguments:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

---@param tbl table
---@return DbgArguments
function DebugArguments.from_table(tbl)
    setmetatable(tbl, DebugArguments)
    return tbl
end

function DebugArguments:force_args_to_string()
    for i,v in ipairs(self.args) do
        self.args[i] = tostring(v)
    end
end

---@param other DbgArguments
---@return boolean
function DebugArguments:__eq(other)
    return self.args == other.args and self.alias == other.alias
end

---@return string
function DebugArguments:__tostring()
    return self.alias
end

function DebugArguments.__concat(op1, op2)
    if type(op1) == "string" then
        return op1 .. tostring(op2)
    elseif type(op2) == "string" then
        return tostring(op1) .. op2
    end
end

---@return string
function DebugArguments:cmd()
    return vim.trim((self.prog or "") .. " " .. table.concat(self.args, " "))
end

return DebugArguments
