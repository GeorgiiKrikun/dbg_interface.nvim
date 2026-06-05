---@class DbgType
---@field debug_type  string       language/adapter key, e.g. "rust", "cpp", "python"
---@field targets     DbgTarget[]  registered debug targets for this type
local DbgType = {}
DbgType.__index = DbgType

local utils = require('dbg_interface.utils')
local DbgTarget = require 'dbg_interface.DbgTarget'

---@param kwargs { debug_type: string }
function DbgType:_init(kwargs)
    kwargs = kwargs or {}
    if not kwargs.debug_type then
        error("Cannot add empty debug type. Make sure you set `debug_type` key.")
    end
    self.debug_type = kwargs.debug_type
    self.targets = {}
end

---@param kwargs { debug_type: string }
---@return DbgType
function DbgType:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

---@param tbl table
---@return DbgType
function DbgType.from_table(tbl)
    if type(tbl) ~= "table" then
        error("DbgType: expected a JSON object, got " .. type(tbl))
    end
    if not tbl.debug_type or tbl.debug_type == "" then
        error("DbgType: missing required field 'debug_type'")
    end
    if tbl.targets == nil then
        error("DbgType '" .. tbl.debug_type .. "': missing required field 'targets'")
    end
    if type(tbl.targets) ~= "table" then
        error("DbgType '" .. tbl.debug_type .. "': 'targets' must be an array, got " .. type(tbl.targets))
    end
    setmetatable(tbl, DbgType)
    for i,_ in ipairs(tbl.targets) do
        tbl.targets[i] = DbgTarget.from_table(tbl.targets[i])
    end
    return tbl
end

---@param target DbgTarget
function DbgType:add_target(target)
    self.targets = utils.append_to_list(self.targets, target)
end

---@param targets DbgTarget[]
function DbgType:add_targets(targets)
    for i, v in ipairs(targets) do
        self.targets = utils.append_to_list(self.targets, v)
    end
end

---@param target DbgTarget
function DbgType:remove_target(target)
    self.targets = utils.remove_from_list(self.targets, target)
end

---@param path string  relpath to check
---@return boolean
function DbgType:path_exists(path)
    for _,t in ipairs(self.targets) do
        if t.relpath == path then
            return true
        end
    end
    return false
end



function DbgType.create_from_user_config()

end

return DbgType

