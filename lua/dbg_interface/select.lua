local async = require('plenary.async')
local Snacks = require('snacks')
local plugin_config = require('dbg_interface.plugin_config')

local M = {}

local async_snacks_select = async.wrap(Snacks.picker.select, 3)

local done = function(callback, payload)
    if callback then callback(payload) end
end

function M.type(config, callback)
    async.run(
        function()
            local types = config.types
            if not types then
                vim.notify("No types exist; nothing to edit", vim.log.levels.ERROR)
                done(callback, nil)
                return
            end

            if #types == 0 then
                vim.notify("No types has been added; nothing to edit", vim.log.levels.ERROR)
                done(callback, nil)
                return
            end

            local selected_item = nil
            if #types == 1 then
                selected_item = types[1]
            else
                selected_item = async_snacks_select(types, {
                    prompt = "Select a debug type:",
                    format_item = function(item)
                        return item.debug_type
                    end
                })
            end

            done(callback, selected_item)
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.type_async = async.wrap(M.type, 2)

function M.type_from_plugin_configs(config, callback)
    async.run(
        function()
            local types = {}
            local already_defined_types = {}

            for k,_ in pairs(plugin_config.get()) do
                already_defined_types[k] = false
            end

            for _,v in ipairs(config.types) do
                already_defined_types[v.debug_type] = true
            end

            for k,v in pairs(already_defined_types) do
                if not v then
                    table.insert(types, k)
                end
            end

            if #types == 0 then
                vim.notify("No types has been defined in the plugin that are not present in the config", vim.log.levels.ERROR)
                done(callback, nil)
                return
            end

            local selected_item = nil
            if #types == 1 then
                selected_item = types[1]
                vim.notify("Adding the only existing type: " .. types[1], vim.log.levels.INFO)
            else
                selected_item = async_snacks_select(types, {
                    prompt = "Select a debug type to add:",
                    format_item = function(item)
                        return item.debug_type
                    end
                })
            end

            done(callback, selected_item)
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.type_from_plugin_configs_async = async.wrap(M.type_from_plugin_configs, 2)

function M.target(dbg_type, callback)
    async.run(
        function()
            local targets = dbg_type.targets
            if #targets == 0 then
                vim.notify("No targets has been added; nothing to edit", vim.log.levels.ERROR)
                return
            end

            local selected_item = nil
            if #targets == 1 then
                selected_item = targets[1]
            else
                selected_item = async_snacks_select(targets, {
                    prompt = "Select a debug target:",
                    format_item = function(item)
                        return item.alias .. " [" .. item.relpath .. "]"
                    end
                })
            end

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
M.target_async = async.wrap(M.target, 2)

function M.args(target, callback)
    async.run(
        function()
            local args = target.args
            if #args == 0 then
                vim.notify("No targets has been added; nothing to edit", vim.log.levels.ERROR)
                return
            end

            local selected_item = nil
            if #args == 1 then
                selected_item = args[1]
            else
                selected_item = async_snacks_select(args, {
                    prompt = "Select a debug arguments:",
                    format_item = function(item)
                        return item.alias
                    end
                })
            end

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
M.args_async = async.wrap(M.args, 2)

return M
