local cmp_setup = function()
	local loaded, cmp = pcall(require, "cmp")
	if not loaded then
		return
	end
	if cmp == nil then
		print("nvim-cmp not installed")
		return
	end

	local function cmp_map(...)
		return cmp.mapping(..., { "i", "s", "c" })
	end

	local function filter_mode(mappings, mode)
		local res = {}
		for k, v in pairs(mappings) do
			if v[mode] then
				res[k] = { [mode] = v[mode] }
			end
		end
		return res
	end

	local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

	local mappings = { -- Preset: ^n, ^p, ^y, ^e, you know the drill..
		["<Down>"] = { i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
		["<Up>"] = { i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
		-- ["<C-n>"] = cmp_map(cmp_ultisnips_mappings.compose({ "jump_forwards", "select_next_item" })),
		["<C-n>"] = {
			i = cmp_ultisnips_mappings.compose({ "jump_forwards", "select_next_item" }),
			c = function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end,
		},
		["<C-p>"] = cmp_map(cmp_ultisnips_mappings.jump_backwards),
		["<C-b>"] = cmp_map(cmp.mapping.scroll_docs(-4)),
		["<C-f>"] = cmp_map(cmp.mapping.scroll_docs(4)),
		["<C-Space>"] = cmp_map(cmp.mapping.complete()),
		["<Tab>"] = { c = cmp.mapping.complete() },
		["<C-e>"] = {
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		},
		["<CR>"] = cmp_map(cmp.mapping.confirm({ select = false })),
	}

	local lspkind = require("lspkind")

	cmp.setup({
		formatting = {
			format = lspkind.cmp_format({
				mode = "symbol",
				maxwidth = 50,
			}),
		},
		snippet = {
			expand = function(args)
				vim.fn["UltiSnips#Anon"](args.body)
			end,
		},
		sources = {
			{ name = "nvim_lsp" },
			{ name = "ultisnips" },
			{ name = "path" },
			{ name = "buffer", keyword_length = 2 },
			{ name = "emoji", insert = true },
			{ name = "nvim_lua" },
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert(filter_mode(mappings, "i")),
		completion = { autocomplete = true },
	})
	local cmdline_mappings = cmp.mapping.preset.cmdline(filter_mode(mappings, "c"))
	local cmdline_view = { entries = "wildmenu" }
	cmdline_view = { entries = "custom" }

	cmp.setup.cmdline(":", {
		mapping = cmdline_mappings,
		view = cmdline_view,
		sources = {
			{ name = "cmdline" },
			{ name = "path" },
		},
		completion = { autocomplete = true },
	})

	cmp.setup.cmdline("/", {
		mapping = cmdline_mappings,
		view = cmdline_view,
		sources = {
			{ name = "buffer" },
		},
		completion = { autocomplete = true },
	})
	-- Set configuration for specific filetype.
	cmp.setup.filetype("gitcommit", {
		sources = cmp.config.sources({
			{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
		}, {
			{ name = "buffer" },
		}),
	})
	vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
		callback = function()
			local line = vim.api.nvim_get_current_line()
			local cursor = vim.api.nvim_win_get_cursor(0)[2]

			local current = string.sub(line, cursor, cursor + 1)
			if current == "." or current == "," or current == " " then
				require("cmp").close()
			end

			local before_line = string.sub(line, 1, cursor + 1)
			local after_line = string.sub(line, cursor + 1, -1)
			if not string.match(before_line, "^%s+$") then
				if after_line == "" or string.match(before_line, " $") or string.match(before_line, "%.$") then
					require("cmp").complete()
				end
			end
		end,
		pattern = "*",
	})
	--  see https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-add-visual-studio-code-dark-theme-colors-to-the-menu
	vim.cmd([[
  highlight! link CmpItemMenu Comment
  " gray
  highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
  " blue
  highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
  highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
  " light blue
  highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
  " pink
  highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
  highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
  " front
  highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
  highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
  highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
]])
end

cmp_setup()
vim.opt.completeopt = { "menu", "menuone", "noselect" }
