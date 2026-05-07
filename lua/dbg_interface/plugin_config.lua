local M = {}

local configs = {}

function M.setup(user_opts)
    configs = vim.tbl_deep_extend('force', configs, user_opts or {})
end

function M.get()
    return vim.deepcopy(configs)
end

return M
