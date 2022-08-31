require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"bash-language-server",
		"black",
		"lua-language-server",
		"luaformatter",
		"prettierd",
		"pyright",
		"sqlfluff",
		"sqls",
		"yaml-language-server",
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

local capabilities = vim.lsp.protocol.make_client_capabilities()

local module_exists, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if module_exists then
	capabilities = cmp_nvim_lsp.update_capabilities(capabilities) --nvim-cmp
	capabilities.textDocument.completion.completionItem.snippetSupport = true
else
	print("cmp_nvim_lsp not installed")
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	if client.name == "yamlls" then
		client.server_capabilities.documentFormattingProvider = true
	end
	enable_formatting(client, bufnr)
	-- require("lsp-format").on_attach(client)
	-- Enable completion triggered by <c-x><c-o>
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
end

local lspconfig = require("lspconfig")

lspconfig.bashls.setup({})

-- lspconfig["pyright"].setup({
-- 	on_attach = on_attach,
-- 	flags = lsp_flags,
-- })
lspconfig.gopls.setup({
	cmd = { "gopls" },
	on_attach = on_attach,
	capabilities = capabilities,
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
	capabilities = capabilities,
})

local null_ls = require("null-ls")
null_ls.setup({
	-- on_init = function(client)
	-- 	local path = client.workspace_folders[1].name
	-- 	for source
	-- 	client.config.sources
	-- end
	on_attach = on_attach,
	capabilities = capabilities,
	sources = {
		-- protobuf
		null_ls.builtins.diagnostics.buf,
		null_ls.builtins.formatting.buf,

		null_ls.builtins.formatting.stylua,
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

		-- sql
		null_ls.builtins.formatting.sqlfluff,
		null_ls.builtins.diagnostics.sqlfluff,
		-- null_ls.builtins.formatting.sqlfluff.with({
		--     extra_args = { "--config=pyproject.toml" },
		-- }),
		-- null_ls.builtins.diagnostics.sqlfluff.with({
		--     extra_args = { "--config=pyproject.toml" },
		-- }),
	},
})

lspconfig.yamlls.setup({
	settings = {
		yaml = {
			format = {
				enable = true,
			},
		},
		schemaStore = {
			url = "https://www.schemastore.org/api/json/catalog.json",
			enable = true,
		},
	},
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "yaml", "yml", "yaml.docker-compose" },
})

lspconfig.sumneko_lua.setup({
	on_attach = on_attach,
	capabilities = capabilities,
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

lspconfig.pylsp.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { "W391" },
					maxLineLength = 100,
				},
				black = {
					enable = true,
				},
				-- jedi = {
				--     -- TODO - Add something to on_attach that finds virtual environment path
				--     environment = environment
				-- }
			},
		},
	},
})

vim.opt.termguicolors = true
