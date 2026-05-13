local async = require('plenary.async')
local select = require('dbg_interface.select')
local edit_ui = require('dbg_interface.edit_ui')
local DbgTarget = require('dbg_interface.DbgTarget')
local DbgArguments = require('dbg_interface.DbgArguments')

---@param callback fun(config: DebugConfig|nil)|nil
---@param payload  DebugConfig|nil
local done = function(callback, payload)
    if callback then callback(payload) end
end

local M = {}

---@param config   DebugConfig
---@param callback fun(config: DebugConfig|nil)|nil
M.target = function(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type = select.type_async(copied_config)
            if not selected_type then
                done(callback, nil)
                return
            end

            local template = select.target_async(selected_type)
            if not template then
                done(callback, nil)
                return
            end

            local template_copy = vim.deepcopy(template)
            local new_target = edit_ui.edit_stuff_async(template_copy, DbgTarget)

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

---@param config   DebugConfig
---@param callback fun(config: DebugConfig|nil)|nil
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

            local template = select.args_async(selected_target)
            if not template then
                done(callback, nil)
                return
            end

            local template_copy = vim.deepcopy(template)
            local new_args = edit_ui.edit_stuff_async(template_copy, DbgArguments)
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
