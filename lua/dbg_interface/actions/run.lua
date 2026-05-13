local async = require('plenary.async')
local select = require('dbg_interface.select')
local dap_module = require('dbg_interface.dap')

local M = {}

---Select a type → target → optional args preset, then launch via dap.run().
---Does not modify the config; callback is never invoked with a new config.
---@param config   DbgConfig
---@param callback fun(config: DbgConfig|nil)|nil
M.target = function(config, callback)
    async.run(
        function()
            local selected_type = select.type_async(config)
            if not selected_type then return end

            local selected_target = select.target_async(selected_type)
            if not selected_target then return end

            local selected_args = nil
            if #selected_target.args > 0 then
                selected_args = select.args_async(selected_target)
            end

            local dap_config = dap_module.to_dap_config(selected_type, selected_target, selected_args)
            if not dap_config then
                vim.notify("dbg: no DAP config for type '" .. selected_type.debug_type .. "'", vim.log.levels.ERROR)
                return
            end

            require('dap').run(dap_config)
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

return M
