require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "bashls",
        "rnix",
        "eslint",
        "sumneko_lua",
        "rust_analyzer",
        "bufls",
        "pyright",
        "sqls",
        "yamlls",
        "taplo",
        "texlab",
    },
    automatic_installation = true,
})

if vim.fn.executable("lua-language-server") ~= 1 then
    print("plz brew install lua-language-server or something")
end

if vim.fn.executable("stylua") ~= 1 then
    print("plz cargo install stylua")
end

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

require("lsp-format").setup({
    exclude = {
        "sumneko_lua",
        "sqls",
    },
    sync = true,
})

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            local ft = vim.fn.getbufvar(bufnr, "&filetype")
            local result
            if ft == "sql" then
                result = client.name ~= "sqls"
            elseif ft == "lua" then
                result = client.name ~= "sumneko_lua"
            else
                result = true
            end
            return result
            --return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- add to your shared on_attach callback
local enable_formatting = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                lsp_formatting(bufnr)
            end,
        })
    end
end

local module_exists, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities
if module_exists then
    capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
else
    print("cmp_nvim_lsp not installed")
    return
end

local vimp = require("vimp")
if vimp == nil then
    print("failed to import vimpeccable")
    return
end
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    if client.name == "yamlls" then
        client.server_capabilities.documentFormattingProvider = true
    end
    enable_formatting(client, bufnr)
    -- require("lsp-format").on_attach(client)

    -- buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vimp.add_buffer_maps(function()
        local function map(...)
            vimp.nnoremap({ "silent" }, ...)
        end
        map("gI", vim.lsp.buf.incoming_calls)
        map("gO", vim.lsp.buf.outgoing_calls)
        map("gD", vim.lsp.buf.declaration)
        map("gd", vim.lsp.buf.definition)
        map("K", vim.lsp.buf.hover)
        map("gi", vim.lsp.buf.implementation)
        map("<C-k>", vim.lsp.buf.signature_help)
        vimp.inoremap({ "silent" }, "<C-k>", vim.lsp.buf.signature_help)
        map("<space>wa", vim.lsp.buf.add_workspace_folder)
        map("<space>wr", vim.lsp.buf.remove_workspace_folder)
        map("<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end)
        map("<space>D", vim.lsp.buf.type_definition)
        map("<space>rn", vim.lsp.buf.rename)
        map("<space>ca", vim.lsp.buf.code_action)
        map("<leader>d]", vim.diagnostic.goto_next)
        map("<leader>d[", vim.diagnostic.goto_prev)
        map("gr", vim.lsp.buf.references)
        map("<space>f", function()
            vim.lsp.buf.format({ async = true })
        end)
    end)
end

local lsp_defaults = {
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    on_attach = on_attach,
}

local lspconfig = require("lspconfig")

lspconfig.util.default_config = vim.tbl_deep_extend("force", lspconfig.util.default_config, lsp_defaults)
for _, x in pairs({
    "tflint",
    "terraform_lsp",
    "bashls",
    "bufls",
    "clangd",
    "eslint",
    "kotlin_language_server",
    "pyright",
    "rnix",
    "rust_analyzer",
    "tsserver",
}) do
    lspconfig[x].setup({})
end

print("Setting up texlab")
lspconfig.texlab.setup({
    settings = {
        texlab = {
            build = {
                -- executable="tectonic",
                executable = "xelatex",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = true,
            },
            chktex = {
                onEdit = true,
                onOpenAndSave = true,
            },
        },
    },
})

-- TOML
lspconfig.taplo.setup({
    filetypes = { "toml", "gitconfig" },
})
lspconfig.gopls.setup({
    cmd = { "gopls" },
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            buildFlags = { "-tags=integration" },
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
            codelenses = {
                gc_details = true,
            },
        },
    },
    init_options = {
        usePlaceholders = true,
    },
})

lspconfig.sqls.setup({
    init_options = {
        provideFormatter = false,
    },
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
})

local null_ls = require("null-ls")
null_ls.setup({
    -- on_init = function(client)
    --  local path = client.workspace_folders[1].name
    --  for source
    --  client.config.sources
    -- end
    sources = {
        -- dotenv
        null_ls.builtins.diagnostics.dotenv_linter,

        -- protobuf
        null_ls.builtins.diagnostics.buf,
        null_ls.builtins.formatting.buf,

        null_ls.builtins.formatting.stylua.with({
            extra_args = { "--indent-type", "spaces" },
        }),
        null_ls.builtins.diagnostics.eslint,

        -- python
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,

        -- golang
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.gofmt,

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
        -- null_ls.builtins.formatting.sqlfluff.with({
        --     extra_args = { "--config=pyproject.toml" },
        -- }),
        -- null_ls.builtins.diagnostics.sqlfluff.with({
        --     extra_args = { "--config=pyproject.toml" },
        -- }),

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
lspconfig.yamlls.setup({
    settings = {
        redhat = {
            telemetry = {
                enabled = true,
            },
        },
        yaml = {
            schemas = {
                ["Kubernetes"] = "/overlays/**/*",
                ["https://json.schemastore.org/circleciconfig.json"] = {
                    "/.circleci/config.*",
                    "/.circleci/test-deploy.*",
                },
                -- codecov
                ["https://json.schemastore.org/codecov.json"] = "/.codecov.yml",
            },
            format = {
                enable = true,
            },
        },
    },
    filetypes = { "yaml", "yml", "yaml.docker-compose" },
})

lspconfig.sumneko_lua.setup({
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})

-- lspconfig.pylsp.setup({
-- 	settings = {
-- 		pylsp = {
-- 			plugins = {
-- 				pycodestyle = {
-- 					ignore = { "W391" },
-- 					maxLineLength = 100,
-- 				},
-- 				pyflakes = { enabled = false },
-- 				flake8 = { enabled = true },
-- 				pydocstyle = { enabled = true },
-- 				black = {
-- 					enable = true,
-- 				},
-- 				-- jedi = {
-- 				--     -- TODO - Add something to on_attach that finds virtual environment path
-- 				--     environment = environment
-- 				-- }
-- 			},
-- 		},
-- 	},
-- })
