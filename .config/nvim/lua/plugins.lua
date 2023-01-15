-- This file can be loaded by calling `lua require('plugins')` from your init.vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- load scrollbar before gitsigns
    { "petertriho/nvim-scrollbar", priority = 102, config = true },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                current_line_blame = true,
                yadm = { enable = true },
            })
            require("scrollbar.handlers.gitsigns").setup()
        end,
        priority = 101,
    },
    -- smooth scrolling
    { "declancm/cinnamon.nvim", config = { centered = true } },
    "tpope/vim-dotenv",
    "norcalli/nvim_utils",
    "fladson/vim-kitty",
    -- split and join treesitter
    { "Wansmer/treesj", config = true },
    -- "vimwiki/vimwiki",
    "ruanyl/vim-gh-line",
    { "direnv/direnv.vim", priority = 102 },
    {
        "github/copilot.vim",
        priority = 101,
        config = function()
            require("config.copilot")
        end,
    },

    { "tpope/vim-fugitive", dependencies = { "tpope/vim-rhubarb" } },
    "wsdjeg/vim-fetch",
    "kdheepak/lazygit.nvim",
    "earthly/earthly.vim",
    "tpope/vim-sensible",
    "junegunn/seoul256.vim",
    "dag/vim-fish",
    "editorconfig/editorconfig-vim",
    "vito-c/jq.vim",

    "folke/tokyonight.nvim",
    "shaunsingh/moonlight.nvim",
    "bluz71/vim-moonfly-colors",
    "marko-cerovac/material.nvim",
    "rmehri01/onenord.nvim",
    {
        "bluz71/vim-nightfly-guicolors",
        priority = 9001,
        lazy = false,
        config = function()
            vim.cmd.colorscheme("nightfly")
        end,
    },

    "honza/vim-snippets",
    "rafamadriz/friendly-snippets",
    "elihunter173/dirbuf.nvim",

    "svermeulen/vimpeccable",

    {
        "folke/which-key.nvim",
        config = true,
    },
    { "stevearc/dressing.nvim" },
    {
        "AckslD/nvim-FeMaco.lua",
        config = {
            ft_from_lang = function(lang)
                if lang == "golang" then
                    return "sql"
                end
                return lang
            end,
        },
    },
    { "echasnovski/mini.nvim", branch = "stable" },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = true,
    },

    -- Colorschemes

    {
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
        dependencies = { "svermeulen/vimpeccable" },
    },
    "nvim-telescope/telescope-hop.nvim",
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("config.telescope")
        end,
        priority = 2,
    },
    {
        "jvgrootveld/telescope-zoxide",
        priority = 1,
        config = function()
            require("telescope").load_extension("zoxide")
            require("vimp").nnoremap("<leader>" .. "fz", require("telescope").extensions.zoxide.list)
        end,
        dependencies = { "svermeulen/vimpeccable" },
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        priority = 1,
        build = "make",
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },
    {
        "cljoly/telescope-repo.nvim",
        priority = 1,
        config = function()
            require("telescope").load_extension("repo")
        end,
    },

    {
        "pwntester/octo.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons",
        },
        config = true,
    },
    {
        "akinsho/toggleterm.nvim",
        version = "2.*",
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
    },

    -- Lua
    {
        "folke/trouble.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = true,
    },

    {
        "ldelossa/litee.nvim",
        priority = 2,
        config = function()
            require("litee.lib").setup({})
        end,
    },
    {
        "ldelossa/litee-calltree.nvim",
        priority = 1,
        config = function()
            require("litee.calltree").setup({})
        end,
    },
    { "ckipp01/stylua-nvim" },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            { "L3MON4D3/LuaSnip", version = "1.*" },
            { "SirVer/ultisnips", dependencies = { "honza/vim-snippets", rtp = "." } },
            "onsails/lspkind.nvim",
            "quangnguyen30192/cmp-nvim-ultisnips",
            "nvim-treesitter/nvim-treesitter",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-emoji",
            "saadparwaiz1/cmp_luasnip",
        },
        priority = 102,
        config = function()
            require("completion")
        end,
    },
    {
        "williamboman/mason.nvim",
        dependencies = {
            "lukas-reineke/lsp-format.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "jose-elias-alvarez/null-ls.nvim",
        },
        priority = 1, -- load after cmp (and most plugins)
        config = function()
            require("config.lsp")
        end,
    },
    {
        "windwp/nvim-autopairs",
        priority = 101,
        config = function()
            require("config.nvim-autopairs")
        end,
    },
    {
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
    },
    { "nvim-treesitter/playground" },
    {
        "kyazdani42/nvim-tree.lua",
        dependencies = {
            "kyazdani42/nvim-web-devicons", -- optional, for file icons
        },
        tag = "nightly", -- optional, updated every week. (see issue #1193)
        config = {
            open_on_setup = false,
            sync_root_with_cwd = true,
            -- respect_buf_cwd = false,
            respect_buf_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            },
            hijack_directories = { enable = false },
        },
    },
    { "akinsho/bufferline.nvim", version = "2.*", dependencies = { "kyazdani42/nvim-web-devicons" } },
    {
        "nvim-treesitter/nvim-treesitter",

        build = ":TSUpdate",
        config = function()
            require("config.treesitter")
        end,
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    },

    {
        "nvim-orgmode/orgmode",
        config = function()
            require("config.orgmode")
        end,
    },
    {
        "akinsho/org-bullets.nvim",
        config = true,
    },
    {
        "numToStr/Comment.nvim",
        config = true,
    },
    {
        "ahmedkhalf/project.nvim",
        config = function()
            -- local statepath = vim.fn.stdpath("state")
            local datapath = vim.fn.stdpath("data")
            require("project_nvim").setup({
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                ignore_lsp = { "null-ls", "terraform_lsp" },
                show_hidden = true,
                datapath = datapath,
            })
            require("telescope").load_extension("projects")
        end,
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
}, {
    install = {
        colorscheme = { "nightfly" },
    },
})
