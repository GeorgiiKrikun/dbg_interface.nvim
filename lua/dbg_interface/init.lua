local M = {}

local DbgTarget = require 'dbg_interface.DbgTarget'
local DbgArguments = require 'dbg_interface.DbgArguments'
local DbgType = require 'dbg_interface.DbgType'
local DbgConfig = require 'dbg_interface.DbgConfig'
local async = require('plenary.async')
local Snacks = require('snacks')

local async_snacks_input = async.wrap(Snacks.input, 2)
local async_snacks_select = async.wrap(Snacks.picker.select, 3)

local configs = {}
local function read_debug_config() 
  local file = io.open(DbgConfig.local_storage, "r")
  if file then
    local content = file:read("*a")
    file:close()
    
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == "table" then
        return DbgConfig.from_table(data)
    end
  end
end

M.save_debug_config = function(config, path)
    local file = io.open(path, "w")
    if file then
        local encoded = vim.json.encode(config)
        file:write(encoded)
        file:close()
    end
end

M.local_dbg_config = read_debug_config()

--@param config DbgConfig
--@return DbgType
function M.select_type(config, callback)
    async.run(
        function()
            local types = config.types
            local selected_item = async_snacks_select(types, {
                prompt = "Select a debug type:",
                format_item = function(item)
                    return item.debug_type
                end
            })
            if callback then
                callback(selected_item)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.select_type_async = async.wrap(M.select_type, 2)

--@param config DbgType
--@return DbgTarget
function M.select_target(dbg_type, callback)
    async.run(
        function()
            local targets = dbg_type.targets
            local selected_item = async_snacks_select(targets, {
                prompt = "Select a debug target:",
                format_item = function(item)
                    return item.alias .. " [" .. item.relpath .. "]"
                end
            })
            if callback then
                callback(selected_item)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.select_target_async = async.wrap(M.select_target, 2)

function M.select_args(target, callback)
    async.run(
        function()
            local args = target.args
            local selected_item = async_snacks_select(args, {
                prompt = "Select a debug arguments:",
                format_item = function(item)
                    return item.alias
                end
            })
            if callback then
                callback(selected_item)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.select_args_async = async.wrap(M.select_args, 2)

function M.edit_stuff(stuff, datatype, callback)
    local FloatWin = require "dbg_interface.FloatWin"
    local utils = require "dbg_interface.utils"
    -- NOTE: This is an ugly fix because something attaches methods not to metatable.
    async.run(
        function()
            local json = vim.json.encode(stuff)
            json = utils.beautify_json(json)
            local result = FloatWin.async_open_float_for_edit(json, "json")
            local table_res = datatype.from_table(vim.json.decode(result))
            if callback then
                callback(table_res)
            end
        end, 
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end
M.edit_stuff_async = async.wrap(M.edit_stuff, 3)


function M.edit_type(config, callback)
    async.run(
        function()
            local copied_config = vim.deepcopy(config)
            local selected_type = M.select_type_async(copied_config)
            local edited_type = M.edit_stuff_async(selected_type, DbgType)
            for i, t in ipairs(copied_config.types) do
                if t == selected_type then
                    copied_config.types[i] = edited_type
                    break
                end
                vim.notify("Failed to replace the dictionary item", vim.log.levels.ERROR)
            end
            if callback then
                callback(copied_config)
            end
        end,
        function(err)
            if err then
                vim.notify("An error occurred: " .. tostring(err), vim.log.levels.ERROR)
            end
        end
    )
end

function M.setup(user_opts)
  configs = vim.tbl_deep_extend('force', configs, user_opts or {})
end

return M
