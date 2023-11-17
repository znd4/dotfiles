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
      go = { "gofumpt" },
      yaml = { prettier },
      json = { prettier },
      jsonnet = { "jsonnetfmt" },
      javascript = { prettier },
      markdown = { prettier },
    },
    formatters = {
      jsonnetfmt = {
        command = "jsonnetfmt",
        args = { "-" },
      },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
      async = false,
    },
  },
}
