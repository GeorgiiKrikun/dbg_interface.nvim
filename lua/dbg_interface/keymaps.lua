local DbgConfig = require('dbg_interface.DbgConfig')
local M = {}

local defaults = {
    add_type      = '<leader>Dat',
    add_target    = '<leader>Dax',
    add_args      = '<leader>Daa',
    edit_type     = '<leader>Det',
    edit_target   = '<leader>Dex',
    edit_args     = '<leader>Dea',
    remove_type   = '<leader>Drt',
    remove_target = '<leader>Drx',
    remove_args   = '<leader>Dra',
    clone_target  = '<leader>Dcx',
    clone_args    = '<leader>Dca',
    run_target    = '<leader>Dsr',
}

local actions = {
    add_type      = { get = function(d) return d.add.type end,       desc = 'dbg: add type' },
    add_target    = { get = function(d) return d.add.target end,     desc = 'dbg: add target' },
    add_args      = { get = function(d) return d.add.args end,       desc = 'dbg: add args' },
    edit_type     = { get = function(d) return d.edit.type end,      desc = 'dbg: edit type' },
    edit_target   = { get = function(d) return d.edit.target end,    desc = 'dbg: edit target' },
    edit_args     = { get = function(d) return d.edit.args end,      desc = 'dbg: edit args' },
    remove_type   = { get = function(d) return d.remove.type end,    desc = 'dbg: remove type' },
    remove_target = { get = function(d) return d.remove.target end,  desc = 'dbg: remove target' },
    remove_args   = { get = function(d) return d.remove.args end,    desc = 'dbg: remove args' },
    clone_target  = { get = function(d) return d.clone.target end,   desc = 'dbg: clone target' },
    clone_args    = { get = function(d) return d.clone.args end,     desc = 'dbg: clone args' },
    run_target    = { get = function(d) return d.run.target end,     desc = 'dbg: run target' },
}

local function bind(get_action)
    return function()
        local dbg = require('dbg_interface')
        get_action(dbg)(dbg.local_dbg_config, function(new_config)
            if new_config then
                dbg.local_dbg_config = new_config
                dbg.save_debug_config(new_config, DbgConfig.local_storage)
            end
        end)
    end
end

function M.setup(user_keymaps)
    local keymaps = vim.tbl_extend('force', defaults, user_keymaps or {})
    for name, lhs in pairs(keymaps) do
        local action = actions[name]
        if action then
            vim.keymap.set('n', lhs, bind(action.get), { noremap = true, silent = true, desc = action.desc })
        end
    end
end

return M
