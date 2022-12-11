-- setlocal textwidth, shiftwidth, and formatoptions
vim.opt_local.textwidth = 120
vim.opt_local.shiftwidth = 4
vim.opt_local.formatoptions = vim.opt_local.formatoptions
	- "c" -- Don't auto-wrap comments with gq
	- "r" -- But do continue comments with gq
	- "o" -- O and o, don't continue comments
	- "t" -- Don't auto-wrap text

-- automatically replace tabs with spaces
vim.opt_local.expandtab = true
