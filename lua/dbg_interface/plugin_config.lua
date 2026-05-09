local keymaps = require('dbg_interface.keymaps')
local M = {}

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

function M.setup(user_opts)
    configs = vim.tbl_deep_extend('force', configs, user_opts or {})
    keymaps.setup(configs.keymaps)
end

function M.get()
    return vim.deepcopy(configs)
end

return M
