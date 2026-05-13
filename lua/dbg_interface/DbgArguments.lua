---@class DbgArguments
---@field args   string[]  ordered list of command-line arguments
---@field alias  string    human-readable label; "no args" when args is empty
local DebugArguments = {}
DebugArguments.__index = DebugArguments

---@param kwargs { args: string[]|nil, alias: string|nil }
function DebugArguments:_init(kwargs)
    self.args = kwargs.args or {}
    if #self.args > 0 then
        self:force_args_to_string()
        if kwargs.alias and kwargs.alias ~= "" then
            self.alias = kwargs.alias
        else
            self.alias = table.concat(kwargs.args, " ")
        end
    else
        self.alias = "no args"
    end
end

---@param kwargs { args: string[]|nil, alias: string|nil }
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

--- Returns a plain table template suitable for editing before constructing a real instance.
---@return { args: string[], alias: string }
function DebugArguments.barebones()
    return { args = {}, alias = "" }
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

---@param op1 DbgArguments|string
---@param op2 DbgArguments|string
---@return string
function DebugArguments.__concat(op1, op2)
    if type(op1) == "string" then
        return op1 .. tostring(op2)
    elseif type(op2) == "string" then
        return tostring(op1) .. op2
    end
end

---@return string
function DebugArguments:cmd()
    return vim.trim(self.prog .. " " .. self.args)
end

return DebugArguments
