local ensure_installed = {
    "bashls",
    "bufls",
    "eslint",
    "gopls",
    "jsonls",
    "ltex",
    "marksman",
    "pyright",
    "rnix",
    "rust_analyzer",
    "sqls",
    "lua_ls",
    "taplo",
    "texlab",
    "yamlls",
}

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
        "lua_ls",
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
                result = client.name ~= "lua_ls"
            else
                result = true
            end
            return result
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
        client.server_capabilities.documentFormattingProvider = false
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
        vimp.inoremap({ "silent" }, "<C-k>", vim.lsp.buf.signature_help)
        map("<space>wa", vim.lsp.buf.add_workspace_folder)
        map("<space>wr", vim.lsp.buf.remove_workspace_folder)
        map("<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end)
        map("<space>D", vim.lsp.buf.type_definition)
        -- map("<space>ca", vim.lsp.buf.code_action)
    end)
end

local lsp = require("lsp-zero")
lsp.preset("recommended")
local lua_library = vim.api.nvim_get_runtime_file("", true)

-- lsp.skip_server_setup({ "marksman" })
lsp.skip_server_setup({ "ltex" })

lsp.nvim_workspace({
    library = lua_library,
})
lsp.on_attach(on_attach)
lsp.ensure_installed(ensure_installed)

local yamlls_settings = {
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
}
local yamlls_filetypes = { "yaml", "yml", "yaml.docker-compose" }

lsp.configure("yamlls", {
    settings = yamlls_settings,
    filetypes = yamlls_filetypes,
})

lsp.configure("lua_ls", {
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
                -- add ~/.local/share/nvim/lazy to vim.api.nvim_get_runtime_file("", true)
                library = lua_library,
                checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})

local texlab_settings = {
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
}
lsp.configure("texlab", {
    settings = texlab_settings,
})
lsp.configure("taplo", {
    filetypes = { "toml", "gitconfig" },
})

lsp.configure("sqls", {
    init_options = {
        provideFormatter = false,
    },
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
})

lsp.configure("gopls", {
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

local lspkind = require("lspkind")

local cmp = require("cmp")

-- vim.opt.completeopt = { "menu", "menuone", "noselect" }

lsp.setup()

local cmp_config = lsp.defaults.cmp_config({
    completion = {
        keyword_length = 1,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol",
            with_text = true,
            -- maxwidth = 50,
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
                luasnip = "[snip]",
                tn = "[TabNine]",
            },
        }),
    },
    window = cmp.config.window.bordered(),
    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-y>"] = cmp.mapping.confirm(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
})

cmp.setup(cmp_config)

local null_ls = require("null-ls")
null_ls.setup({
    -- on_init = function(client)
    --  local path = client.workspace_folders[1].name
    --  for source
    --  client.config.sources
    -- end
    on_attach = on_attach,
    sources = {
        -- dotenv
        null_ls.builtins.diagnostics.dotenv_linter,

        -- protobuf
        null_ls.builtins.diagnostics.buf,
        null_ls.builtins.formatting.buf,

        null_ls.builtins.formatting.stylua.with({
            extra_args = { "--indent-type", "spaces" },
        }),
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.diagnostics.eslint_d,

        -- python
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,

        -- golang
        null_ls.builtins.formatting.goimports.with({
            extra_args = { "-local", "github.com/AspirationPartners" },
        }),
        null_ls.builtins.formatting.gofmt,

        -- prettier
        null_ls.builtins.formatting.prettierd.with({
            -- remove javascript from filetypes
            filetypes = {
                "json",
                "yaml",
                "markdown",
                "html",
                "css",
                "scss",
                "less",
                "graphql",
                "vue",
                "svelte",
                "bash",
                "yaml.docker-compose",
            },
        }),

        null_ls.builtins.formatting.prettier_eslint,

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
