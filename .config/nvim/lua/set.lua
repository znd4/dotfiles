-- set tabs to 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- linux-specific settings
local uname_output = vim.fn.system("uname")
if uname_output:match("Linux") then
    vim.g.netrw_browsex_viewer = "xdg-open"
end

--enable editorconfig
vim.g.editorconfig = true

-- set autoindent
vim.opt.smartindent = true

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.confirm = true
vim.opt.hidden = true

vim.opt.mouse = "a"

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.colorcolumn = "100"

-- configure folding to use treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
