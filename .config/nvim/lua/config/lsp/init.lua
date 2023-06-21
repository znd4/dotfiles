local ensure_installed = {
    "bashls",
    "bufls",
    "eslint",
    "gopls",
    "jsonls",
    "ltex",
    "marksman",
    "tsserver",
    "rnix",
    "rust_analyzer",
    "sqlls",
    "lua_ls",
    "taplo",
    "texlab",
    "yamlls",
}

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
        "sqlls",
        "tsserver",
        -- "eslint",
    },
    sync = true,
})

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
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

local lsp = require("lsp-zero").preset({
    manage_nvim_cmp = {
        set_extra_mappings = true,
    },
})

local lua_library = vim.api.nvim_get_runtime_file("", true)

lsp.skip_server_setup({ "ltex", "pyright" })
require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

local attached_to_buffer = {}

local function set_keymaps_for_buffer(bufnr)
    if attached_to_buffer[bufnr] then
        return
    end
    lsp.default_keymaps({ buffer = bufnr, preserve_mappings = false })

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vimp.add_buffer_maps(function()
        local function nnoremap(...)
            vimp.nnoremap({ "silent" }, ...)
        end

        -- LSP actions
        nnoremap("<C-K>", vim.lsp.buf.signature_help)
        vimp.inoremap({ "silent" }, "<C-K>", vim.lsp.buf.signature_help)
        vimp.xnoremap({ "silent" }, "<F4>", vim.lsp.buf.range_code_action)

        -- Diagnostics
        nnoremap("gl", vim.diagnostic.open_float)
        nnoremap("[d", vim.diagnostic.goto_prev)
        nnoremap("]d", vim.diagnostic.goto_next)

        nnoremap("gI", vim.lsp.buf.incoming_calls)
        nnoremap("gO", vim.lsp.buf.outgoing_calls)

        nnoremap("<space>wa", vim.lsp.buf.add_workspace_folder)
        nnoremap("<space>wr", vim.lsp.buf.remove_workspace_folder)
        nnoremap("<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end)
    end)
    attached_to_buffer[bufnr] = true
end

lsp.on_attach(function(client, bufnr)
    if client.name == "copilot" then
        return
    end
    enable_formatting(client, bufnr)
    set_keymaps_for_buffer(bufnr)
end)

lsp.ensure_installed(ensure_installed)

local function disableFormatting(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

local yamlls_settings = {
    redhat = {
        telemetry = {
            enabled = true,
        },
    },
    yaml = {
        customTags = {
            "!Sub",
            "!FindInMap sequence",
            "!Ref",
            "!GetAtt",
        },
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
    on_init = disableFormatting,
    settings = yamlls_settings,
    filetypes = yamlls_filetypes,
})

-- code to be profiled
local enabled = { enabled = true }

lsp.configure("pylsp", {
    settings = {
        pylsp = {
            plugins = {
                ruff = enabled,
                rope = enabled,
                rope_autoimport = enabled,
                isort = enabled,
                black = enabled,
            },
        },
    },
})

lsp.configure("tsserver", {
    on_init = disableFormatting,
})

lsp.configure("jsonls", {
    on_init = disableFormatting,
    settings = {
        json = {
            format = {
                enable = false,
            },
            schemas = {
                {
                    fileMatch = { ".prettierrc" },
                    url = "https://json.schemastore.org/prettierrc.json",
                },
                {
                    fileMatch = { ".eslintrc", ".eslintrc.json" },
                    url = "https://json.schemastore.org/eslintrc.json",
                },
            },
        },
    },
})

lsp.configure("lua_ls", {
    on_init = disableFormatting,
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

lsp.configure("sqlls", {
    init_options = {
        provideFormatter = false,
    },
    on_init = disableFormatting,
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

require("mason").setup()
require("mason-lspconfig").setup()

lsp.setup()

require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()

local cmp_config = lsp.defaults.cmp_config({
    completion = {
        keyword_length = 1,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol",
            with_text = true,
            menu = {
                fuzzy_buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                fuzzy_path = "[path]",
                luasnip = "[snip]",
                tn = "[TabNine]",
            },
        }),
    },
    window = cmp.config.window.bordered(),
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "fuzzy_path" },
        { name = "git" },
        { name = "emoji" },
        { name = "fuzzy_buffer" },
        { name = "luasnip" },
    }),
})

cmp.setup(cmp_config)

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "conventionalcommits" },
        { name = "git" },
        { name = "fuzzy_buffer" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "fuzzy_buffer" },
        { name = "cmdline_history" },
    }),
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "fuzzy_path" },
        { name = "cmdline" },
        { name = "cmdline_history" },
    }),
})

require("cmp_git").setup()
