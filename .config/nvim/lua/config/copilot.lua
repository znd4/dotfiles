vim.cmd.Copilot("restart")

vim.cmd('imap <silent><script><expr> <C-j> copilot#Accept("")')

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

vim.api.nvim_create_augroup("yamlenter", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = "yamlenter",
    pattern = { ".circleci/*.yml" },
    callback = function()
        vim.b.copilot_enabled = true
    end,
})
