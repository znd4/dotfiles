return {
  "github/copilot.vim",
  priority = 101,
  config = function()
    -- TODO - run this in the background
    vim.cmd.Copilot("restart")

    vim.keymap.set(
      "i",
      "<C-j>",
      "copilot#Accept('<CR>')",
      { expr = true, noremap = true, silent = true, replace_keycodes = false }
    )

    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_filetypes = {
      ["dap-repl"] = false,
    }

    vim.api.nvim_create_augroup("yamlenter", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter" }, {
      group = "yamlenter",
      pattern = { ".circleci/*.yml" },
      callback = function()
        vim.b.copilot_enabled = true
      end,
    })
  end,
}
