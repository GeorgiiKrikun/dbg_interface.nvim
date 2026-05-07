local async = require('plenary.async')
local select = require('dbg_interface.select')
local edit_ui = require('dbg_interface.edit_ui')
local DbgType = require('dbg_interface.DbgType')
local DbgTarget = require('dbg_interface.DbgTarget')
local DbgArguments = require('dbg_interface.DbgArguments')

local done = function(callback, payload)
    if callback then callback(payload) end
end

local M = {}

M.type = function(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type_name = select.type_from_plugin_configs_async(copied_config)
            local new_debug_type = DbgType:new{debug_type = selected_type_name}
            local edited_type = edit_ui.edit_stuff_async(new_debug_type, DbgType)
            table.insert(copied_config.types, edited_type)
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
            local new_target_kwargs = DbgTarget.barebones()
            local edited_target_kwargs = edit_ui.edit_table_async(new_target_kwargs)
            local new_target = DbgTarget:new(edited_target_kwargs)

            if selected_type:path_exists(new_target.relpath) then
                vim.notify("New executable path already exists", vim.log.levels.ERROR)
                done(callback, nil)
                return
            end

            table.insert(selected_type.targets, new_target)
            done(callback, copied_config)
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
            if not selected_type then
                done(callback, nil)
                return
            end

            local selected_target = select.target_async(selected_type)
            if not selected_target then
                done(callback, nil)
                return
            end

            local new_args_kwargs = DbgArguments.barebones()
            local edited_args_kwargs = edit_ui.edit_table_async(new_args_kwargs)
            local new_args = DbgArguments:new(edited_args_kwargs)
            table.insert(selected_target.args, new_args)
            done(callback, copied_config)
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

return M
