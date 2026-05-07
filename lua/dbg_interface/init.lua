local M = {}

local plugin_config = require('dbg_interface.plugin_config')
local dbg_config = require('dbg_interface.config')
local actions = require('dbg_interface.actions')

M.local_dbg_config = dbg_config.local_dbg_config
M.save_debug_config = dbg_config.save

M.add = actions.add
M.edit = actions.edit
M.remove = actions.remove
M.clone = actions.clone

M.setup = plugin_config.setup

return M
