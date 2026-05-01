local FloatWin = {}
FloatWin.__index = FloatWin
local async = require("plenary.async")

FloatWin.async_open_float_for_edit = async.wrap(function(
    target_json,
    ftype,
    kwargs,
    cb
)
    local float_win = require("dbg_interface.FloatWin")
    kwargs = kwargs or {}
    kwargs.callback = function(data)
        cb(data)
    end
    local f = float_win:new(kwargs)
    -- This schedule here is to schedule the UI job only in the main thread. 
    -- Gemini says that just calling `f:open(target_json, ftype)` is a ticking time bomb since it can get executed from another thread
    vim.schedule(function()
        f:open(target_json, ftype)
    end)
end, 4)

function FloatWin:_init(kwargs)
    self.win = nil

    local width_ratio = kwargs.width or 0.6
    local height_ratio = kwargs.height or 0.5
    local width = math.floor(vim.o.columns * width_ratio)
    local height = math.floor(vim.o.lines * height_ratio)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    self.whrc = {
        w = width,
        h = height,
        r = row,
        c = col,
    }

    self.bufnr = nil
    self.win = nil
    self.callback = kwargs.callback
end

function FloatWin:new(kwargs)
    local instance = setmetatable({}, self)
    instance:_init(kwargs)
    return instance
end

function FloatWin:close()
    if vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_close(self.win, true)
    end

end

function FloatWin:open(text, ftype)
    self.bufnr = vim.api.nvim_create_buf(false, true)

    -- 1. Populate the buffer text first
    local lines = vim.split(text, "\n")
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)

    -- 2. Open the window
    self.win = vim.api.nvim_open_win(self.bufnr , true, {
        relative = 'editor',
        width = self.whrc.w,
        height = self.whrc.h,
        row = self.whrc.r,
        col = self.whrc.c,
        style = 'minimal',
        border = 'rounded',
    })
    vim.wo[self.win].winhl = 'Normal:FloatNormal'

    -- 3. Set filetype AFTER the window is created and focused
    if ftype then
        vim.bo[self.bufnr].filetype = ftype
    end

    -- 4. Explicitly enable folding on the floating window
    vim.wo[self.win].foldenable = true
    -- Keep all folds OPEN by default
    vim.wo[self.win].foldlevel = 99   
    -- If you use Treesitter for folding (Recommended for modern Neovim):
    vim.wo[self.win].foldmethod = 'expr'
    vim.wo[self.win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    
    -- OR, if you don't use Treesitter, uncomment these instead:
    -- vim.wo[self.win].foldmethod = 'syntax' 

    self:_set_close_hotkey()
    self:_set_return_hotkey()
end

function FloatWin:_set_close_hotkey()
    vim.keymap.set(
        'n',
        'q',
        function ()
            self:close()
            if self.callback then
                self.callback(nil) 
                self.callback = nil 
            end
        end,
        {
            buffer = self.bufnr,
            nowait = true
        }
    )

end

function FloatWin:_set_return_hotkey()
    vim.keymap.set('n', '<CR>', function()
        local final_out = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
        if self.callback then
            self.callback(final_out)
            self.callback = nil
        end
        self:close()
    end, {
        buffer = self.bufnr,
        nowait = true
    })

end

return FloatWin
