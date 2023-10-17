vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2

vim.opt_local.formatoptions = vim.opt_local.formatoptions
  - "c" -- Don't auto-wrap comments with gq
  - "r" -- But do continue comments with gq
  - "o" -- O and o, don't continue comments
  - "t" -- Don't auto-wrap text
