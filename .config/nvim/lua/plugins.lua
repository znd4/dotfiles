-- This file can be loaded by calling `lua require('plugins')` from your init.vim

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap =
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd([[packadd packer.nvim]])
end

return require("packer").startup({

	function(use)
		-- Packer can manage itself
		use("wbthomason/packer.nvim")

		use("norcalli/nvim_utils")
		use({
			"ray-x/go.nvim",
			requires = { "ray-x/guihua.lua" },
			config = function()
				require("go").setup()
			end,
		})
		-- use({
		-- 	"folke/noice.nvim",
		-- 	event = "VimEnter",
		-- 	config = function()
		-- 		require("noice").setup({ debug = true })
		-- 	end,
		-- 	requires = {
		-- 		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		-- 		"MunifTanjim/nui.nvim",
		-- 		"rcarriga/nvim-notify",
		-- 		"hrsh7th/nvim-cmp",
		-- 	},
		-- })
		-- use('tpope/vim-surround')
		use("tpope/vim-dotenv")

		use("fladson/vim-kitty")
		-- use('pedrohdz/vim-yaml-folds')
		-- use('gabrielelana/vim-markdown')

		use("vimwiki/vimwiki")

		-- use('preservim/nerdtree')

		-- open line in github
		use("ruanyl/vim-gh-line")

		-- direnv plugin
		use("direnv/direnv.vim")
		--
		--""""""""""""""
		-- Python plugins
		--""""""""""""""

		-- git plugin
		use("tpope/vim-fugitive")

		-- lazygit
		use("kdheepak/lazygit.nvim")

		use("earthly/earthly.vim")

		use({ "github/copilot.vim", after = "direnv.vim", config = [[vim.cmd.Copilot("restart")]] })
		-- use({
		-- 	"zbirenbaum/copilot.lua",
		-- 	event = "InsertEnter",
		-- 	config = function()
		-- 		vim.schedule(function()
		-- 			require("copilot").setup()
		-- 		end)
		-- 	end,
		-- })
		-- use({
		-- 	"zbirenbaum/copilot-cmp",
		-- 	after = { "copilot.lua" },
		-- 	config = function()
		-- 		require("copilot_cmp").setup()
		-- 	end,
		-- })

		-- use('junegunn/fzf', { 'do'): { -> fzf#install() } }
		-- use('junegunn/fzf.vim')

		-- Declare the list of plugins.
		use("tpope/vim-sensible")
		use("junegunn/seoul256.vim")

		-- Fish support
		use("dag/vim-fish")

		-- editorconfig
		use("editorconfig/editorconfig-vim")

		use("vito-c/jq.vim")
		use({
			"karb94/neoscroll.nvim",
			config = function()
				require("neoscroll").setup()
			end,
		})
		-- Lua
		use({
			"folke/which-key.nvim",
			config = function()
				require("which-key").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})
		use({ "stevearc/dressing.nvim" })
		-- use({
		-- 	"nmac427/guess-indent.nvim",
		-- 	config = function()
		-- 		require("guess-indent").setup({})
		-- 	end,
		-- })
		use({
			"AckslD/nvim-FeMaco.lua",
			config = function()
				require("femaco").setup({
					ft_from_lang = function(lang)
						if lang == "golang" then
							return "sql"
						end
						return lang
					end,
				})
			end,
		})
		use({ "echasnovski/mini.nvim", branch = "stable" })
		use({
			"kylechui/nvim-surround",
			tag = "*", -- Use for stability; omit to use `main` branch for the latest features
			config = function()
				require("nvim-surround").setup({
					-- Configuration here, or leave empty to use defaults
				})
			end,
		})

		-- Colorschemes
		use("folke/tokyonight.nvim")
		use("shaunsingh/moonlight.nvim")
		use("bluz71/vim-moonfly-colors")
		use("marko-cerovac/material.nvim")
		use("rmehri01/onenord.nvim")
		use("bluz71/vim-nightfly-guicolors")

		use({
			"phaazon/hop.nvim",
			branch = "v2", -- optional but strongly recommended
			config = function()
				-- you can configure Hop the way you like here; see :h hop-config
				local hop = require("hop")
				hop.setup({})
				local vimp = require("vimp")
				vimp.noremap(",", function()
					-- hop.hint_char2()
					hop.hint_words()
				end)
			end,
		})

		use({
			"lewis6991/gitsigns.nvim",
			config = function()
				require("gitsigns").setup({
					current_line_blame = true,
					yadm = { enable = true },
				})
			end,
		})

		use({
			"nvim-telescope/telescope-hop.nvim",
		})
		use({
			"nvim-telescope/telescope.nvim",
			requires = { { "nvim-lua/plenary.nvim" } },
			config = function()
				local actions = require("telescope.actions")
				local telescope = require("telescope")
				telescope.setup({
					extensions = {
						zoxide = {
							mappings = {
								default = {
									action = function(selection)
										vim.cmd.cd({ selection.path })
										vim.cmd.edit({ selection.path })
									end,
								},
							},
						},
					},
					defaults = {
						vimgrep_arguments = {
							"rg",
							"--color=never",
							"--no-heading",
							"--with-filename",
							"--line-number",
							"--column",
							"--smart-case",
							"--trim", -- add this value
						},
						mappings = {
							n = {
								[","] = telescope.extensions.hop.hop,
							},
							i = {
								["<C-,>"] = telescope.extensions.hop.hop, -- hop.hop_toggle_selection
								-- custom hop loop to multi selects and sending selected entries to quickfix list
								["<C-space>"] = function(prompt_bufnr)
									local opts = {
										callback = actions.toggle_selection,
										loop_callback = actions.send_selected_to_qflist,
									}
									require("telescope").extensions.hop._hop_loop(prompt_bufnr, opts)
								end,
							},
						},
					},
				})
				telescope.load_extension("hop")
			end,
		})
		use({
			"jvgrootveld/telescope-zoxide",
			after = "telescope.nvim",
			opt = false,
			config = function()
				require("telescope").load_extension("zoxide")
				vimp.nnoremap("<leader>" .. "fz", require("telescope").extensions.zoxide.list)
			end,
		})
		use({
			"nvim-telescope/telescope-fzf-native.nvim",
			after = "telescope.nvim",
			opt = false,
			run = "make",
			config = function()
				require("telescope").load_extension("fzf")
			end,
		})
		use({
			"cljoly/telescope-repo.nvim",
			requires = "nvim-telescope/telescope.nvim",
			after = "telescope.nvim",
			opt = false,
			config = function()
				require("telescope").load_extension("repo")
			end,
		})

		use({
			"pwntester/octo.nvim",
			requires = {
				"nvim-telescope/telescope.nvim",
				"nvim-lua/plenary.nvim",
				"kyazdani42/nvim-web-devicons",
			},
			config = function()
				require("octo").setup()
			end,
		})
		use({
			"akinsho/toggleterm.nvim",
			tag = "v2.*",
			config = function()
				require("toggleterm").setup({
					open_mapping = [[<c-.>]],
					insert_mappings = true,
					hide_numbers = true,
					close_on_exit = true,
					shade_terminals = false,
					winblend = 0,
					direction = "float",
					height = 20,
				})
			end,
		})

		-- Lua
		use({
			"folke/trouble.nvim",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("trouble").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})

		use({
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			"jose-elias-alvarez/null-ls.nvim",
		})
		use({ "ldelossa/litee.nvim", config = [[require("litee.lib").setup({})]] })
		use({
			"ldelossa/litee-calltree.nvim",
			after = "litee.nvim",
			config = function()
				require("litee.calltree").setup({})
			end,
		})
		use({ "ckipp01/stylua-nvim" })

		use({ "lukas-reineke/lsp-format.nvim" })

		--auto complete
		use({
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"saadparwaiz1/cmp_luasnip",
		})
		use("honza/vim-snippets")
		use("rafamadriz/friendly-snippets")
		use({ "L3MON4D3/LuaSnip", tag = "v1.*" })
		use({ "SirVer/ultisnips", requires = { { "honza/vim-snippets", rtp = "." } } })
		use({ "onsails/lspkind.nvim" })
		use({
			"hrsh7th/nvim-cmp",
			requires = {
				"quangnguyen30192/cmp-nvim-ultisnips",
				requires = {
					"nvim-treesitter/nvim-treesitter",
				},
			},
			config = function()
				require("completion")
			end,
		})
		use({
			"IndianBoy42/tree-sitter-just",
			config = function()
				require("nvim-treesitter.parsers").get_parser_configs().just = {
					install_info = {
						url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
						files = { "src/parser.c", "src/scanner.cc" },
						branch = "main",
						use_makefile = true,
						-- generate_requires_npm = false, -- if stand-alone parser without npm dependencies
						-- requires_generate_from_grammar = false,
					},
					maintainers = { "@IndianBoy42" },
				}
			end,
		})

		use({ "nvim-treesitter/playground" })

		use({
			"windwp/nvim-autopairs",
			after = "nvim-cmp",
			config = function()
				require("config.nvim-autopairs")
			end,
		})
		-- use({
		-- 	"TimUntersberger/neogit",
		-- 	requires = "nvim-lua/plenary.nvim",
		-- 	config = function()
		-- 		require("neogit").setup()
		-- 	end,
		-- })
		use("elihunter173/dirbuf.nvim")
		use({
			"kyazdani42/nvim-tree.lua",
			requires = {
				"kyazdani42/nvim-web-devicons", -- optional, for file icons
			},
			tag = "nightly", -- optional, updated every week. (see issue #1193)
			config = function()
				require("nvim-tree").setup({
					open_on_setup = false,
					sync_root_with_cwd = true,
					-- respect_buf_cwd = false,
					respect_buf_cwd = true,
					update_focused_file = {
						enable = true,
						update_root = true,
					},
					hijack_directories = { enable = false },
				})
			end,
		})

		-- using packer.nvim
		use({ "akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons" })
		use("nvim-treesitter/nvim-treesitter-textobjects")
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
			config = [[require("config.treesitter")]],
		})
		use({
			"nvim-orgmode/orgmode",
			config = function()
				require("orgmode").setup({})
			end,
		})
		use({
			"akinsho/org-bullets.nvim",
			config = function()
				require("org-bullets").setup()
			end,
		})

		use({
			"glacambre/firenvim",
			run = function()
				vim.fn["firenvim#install"](0)
			end,
		})

		use({
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
		})
		use({
			"ahmedkhalf/project.nvim",
			config = function()
				-- local statepath = vim.fn.stdpath("state")
				local datapath = vim.fn.stdpath("data")
				require("project_nvim").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
					ignore_lsp = { "null-ls" },
					show_hidden = true,
					datapath = datapath,
				})
				require("telescope").load_extension("projects")
			end,
			requires = "nvim-telescope/telescope.nvim",
		})
		use("svermeulen/vimpeccable")

		-- Automatically set up your configuration after cloning packer.nvim
		-- Put this at the end after all plugins
		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		autoremove = true,
		display = {
			open_fn = require("packer.util").float,
		},
	},
})
