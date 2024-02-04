local ensure_installed = {
  "bashls",
  "bufls",
  "clojure_lsp",
  "eslint",
  "gopls",
  "helm_ls",
  "html",
  "jsonls",
  "jsonnet_ls",
  "ltex",
  "lua_ls",
  "marksman",
  "pyright",
  "nil_ls",
  "rust_analyzer",
  "sqlls",
  "taplo",
  "texlab",
  "tsserver",
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

-- if you want to set up formatting on save, you can use this as a callback
-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local function disableFormatting(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

-- add to your shared on_attach callback
local enable_formatting = function(client, bufnr)
  -- get name of filetype
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local augroup = vim.api.nvim_create_augroup("LspFormatting" .. ft, {})
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
        })
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

local lsp_zero = require("lsp-zero").preset({
  manage_nvim_cmp = {
    set_extra_mappings = true,
  },
})

local lua_library = vim.api.nvim_get_runtime_file("", true)

local attached_to_buffer = {}

local function set_keymaps_for_buffer(bufnr)
  if attached_to_buffer[bufnr] then
    return
  end
  lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false })

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

lsp_zero.on_attach(function(client, bufnr)
  if client.name == "copilot" then
    return
  end
  enable_formatting(client, bufnr)
  set_keymaps_for_buffer(bufnr)
end)

local yamlls_settings = {
  redhat = {
    telemetry = {
      enabled = true,
    },
  },
  editor = {
    tabSize = 2,
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
      ["https://squidfunk.github.io/mkdocs-material/schema.json"] = { "mkdocs.yml" },
      ["https://json.schemastore.org/kustomization.json"] = { "kustomization.yaml" },
      ["https://json.schemastore.org/circleciconfig.json"] = {
        "/.circleci/config.*",
        "/.circleci/test-deploy.*",
      },
      -- codecov
      ["https://json.schemastore.org/codecov.json"] = "/.codecov.yml",
    },
    format = {
      enable = false,
    },
  },
}
local yamlls_filetypes = { "yaml", "yml", "yaml.docker-compose" }

lsp_zero.configure("yamlls", {
  on_init = disableFormatting,
  settings = yamlls_settings,
  filetypes = yamlls_filetypes,
})

-- code to be profiled
local enabled = { enabled = true }

-- lsp_zero.configure("pylsp", {
--   cmd = { "pylsp", "--verbose", "--log-file", "/tmp/pylsp.log" },
--   settings = {
--     pylsp = {
--       plugins = {
--         ruff = enabled,
--         rope = enabled,
--         rope_autoimport = enabled,
--         -- isort = enabled,
--         -- black = enabled,
--       },
--     },
--   },
-- })

lsp_zero.configure("tsserver", {
  on_init = disableFormatting,
})
lsp_zero.configure("helm_ls", {
  filetypes = { "helm.yaml" },
})

lsp_zero.configure("jsonls", {
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
          fileMatch = { ".devcontainer.json", "devcontainer.json" },
          url = "https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.schema.json",
        },
        {
          fileMatch = { ".eslintrc", ".eslintrc.json" },
          url = "https://json.schemastore.org/eslintrc.json",
        },
        {
          fileMatch = { "devcontainer-feature.json" },
          url = "https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainerFeature.schema.json",
        },
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
lsp_zero.configure("texlab", {
  settings = texlab_settings,
})
lsp_zero.configure("taplo", {
  filetypes = { "toml", "gitconfig" },
})

lsp_zero.configure("sqlls", {
  init_options = {
    provideFormatter = false,
  },
  on_init = disableFormatting,
})

lsp_zero.configure("nil_ls", {
  settings = {
    ["nil"] = {
      formatting = {
        command = "nixfmt",
      },
    },
  },
})

local gopls_settings = {
  cmd = { "gopls" },
  settings = {
    gopls = {
      experimentalPostfixCompletions = true,
      -- buildFlags = { "-tags=integration" },
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
}

require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = ensure_installed,
  handlers = {
    lsp_zero.default_setup,
    ltex = lsp_zero.noop,
    pylsp = lsp_zero.noop,
    rnix = lsp_zero.noop,
    gopls = function()
      require("lspconfig").gopls.setup(gopls_settings)
    end,
    jsonnet_ls = function()
      require("lspconfig").jsonnet_ls.setup({})
    end,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls({ on_init = disableFormatting })
      require("lspconfig").lua_ls.setup(lua_opts)
    end,
    pyright = function()
      require("lspconfig").pyright.setup({
        settings = {
          python = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      })
    end,
  },
})

require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()

local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()

local fuzzy_path = {
  name = "fuzzy_path",
  option = { fd_timeout_msec = 600 },
}

local cmp_config = lsp_zero.defaults.cmp_config({
  completion = {
    keyword_length = 1,
  },
  formatting = lsp_zero.cmp_format(),
  window = cmp.config.window.bordered(),
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-f>"] = cmp_action.luasnip_jump_forward(),
    ["<C-b>"] = cmp_action.luasnip_jump_backward(),
  }),
  sources = cmp.config.sources({
    {
      name = "nvim_lsp",
    },
    { name = "nvim_lua" },
  }, {
    { name = "path" },
    fuzzy_path,
    { name = "git" },
    { name = "emoji" },
    { name = "fuzzy_buffer" },
    { name = "latex_symbols" },
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
  }, {
    { name = "cmdline_history" },
  }),
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, { fuzzy_path }, {
    { name = "cmdline" },
    { name = "cmdline_history" },
  }),
})

require("cmp_git").setup()
