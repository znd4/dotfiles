vim.cmd.Copilot("restart")

vim.cmd('imap <silent><script><expr> <C-j> copilot#Accept("")')

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
