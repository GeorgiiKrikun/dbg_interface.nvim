local async = require("plenary.async")

local M = {}

function M.open_edit_win(target_json, ftype, kwargs, cb)
    local plugin_config = require("dbg_interface.plugin_config")
    kwargs = vim.tbl_deep_extend("force", plugin_config.get().edit_win, kwargs or {})

    local ext = ftype and ("." .. ftype) or ""
    local tmpfile = vim.fn.tempname() .. ext

    local f = io.open(tmpfile, "w")
    if not f then
        vim.notify("EditWin: failed to create temp file", vim.log.levels.ERROR)
        cb(nil)
        return
    end
    f:write(target_json)
    f:close()

    vim.schedule(function()
        local scratch = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(scratch, true, kwargs.window)
        vim.cmd("edit " .. vim.fn.fnameescape(tmpfile))
        local bufnr = vim.api.nvim_get_current_buf()
        local augroup = vim.api.nvim_create_augroup("EditWin_" .. bufnr, { clear = true })
        local done = false

        local function finish(content)
            if done then return end
            done = true
            pcall(vim.api.nvim_del_augroup_by_id, augroup)
            pcall(os.remove, tmpfile)
            cb(content)
        end

        -- Write = submit: finish first so the augroup is cleared before bdelete fires WinClosed
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = augroup,
            buffer = bufnr,
            once = true,
            callback = function()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local content = table.concat(lines, "\n")
                finish(content)
                pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
            end,
        })

        -- q / :close / any window exit without saving = cancel
        vim.api.nvim_create_autocmd("WinClosed", {
            group = augroup,
            pattern = tostring(win),
            once = true,
            callback = function()
                finish(nil)
                pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
            end,
        })
    end)
end

-- Same signature as FloatWin.async_open_float_for_edit: (target_json, ftype, kwargs, cb)
M.async_open_for_edit = async.wrap(M.open_edit_win, 4)

return M
