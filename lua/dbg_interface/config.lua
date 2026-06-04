local DbgConfig = require 'dbg_interface.DbgConfig'
local utils = require 'dbg_interface.utils'

local M = {}

---@return DebugConfig
function M.read()
    local file = io.open(DbgConfig.local_storage, "r")
    if not file then
        return DbgConfig:new()
    end
    local content = file:read("*a")
    file:close()
    local ok, data = pcall(utils.json_decode, content)
    if ok and type(data) == "table" then
        return DbgConfig.from_table(data)
    else
        vim.notify("Failed to read the configuration from file " .. DbgConfig.local_storage, vim.log.levels.ERROR)
        vim.notify("Reason: " .. data, vim.log.levels.ERROR)
        return DbgConfig:new()
    end
end

---@param config DebugConfig
---@param path   string  destination file path
function M.save(config, path)
    local file = io.open(path, "w")
    if file then
        local encoded = utils.beautify_json(utils.json_encode(config))
        file:write(encoded)
        file:close()
    end
end

M.local_dbg_config = M.read()

return M
