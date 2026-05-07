local async = require('plenary.async')
local select = require('dbg_interface.select')
local edit_ui = require('dbg_interface.edit_ui')
local DbgType = require('dbg_interface.DbgType')
local DbgTarget = require('dbg_interface.DbgTarget')
local DbgArguments = require('dbg_interface.DbgArguments')
local utils = require('dbg_interface.utils')

local M = {}

M.type = function(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type = select.type_async(copied_config)
            local edited_type = edit_ui.edit_stuff_async(selected_type, DbgType)
            utils.replace_in_list(config.types, selected_type, edited_type)
            if callback then
                callback(copied_config)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

M.target = function(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type = select.type_async(copied_config)
            local selected_target = select.target_async(selected_type)
            local edited_target = edit_ui.edit_stuff_async(selected_target, DbgTarget)
            utils.replace_in_list(selected_type.targets, selected_target, edited_target)
            if callback then
                callback(copied_config)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

M.args = function(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type = select.type_async(copied_config)
            local selected_target = select.target_async(selected_type)
            local selected_args = select.args_async(selected_target)
            local edited_args = edit_ui.edit_stuff_async(selected_args, DbgArguments)
            utils.replace_in_list(selected_target.args, selected_args, edited_args)
            if callback then
                callback(copied_config)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

return M
