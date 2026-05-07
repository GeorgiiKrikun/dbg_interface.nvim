local M = {}

local plugin_config = require('dbg_interface.plugin_config')
local dbg_config = require('dbg_interface.config')
local select = require('dbg_interface.select')
local edit_ui = require('dbg_interface.edit_ui')
local actions = require('dbg_interface.actions')

M.local_dbg_config = dbg_config.local_dbg_config
M.save_debug_config = dbg_config.save

M.select_type = select.type
M.select_type_async = select.type_async
M.select_type_from_plugin_configs = select.type_from_plugin_configs
M.select_type_from_plugin_configs_async = select.type_from_plugin_configs_async
M.select_target = select.target
M.select_target_async = select.target_async
M.select_args = select.args
M.select_args_async = select.args_async

M.edit_stuff = edit_ui.edit_stuff
M.edit_stuff_async = edit_ui.edit_stuff_async
M.edit_table = edit_ui.edit_table
M.edit_table_async = edit_ui.edit_table_async

M.add = actions.add
M.edit = actions.edit
M.remove = actions.remove

M.setup = plugin_config.setup
M.get_plugin_config = plugin_config.get

return M
