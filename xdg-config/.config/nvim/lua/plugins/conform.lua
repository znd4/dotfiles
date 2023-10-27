local prettier = { "prettierd", "prettier" }
return {
  "stevearc/conform.nvim",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = {
    formatters_by_ft = {
      python = { "ruff_format" },
      fish = { "fish_indent" },
      lua = { "stylua" },
      just = { "just" },
      yaml = { prettier },
      json = { prettier },
      javascript = { prettier },
      markdown = { prettier },
    },
    format_on_save = {
      timeout_ms = 500,
      -- lsp_fallback = true,
    },
  },
}
