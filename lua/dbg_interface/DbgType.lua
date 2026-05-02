local DbgType = {}
DbgType.__index = DbgType

local utils = require('dbg_interface.utils')
local DbgTarget = require 'dbg_interface.DbgTarget'

function DbgType:_init(kwargs)
    kwargs = kwargs or {}
    if not kwargs.debug_type then
        error("Cannot add empty debug type. Make sure you set `debug_type` key.")
    end
    self.debug_type = kwargs.debug_type
    self.targets = {}
end

function DbgType:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

function DbgType.from_table(tbl)
    setmetatable(tbl, DbgType)
    for i,_ in ipairs(tbl.targets) do
        tbl.targets[i] = DbgTarget.from_table(tbl.targets[i])
    end
    return tbl
end

function DbgType:add_target(target)
    self.targets = utils.append_to_list(self.targets, target)
end

function DbgType:add_targets(targets)
    for i, v in ipairs(targets) do
        self.targets = utils.append_to_list(self.targets, v)
    end
end

function DbgType:remove_target(target)
    self.targets = utils.remove_from_list(self.targets, target)
end

function DbgType.create_from_user_config()

end

return DbgType

