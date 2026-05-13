local keymaps = require('dbg_interface.keymaps')
local M = {}

---@class PluginConfig
---@field edit_win    { window: { split: string, win: integer } }
---@field json        { encode: fun(tbl: table): string, decode: fun(str: string): any }
---@field debug_types table<string, { config: table, opts: { filetype: string } }>|nil
---@field keymaps     table|nil

---@type PluginConfig
local configs = {
    edit_win = {
        window = {
            split = "below",
            win = -1,
        },
    },
    json = {
        encode = vim.json.encode,
        decode = vim.json.decode,
    },
}

---@param user_opts PluginConfig|nil
function M.setup(user_opts)
    configs = vim.tbl_deep_extend('force', configs, user_opts or {})
    keymaps.setup(configs.keymaps)
end

---@return PluginConfig
function M.get()
    return vim.deepcopy(configs)
end

return M
