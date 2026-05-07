local async = require('plenary.async')
local Snacks = require('snacks')
local select = require('dbg_interface.select')
local utils = require('dbg_interface.utils')

local async_snacks_select = async.wrap(Snacks.picker.select, 3)

local done = function(callback, payload)
    if callback then callback(payload) end
end

local M = {}

M.type = function(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type = select.type_async(copied_config)
            if not selected_type then
                done(callback, nil)
                return
            end

            if copied_config.types and (#(copied_config.types) == 1) then
                local result = async_snacks_select(
                    {"Yes", "No"},
                    { prompt = "Only single type left (" .. selected_type.debug_type .. ") are you sure you want to delete it?" }
                )
                if result ~= "Yes" then
                    done(callback, nil)
                    return
                end
            end

            local idx = utils.find_element_idx(copied_config.types, selected_type)
            if idx then
                table.remove(copied_config.types, idx)
            else
                vim.notify("Error while removing the type " .. selected_type.debug_type)
                done(callback, nil)
                return
            end
            done(callback, copied_config)
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
            if not selected_type then
                done(callback, nil)
                return
            end

            local selected_target = select.target_async(selected_type)
            if not selected_target then
                done(callback, nil)
                return
            end

            if selected_type.targets and (#(selected_type.targets) == 1) then
                local result = async_snacks_select(
                    {"Yes", "No"},
                    { prompt = "Only single target left (" .. selected_target.alias .. "[" .. selected_target.relpath .. "]" .. ") are you sure you want to delete it?" }
                )
                if result ~= "Yes" then
                    done(callback, nil)
                    return
                end
            end

            local idx = utils.find_element_idx(selected_type.targets, selected_target)
            if idx then
                table.remove(selected_type.targets, idx)
            else
                vim.notify("Error while removing the type " .. selected_target.alias .. "[" .. selected_target.relpath .. "]")
                done(callback, nil)
                return
            end
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

            local selected_args = select.args_async(selected_target)
            if not selected_args then
                done(callback, nil)
                return
            end

            if selected_target.args and (#(selected_target.args) == 1) then
                local result = async_snacks_select(
                    {"Yes", "No"},
                    { prompt = "Only single list of arguments left (" .. selected_args.alias .. ") are you sure you want to delete it?" }
                )
                if result ~= "Yes" then
                    done(callback, nil)
                    return
                end
            end

            local idx = utils.find_element_idx(selected_target.args, selected_args)
            if idx then
                table.remove(selected_target.args, idx)
            else
                vim.notify("Error while removing the type " .. selected_args.alias)
                done(callback, nil)
                return
            end
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
