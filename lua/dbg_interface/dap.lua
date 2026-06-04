local M = {}


local plugin_config = require('dbg_interface.plugin_config')

--- Build a ready-to-use nvim-dap launch config from the plugin's data model.
--- The base config is taken from `plugin_config.debug_types[dbg_type.debug_type].config`
--- and the dynamic fields (name, program, args, cwd) are overlaid on top.
---@param dbg_type DbgType          the type entry (carries debug_type key)
---@param target   DbgTarget        the target entry (relpath, alias, executable_type)
---@param args     DbgArguments|nil argument preset, or nil for no args
---@return table|nil  DAP config table for dap.run(), nil if the type is not in plugin config
function M.to_dap_config(dbg_type, target, args)
    local type_entry_config = vim.tbl_get(plugin_config.get(), 'debug_types', dbg_type.debug_type, 'config')
    if not type_entry_config then
        return nil
    end

    local name = target.alias
    if args and args.alias and args.alias ~= "no args" then
        name = name .. " [" .. args.alias .. "]"
    end

    return vim.tbl_deep_extend('force', type_entry_config, {
        name = name,
        program = vim.fn.fnamemodify(target.relpath, ":p"),
        args = (args and args.args) or {},
        cwd = vim.fn.getcwd(),
    })
end

return M
