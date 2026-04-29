local DebugArguments = {}
DebugArguments.__index = DebugArguments

function DebugArguments:_init(kwargs)
    self.args = kwargs.args
    self.alias = kwargs.alias or DebugArguments.concat_list(kwargs.args)
end

-- 2. The Constructor
function DebugArguments:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

function DebugArguments.from_table(tbl)
    return DebugArguments:new{
        prog = tbl.prog,
        args = tbl.args,
        type = tbl.type,
        name = tbl.name or (tbl.prog .. " " .. tbl.args),
        timestamp = tbl.timestamp
    }
end

function DebugArguments.concat_list(list) 
    local out = ""
    for i = 1, #args do
        out = out .. tostring(args[i])
        if i ~= #args then
            out = out .. " "
        end
    end
end


function DebugArguments:__lt(other)
    return self.timestamp < other.timestamp
end

function DebugArguments:__eq(other)
    return self.prog == other.prog and self.args == other.args and self.type == other.type
end

function DebugArguments:__tostring()
    return "DebugArguments(name = " .. self.name .. "; type = " .. self.type .. "; prog=" .. self.prog .. "; args=" .. self.args .. ")"
end

function DebugArguments.__concat(op1, op2)
    if type(op1) == "string" then
        return op1 .. tostring(op2)
    elseif type(op2) == "string" then
        return tostring(op1) .. op2
    end
end

function DebugArguments:cmd()
    return vim.trim(self.prog .. " " .. self.args)
end


return DebugArguments

