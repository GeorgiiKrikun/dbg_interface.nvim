local async = require('plenary.async')
local utils = require('dbg_interface.utils')
local EditWin = require('dbg_interface.EditWin')

local M = {}

function M.edit_stuff(stuff, datatype, callback)
    async.run(
        function()
            local json = utils.json_encode(stuff)
            json = utils.beautify_json(json)
            local result = EditWin.async_open_for_edit(json, "json")
            if result == nil then return end
            local ok, decoded = pcall(utils.json_decode, result)
            if not ok then
                error("Invalid JSON: " .. tostring(decoded))
            end
            local ok2, table_res = pcall(datatype.from_table, decoded)
            if not ok2 then
                error("Invalid format: " .. tostring(table_res))
            end
            if callback then
                callback(table_res)
            end
        end,
        function(err)
            if err then
                vim.notify(tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.edit_stuff_async = async.wrap(M.edit_stuff, 3)

function M.edit_table(tbl, callback)
    async.run(
        function()
            local json = utils.json_encode(tbl)
            json = utils.beautify_json(json)
            local result = EditWin.async_open_for_edit(json, "json")
            if result == nil then return end
            local ok, decoded = pcall(utils.json_decode, result)
            if not ok then
                error("Invalid JSON: " .. tostring(decoded))
            end
            if callback then
                callback(decoded)
            end
        end,
        function(err)
            if err then
                vim.notify(tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.edit_table_async = async.wrap(M.edit_table, 2)

return M
