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

		use("direnv/direnv.vim")
		use({
			"nvim-telescope/telescope.nvim",
			requires = { { "nvim-lua/plenary.nvim" } },
		})
		use({
			"cljoly/telescope-repo.nvim",
			requires = "nvim-telescope/telescope.nvim",
			config = function()
				require("telescope").setup()
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
					open_mapping = [[<c-\>]],
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

		use({ "ckipp01/stylua-nvim" })

		use({ "lukas-reineke/lsp-format.nvim" })

		--auto complete
		use({
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
		})
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
			"windwp/nvim-autopairs",
			after = "nvim-cmp",
			config = function()
				require("config.nvim-autopairs")
			end,
		})
		use({
			"kyazdani42/nvim-tree.lua",
			requires = {
				"kyazdani42/nvim-web-devicons", -- optional, for file icons
			},
			tag = "nightly", -- optional, updated every week. (see issue #1193)
			config = function()
				require("nvim-tree").setup()
			end,
		})

		-- using packer.nvim
		use({ "akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons" })
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
		})
		use({
			"nvim-orgmode/orgmode",
			config = function()
				require("orgmode").setup({})
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
				print("Running project.nvim config")
				require("project_nvim").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
					ignore_lsp = { "null-ls" },
				})
				require("telescope").load_extension("projects")
			end,
			requires = "nvim-telescope/telescope.nvim",
		})
		use("svermeulen/vimpeccable")
		use("folke/tokyonight.nvim")

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
