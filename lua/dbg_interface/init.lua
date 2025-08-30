local M = {}

local dap = require('dap')
local DebugEntry = require('dbg_interface.DebugEntry')
local DebugHistory = require('dbg_interface.DebugHistory')
local Path = require('pl.path')
local tablex = require('pl.tablex')
local async = require('plenary.async')
local Snacks = require('snacks')

local configs =
  {
    vscode = {
      config = {
        name = "Tests",
        type = "cppdbg",
        request = "launch",
        program = "",
        stopAtEntry = false,
        cwd = "/app/",
        environment = {},
        externalConsole = false,
        justMyCode = true,
        args="",
        setupCommands = {
          {
             text = '-enable-pretty-printing',
             description =  'enable pretty printing',
             ignoreFailures = false
          },
        },
      },
      opts = {
        filetype = { "cpp"},
      }
    }
  }

M.debug_history = DebugHistory.load_history()

function M.parse_args(arg_string)
  local args = {}
  for arg in string.gmatch(arg_string, "%S+") do
    table.insert(args, arg)
  end
  return args
end

function M.get_config(custom_name, executable, args) 
  vim.notify("Getting configuration for type: " .. tostring(custom_name), vim.log.levels.INFO)
  local config = tablex.deepcopy(configs[custom_name].config)
  local opts = tablex.deepcopy(configs[custom_name].opts)

  if not config then
    vim.notify("No configuration found for type: " .. tostring(custom_name), vim.log.levels.ERROR)
    error()
  end
  vim.notify("Found configuration for type " .. vim.inspect(custom_name) .. ": " .. vim.inspect(config), vim.log.levels.INFO)
  config.program = executable
  config.args = M.parse_args(args)
  return config, opts
end

-- Wrap vim.ui.input to be awaitable
local awaitable_input = async.wrap(Snacks.input, 2)
function M.dbg_args_async(custom_name)
  -- async.run starts the coroutine context
  async.run(function()
    local executable = awaitable_input({
      prompt = 'Enter the path to the executable: ',
      default = '/app/output/tests/core-tests',
      completion = 'file',
    })

    -- The user pressed <Esc> or entered nothing
    if not executable or executable == "" then
      vim.notify('No executable provided, cancelling.', vim.log.levels.WARN)
      return -- Exit the async function
    end

    local flags = awaitable_input({
      prompt = 'Flags: ',
      -- You could add completion for flags here if desired
    })

    -- The user pressed <Esc> on the second prompt
    if flags == nil then -- Note: empty string for flags is a valid input
        vim.notify('No flags provided, cancelling.', vim.log.levels.WARN)
        return
    end
 
    local config, opts = M.get_config(custom_name, executable, flags)
    vim.notify("Starting DAP with config: " .. vim.inspect(config), vim.log.levels.INFO)
    dap.run(config, opts)

    -- Update history
    M.debug_history:add_entry(DebugEntry{type = custom_name, prog=executable, args=flags})
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
    local item = { text = val:cmd(), preview = { text = "Preview for " .. val.prog .. " " .. val.args }, }
    table.insert(items, item)
  end
  return items
end

function M.run_picker(custom_name)
  Snacks.picker.pick({
    items = M.gen_items(M.debug_history, custom_name),
    preview = "preview",
    format = "text",
    confirm = function(picker, item)
      picker:close()
      local entry = M.debug_history:sorted_recent_by_type(custom_name).entries[item.idx]
      local config, opts = M.get_config(custom_name, entry.prog, entry.args)
      dap.run(config, opts)
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
      print(entry:cmd())
    end,
  })
end

-- function M.reload()
-- 	local current_file, _ = Path.splitext(Path.basename(debug.getinfo(1, "S").source:sub(2)))
-- 	package.loaded[current_file] = nil
-- 	return require(current_file)
-- end
--

function M.print_configs()
  print("Current DAP Configurations:")
  print(vim.inspect(configs))
end

function M.setup(user_opts)
  -- We merge the user's options into our default config table.
  -- 'force' means the user's values will overwrite the defaults.
  -- 'user_opts or {}' prevents errors if the user calls setup() with no arguments.
  configs = vim.tbl_deep_extend('force', configs, user_opts or {})
end

return M

