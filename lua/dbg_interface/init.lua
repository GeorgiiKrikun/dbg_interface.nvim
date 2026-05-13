local M = {}

local plugin_config = require('dbg_interface.plugin_config')
local dbg_config = require('dbg_interface.config')
local actions = require('dbg_interface.actions')
local dap = require('dbg_interface.dap')

M.local_dbg_config = dbg_config.local_dbg_config
M.save_debug_config = dbg_config.save

M.add = actions.add
M.edit = actions.edit
M.remove = actions.remove
M.clone = actions.clone

M.to_dap_config = dap.to_dap_config

M.setup = plugin_config.setup

return M
