local async = require('plenary.async')
local utils = require('dbg_interface.utils')
local EditWin = require('dbg_interface.EditWin')

local M = {}

function M.edit_stuff(stuff, datatype, callback)
    async.run(
        function()
            local json = vim.json.encode(stuff)
            json = utils.beautify_json(json)
            local result = EditWin.async_open_for_edit(json, "json")
            if result == nil then return end
            local table_res = datatype.from_table(vim.json.decode(result))
            if callback then
                callback(table_res)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.edit_stuff_async = async.wrap(M.edit_stuff, 3)

function M.edit_table(tbl, callback)
    async.run(
        function()
            local json = vim.json.encode(tbl)
            json = utils.beautify_json(json)
            local result = EditWin.async_open_for_edit(json, "json")
            if result == nil then return end
            local table_res = vim.json.decode(result)
            if callback then
                callback(table_res)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.edit_table_async = async.wrap(M.edit_table, 2)

return M
