vim.cmd.Copilot("restart")

vim.cmd('imap <silent><script><expr> <C-j> copilot#Accept("")')

vim.o.copilot_no_tab_map = true
vim.o.copilot_assume_mapped = true
