local prettier = { "prettierd", "prettier" }
return {
  "stevearc/conform.nvim",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = {
    formatters_by_ft = {
      python = { "ruff" },
      lua = { "stylua" },
      json = { prettier },
      javascript = { prettier },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
