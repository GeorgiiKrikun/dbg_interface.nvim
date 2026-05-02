local M = {}

local DbgTarget = require 'dbg_interface.DbgTarget'
local DbgArguments = require 'dbg_interface.DbgArguments'
local DbgType = require 'dbg_interface.DbgType'
local DbgConfig = require 'dbg_interface.DbgConfig'
local async = require('plenary.async')
local Snacks = require('snacks')

local async_snacks_input = async.wrap(Snacks.input, 2)
local async_snacks_select = async.wrap(Snacks.picker.select, 3)

local configs = {}

--@param config DbgConfig
--@return DbgType
function M.select_type(config, callback)
    async.run(
        function()
            local types = config.types
            local selected_item = async_snacks_select(types, {
                prompt = "Select a debug type:",
                format_item = function(item)
                    return item.debug_type
                end
            })
            if callback then
                callback(selected_item)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

function M.edit_stuff(stuff, datatype, callback)
    local FloatWin = require "dbg_interface.FloatWin"
    local utils = require "dbg_interface.utils"
    async.run(
        function()
            local json = vim.json.encode(stuff)
            json = utils.beautify_json(json)
            local result = FloatWin.async_open_float_for_edit(json, "json")
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

function M.setup(user_opts)
  configs = vim.tbl_deep_extend('force', configs, user_opts or {})
end



return M
