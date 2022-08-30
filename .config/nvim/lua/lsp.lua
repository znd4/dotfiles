require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"pyright",
		"sqls",
		"black",
		"sqlfluff",
		"lua-language-server",
		"yaml-language-server",
		"prettierd",
		"luaformatter",
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
			print("client name=" .. client.name)
			print("ft=" .. ft)
			local result
			if ft == "sql" then
				result = client.name ~= "sqls"
			elseif ft == "lua" then
				result = client.name ~= "sumneko_lua"
			else
				result = true
			end
			if result then
				print("formatting")
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
		print("enabling formatting")
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

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	if client.name == "yamlls" then
		client.server_capabilities.documentFormattingProvider = true
	end
	enable_formatting(client, bufnr)
	-- require("lsp-format").on_attach(client)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

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

local lsp_flags = {
	-- This is the default in Nvim 0.7+
	debounce_text_changes = 150,
}
local lspconfig = require("lspconfig")
-- lspconfig["pyright"].setup({
-- 	on_attach = on_attach,
-- 	flags = lsp_flags,
-- })
lspconfig.gopls.setup({
	on_attach = on_attach,
	settings = {
		gopls = {
			buildFlags = { "-tags=integration" },
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
			codelenses = {
				gc_details = true,
			},
		},
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

local nullls = require("null-ls")
nullls.setup({
	-- on_init = function(client)
	-- 	local path = client.workspace_folders[1].name
	-- 	for source
	-- 	client.config.sources
	-- end
	on_attach = on_attach,
	sources = {
		-- protobuf
		nullls.builtins.diagnostics.buf,
		nullls.builtins.formatting.buf,

		nullls.builtins.formatting.stylua,
		nullls.builtins.diagnostics.eslint,

		-- python
		nullls.builtins.formatting.black,
		nullls.builtins.formatting.isort,

		-- golang
		nullls.builtins.formatting.goimports,
		nullls.builtins.formatting.gofmt,

		-- Spellchecking
		nullls.builtins.completion.spell,

		-- sql
		nullls.builtins.formatting.sqlfluff,
		nullls.builtins.diagnostics.sqlfluff,
		-- nullls.builtins.formatting.sqlfluff.with({
		--     extra_args = { "--config=pyproject.toml" },
		-- }),
		-- nullls.builtins.diagnostics.sqlfluff.with({
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
	filetypes = { "yaml", "yml", "yaml.docker-compose" },
})

lspconfig.sumneko_lua.setup({
	on_attach = on_attach,
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
