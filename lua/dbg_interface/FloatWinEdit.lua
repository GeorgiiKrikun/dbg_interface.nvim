local M = {}

M.close_win = function (win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
end

M.open_float = function (kwargs)
    local text = kwargs.text
    local ftype = kwargs.ftype
    local callback = kwargs.callback

    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.5)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(bufnr , true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    vim.wo[win].winhl = 'Normal:FloatNormal' -- Optional: custom highlighting
    vim.keymap.set('n', 'q', M.close_win, { buffer = bufnr, nowait = true })
    vim.keymap.set('n', '<Esc>', M.close_win, { buffer = bufnr, nowait = true })

end
