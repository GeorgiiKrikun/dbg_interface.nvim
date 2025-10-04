local M = {}

local dap = require('dap')
local DebugEntry = require('dbg_interface.DebugEntry')
local DebugHistory = require('dbg_interface.DebugHistory')
local Path = require('pl.path')
local tablex = require('pl.tablex')
local async = require('plenary.async')
local Snacks = require('snacks')

local configs = {}

M.debug_history = DebugHistory.load_history()

function M.parse_args(arg_string)
  local args = {}
  for arg in string.gmatch(arg_string, "%S+") do
    table.insert(args, arg)
  end
  return args
end

function M.get_config(custom_name, executable, args) 
  vim.notify("Getting configuration for type: " .. tostring(custom_name), vim.log.levels.DEBUG)
  local config = tablex.deepcopy(configs[custom_name].config)
  local opts = tablex.deepcopy(configs[custom_name].opts)

  if not config then
    vim.notify("No configuration found for type: " .. tostring(custom_name), vim.log.levels.ERROR)
    error()
  end

  vim.notify("Found configuration for type " .. vim.inspect(custom_name) .. ": " .. vim.inspect(config), vim.log.levels.DEBUG)
  config.program = executable
  config.args = M.parse_args(args)

  return config, opts
end

--- Opens a floating window to edit a list of arguments.
-- @param initial_flags string The initial space-separated flags to edit.
-- @param callback function A function to call with the new flags string when done.
function M.edit_flags(initial_flags, callback)
  -- 1. Parse the initial string into a table of flags (one per line)
  -- A simple split by space. A more robust solution would handle quoted args.
  local flags_table = {}
  for flag in string.gmatch(initial_flags, "[^%s]+") do
    table.insert(flags_table, flag)
  end

  -- 2. Create a new scratch buffer
  local buf = vim.api.nvim_create_buf(false, true) -- Not listed, scratch buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, flags_table)
  vim.bo[buf].filetype = 'debugger-flags' -- Set a custom filetype for completion

  -- 3. Calculate floating window dimensions
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- 4. Open the floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })
  vim.wo[win].winhl = 'Normal:FloatNormal' -- Optional: custom highlighting

  -- 5. Set buffer-local keymaps for accepting or canceling
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Accept with <CR>
  vim.keymap.set('n', '<CR>', function()
    local final_flags_table = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    -- Filter out any empty lines
    local non_empty_flags = {}
    for _, flag in ipairs(final_flags_table) do
        if flag ~= '' then
            table.insert(non_empty_flags, flag)
        end
    end
    -- Join the table back into a single string and call the callback
    callback(table.concat(non_empty_flags, ' '))
    close_win()
  end, { buffer = buf, nowait = true })

  -- Cancel with 'q' or <Esc>
  vim.keymap.set('n', 'q', close_win, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', close_win, { buffer = buf, nowait = true })
end
M.async_edit_flags = async.wrap(M.edit_flags, 2)

-- Wrap vim.ui.input to be awaitable
M.async_snacks_input = async.wrap(Snacks.input, 2)

function M.dbg_args_async(custom_name)
  -- async.run starts the coroutine context
  async.run(function()
    local executable = M.async_snacks_input({
      prompt = 'Enter the path to the executable: ',
      default = '/app/output/tests/core-tests',
      completion = 'file',
    })

    -- The user pressed <Esc> or entered nothing
    if not executable or executable == "" then
      vim.notify('No executable provided, cancelling.', vim.log.levels.WARN)
      return -- Exit the async function
    end

    local flags = M.async_edit_flags("")

    -- The user pressed <Esc> on the second prompt
    if flags == nil then -- Note: empty string for flags is a valid input
        vim.notify('No flags provided, cancelling.', vim.log.levels.WARN)
        return
    end

    local name = M.async_snacks_input({
      prompt = 'Name (optional): ',
    })

    if name == nil then
      vim.notify('No name provided, cancelling.', vim.log.levels.WARN)
      return
    end

    if name == "" then
      name = executable .. " " .. flags
    end

 
    local config, opts = M.get_config(custom_name, executable, flags)
    vim.notify("Starting DAP with config: " .. vim.inspect(config), vim.log.levels.DEBUG)
    dap.run(config, opts)

    -- Update history
    M.debug_history:add_entry(DebugEntry{
      name = name,
      type = custom_name,
      prog=executable,
      args=flags
    })

    M.debug_history:save_history()

  end, function(err)
    if err then
      vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

function M.gen_items(history, custom_name)
  local items = {}
  local sorted_items = history:sorted_recent_by_type(custom_name)
  for _, val in ipairs(sorted_items.entries) do
    local item = { text = val.name, preview = { text = val.prog .. " " .. val.args }, }
    table.insert(items, item)
  end
  return items
end

function M.run_existing_dbg_cfg(custom_name)
  Snacks.picker.pick({
    items = M.gen_items(M.debug_history, custom_name),
    preview = "preview",
    format = "text",
    confirm = function(picker, item)
      picker:close()
      local entry = M.debug_history:sorted_recent_by_type(custom_name).entries[item.idx]
      local config, opts = M.get_config(custom_name, entry.prog, entry.args)
      M.debug_history:upd_ts(entry)
      M.debug_history:save_history()
      dap.run(config, opts)
    end,
  })
end

function M.delete_existing_dbg_cfg(custom_name)
  Snacks.picker.pick({
    items = M.gen_items(M.debug_history, custom_name),
    preview = "preview",
    format = "text",
    confirm = function(picker, item)
      picker:close()
      local entry = M.debug_history:sorted_recent_by_type(custom_name).entries[item.idx]
      M.debug_history:remove_entry(entry)
      M.debug_history:save_history()
    end,
  })
end

function M.get_cli_cmd(custom_name)
  Snacks.picker.pick({
    items = M.gen_items(M.debug_history, custom_name),
    preview = "preview",
    format = "text",
    confirm = function(picker, item)
      picker:close()
      local entry = M.debug_history:sorted_recent_by_type(custom_name).entries[item.idx]
    end,
  })
end

function M.print_configs()
  print("Current DAP Configurations:")
  print(vim.inspect(configs))
end

function M.setup(user_opts)
  configs = vim.tbl_deep_extend('force', configs, user_opts or {})
end

return M

