local DbgConfig = require 'dbg_interface.DbgConfig'

local M = {}

local function read()
    local file = io.open(DbgConfig.local_storage, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local ok, data = pcall(vim.json.decode, content)
        if ok and type(data) == "table" then
            return DbgConfig.from_table(data)
        end
    end
end

function M.save(config, path)
    local file = io.open(path, "w")
    if file then
        local encoded = vim.json.encode(config)
        file:write(encoded)
        file:close()
    end
end

M.local_dbg_config = read()

return M
