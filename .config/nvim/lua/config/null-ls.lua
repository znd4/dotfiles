require("mason").setup()
local null_ls = require("null-ls")

table.insert(null_ls.builtins.formatting.prettier.filetypes, "sql")

null_ls.setup({
    sources = {
        -- dotenv
        null_ls.builtins.diagnostics.dotenv_linter,

        -- protobuf
        null_ls.builtins.diagnostics.buf,
        null_ls.builtins.formatting.buf,

        null_ls.builtins.formatting.stylua.with({
            extra_args = { "--indent-type", "spaces" },
        }),

        -- python
        -- null_ls.builtins.formatting.black,
        -- null_ls.builtins.formatting.isort,
        -- null_ls.builtins.diagnostics.ruff,
        -- null_ls.builtins.diagnostics.mypy,

        -- golang
        null_ls.builtins.formatting.goimports.with({
            extra_args = { "-local", "github.com/AspirationPartners" },
        }),
        null_ls.builtins.formatting.gofmt,

        -- prettier
        null_ls.builtins.formatting.prettier,

        -- Spellchecking
        null_ls.builtins.completion.spell,

        -- shell scripts
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.diagnostics.shellcheck,

        -- terraform
        null_ls.builtins.formatting.terraform_fmt,

        -- toml
        null_ls.builtins.formatting.taplo.with({
            filetypes = { "toml", "gitconfig" },
        }),

        -- sql
        null_ls.builtins.formatting.sqlfluff.with({
            extra_args = { "--dialect", "postgres" },
        }),
        null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect", "postgres" },
        }),

        -- retab
        {
            filetypes = { "lua", "python" },
            name = "retab",
            method = null_ls.methods.FORMATTING,
            generator = {
                async = true,
                fn = function(_, done)
                    vim.cmd.retab()
                    done()
                end,
            },
        },
    },
})

require("mason-null-ls").setup({
    ensure_installed = nil,
    automatic_installation = true,
    automatic_setup = false,
})
