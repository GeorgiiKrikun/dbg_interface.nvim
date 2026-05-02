local Enum = require('dbg_interface.Enum')
local utils = require('dbg_interface.utils')
local DbgType = require 'dbg_interface.DbgType'
local DebugConfig = {}
DebugConfig.__index = DebugConfig

DebugConfig.local_storage = "./.debug_config.json"

function DebugConfig:_init(kwargs)
    self.types = (kwargs and kwargs.types) or {}
end

function DebugConfig:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

function DebugConfig.from_table(tbl)
    setmetatable(tbl, DebugConfig)
    for i,_ in ipairs(tbl.types) do
        tbl.types[i] = DbgType.from_table(tbl.types[i])
    end
    return tbl
end

function DebugConfig:add_type(type)
    utils.append_to_list(self.types, type)
end

function DebugConfig:remove_type(type)
    return utils.remove_from_list(self.types, type)
end

return DebugConfig
