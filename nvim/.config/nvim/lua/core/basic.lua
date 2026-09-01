vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.autoread = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase =true
vim.opt.smartcase = true
vim.opt.hlsearch =false
vim.opt.showmode = false


vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local transparent = { bg = "NONE", ctermbg = "NONE" }
        vim.api.nvim_set_hl(0, "Normal", transparent)
        vim.api.nvim_set_hl(0, "NormalNC", transparent)
        vim.api.nvim_set_hl(0, "SignColumn", transparent)
        vim.api.nvim_set_hl(0, "LineNr", transparent)
        vim.api.nvim_set_hl(0, "EndOfBuffer", transparent)
        vim.api.nvim_set_hl(0, "Folded", transparent)
        vim.api.nvim_set_hl(0, "FloatBorder", transparent)
    end,
})
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
