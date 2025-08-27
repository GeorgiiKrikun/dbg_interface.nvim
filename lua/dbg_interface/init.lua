local M = {}

local dap = require('dap')
local DebugEntry = require('DebugEntry')
local DebugHistory = require('DebugHistory')
local Path = require('pl.path')
local tablex = require('pl.tablex')
local async = require('plenary.async')
local Snacks = require('snacks')

M.configs = 
  {
    cppdbg = {
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

function M.run_dap(type, program, flags)
  local config = tablex.deepcopy(M.configs[type])
  if not config then
    vim.notify("No configuration found for type: " .. tostring(type), vim.log.levels.ERROR)
    return
  end
  config.type = type
  config.program = program
  config.args = M.parse_args(flags)
  dap.run(config)
end

-- Wrap vim.ui.input to be awaitable
local awaitable_input = async.wrap(vim.ui.input, 2)
function M.dbg_args_async(type)
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
    
    M.run_dap(type, executable, flags)

    -- Update history
    M.debug_history:add_entry(DebugEntry{type = type, prog=executable, args=flags})
    M.debug_history:save_history()

  end, function(err)
    if err then
      vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

function M.gen_items(history, type)
  local items = {}
  local sorted_items = history:sorted_recent_by_type(type)
  for _, val in ipairs(sorted_items.entries) do
    local item = { text = val:cmd(), preview = { text = "Preview for " .. val.prog .. " " .. val.args }, }
    table.insert(items, item)
  end
  return items
end

function M.run_picker(type)
  Snacks.picker.pick({
    items = M.gen_items(M.debug_history, type),
    preview = "preview",
    format = "text",
    confirm = function(picker, item)
      picker:close()
      local entry = M.debug_history:sorted_recent_by_type().entries[item.idx]
      M.run_dap(entry.type, entry.prog, entry.args)
    end,
  })
end

function M.reload()
	local current_file, _ = Path.splitext(Path.basename(debug.getinfo(1, "S").source:sub(2)))
	package.loaded[current_file] = nil
	return require(current_file)
end

return M

