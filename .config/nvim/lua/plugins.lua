-- This file can be loaded by calling `lua require('plugins')` from your init.vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    print("Trying to clone lazy.nvim to " .. lazypath)
    print(vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    }))
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- load scrollbar before gitsigns
    {
        "epwalsh/obsidian.nvim",
        lazy = true,
        event = { "BufReadPre " .. vim.fn.expand("~") .. "/Documents/obsidian-vault/**.md" },
        dependencies = {
            -- Required.
            "nvim-lua/plenary.nvim",

            -- Optional, for completion.
            "hrsh7th/nvim-cmp",

            -- Optional, for search and quick-switch functionality.
            "nvim-telescope/telescope.nvim",

            -- Optional, alternative to nvim-treesitter for syntax highlighting.
            "godlygeek/tabular",
            "preservim/vim-markdown",
        },
        opts = {
            dir = "~/Documents/obsidian-vault", -- no need to call 'vim.fn.expand' here
            -- see below for full list of options 👇
        },
        config = function(_, opts)
            require("obsidian").setup(opts)

            -- Optional, override the 'gf' keymap to utilize Obsidian's search functionality.
            -- see also: 'follow_url_func' config option below.
            vim.keymap.set("n", "gf", function()
                if require("obsidian").util.cursor_on_markdown_link() then
                    return "<cmd>ObsidianFollowLink<CR>"
                else
                    return "gf"
                end
            end, { noremap = false, expr = true })
        end,
    },
    { "petertriho/nvim-scrollbar", priority = 102,              config = true },
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
    { "declancm/cinnamon.nvim",    config = { centered = true } },
    "tpope/vim-dotenv",
    "norcalli/nvim_utils",
    "fladson/vim-kitty",
    -- split and join treesitter
    { "Wansmer/treesj",    config = true },
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
    {
        "glacambre/firenvim",
        -- Lazy load firenvim
        -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
        cond = not not vim.g.started_by_firenvim,
        build = function()
            require("lazy").load({ plugins = "firenvim", wait = true })
            vim.cmd([[packadd firenvim]])
        end,
        config = function()
            -- set lines to max of current lines value and 10
            vim.o.lines = math.max(vim.o.lines, 10)
            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                pattern = "colab.research.google.com_*.txt",
                cmd = "set ft=python",
            })
            print("in firenvim")
            vim.api.nvim_create_autocmd("UIEnter", {
                callback = function()
                    vim.g.gui_font_size = 12
                    vim.g.gui_font_face = "VictorMono"
                    -- set lines to max of current lines value and 10
                    -- after an asynchronous 1000 ms delay
                    print("in UIEnter")
                    vim.defer_fn(function()
                        print("UIEnter fired")
                        vim.g.lines = math.max(vim.g.lines, 10)
                        vim.o.columns = 110
                        vim.o.laststatus = 0
                    end, 2000)
                end,
            })
        end,
    },
    -- { "dccsillag/magma-nvim", build = ":UpdateRemotePlugins" },
    -- { "untitled-ai/jupyter_ascending.vim" },
    -- {
    --     "bfredl/nvim-ipy",
    --     config = function()
    --         require("config.nvim-ipy")
    --     end,
    -- },
    -- {
    --     "hkupty/iron.nvim",
    --     config = function()
    --         require("config.iron")
    --     end,
    -- },
    -- { "GCBallesteros/jupytext.vim" },
    -- {
    --     "GCBallesteros/vim-textobj-hydrogen",
    --     dependencies = {
    --         "kana/vim-textobj-line",
    --         "kana/vim-textobj-user",
    --     },
    -- },

    { "tpope/vim-fugitive",    dependencies = { "tpope/vim-rhubarb" } },
    "wsdjeg/vim-fetch",
    "kdheepak/lazygit.nvim",
    "earthly/earthly.vim",
    "tpope/vim-sensible",
    "junegunn/seoul256.vim",
    "dag/vim-fish",
    "editorconfig/editorconfig-vim",
    "vito-c/jq.vim",
    {
        "johmsalas/text-case.nvim",
        config = function()
            local textcase = require("textcase")
            textcase.setup({})
            local vimp = require("vimp")
            vimp.nnoremap("gas", function()
                textcase.current_word("to_snake_case")
            end)
            vimp.nnoremap("gaS", function()
                textcase.lsp_rename("to_snake_case")
            end)
        end,
    },

    {
        "folke/tokyonight.nvim",
        lazy = true,
        config = { transparent = false, style = "night" },
    },
    "shaunsingh/moonlight.nvim",
    "bluz71/vim-moonfly-colors",
    "marko-cerovac/material.nvim",
    "rmehri01/onenord.nvim",
    -- {
    --     "bluz71/vim-nightfly-guicolors",
    --     priority = 9001,
    --     lazy = false,
    --     config = function()
    --         vim.cmd.colorscheme("nightfly")
    --     end,
    -- },

    "honza/vim-snippets",
    "rafamadriz/friendly-snippets",
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = true,
    },
    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup()
            vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
        end,
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    "svermeulen/vimpeccable",

    {
        "https://codeberg.org/esensar/nvim-dev-container",
        config = {
            container_runtime = "podman",
        },
        build = function()
            vim.cmd.TSInstall("jsonc")
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },

    {
        "folke/which-key.nvim",
        config = true,
    },
    {
        "stevearc/dressing.nvim",
        config = {
            input = {
                insert_only = false,
            },
        },
    },
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
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function()
                    -- default options: exact mode, multi window, all directions, with a backdrop
                    require("flash").jump()
                end,
                desc = "Flash",
            },
            {
                "S",
                mode = "n",
                -- mode = { "n", "o", "x" },
                function()
                    require("flash").treesitter()
                end,
                desc = "Flash Treesitter",
            },
            {
                "r",
                mode = "o",
                function()
                    require("flash").remote()
                end,
                desc = "Remote Flash",
            },
        },
    },

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
                hop.hint_words({ multi_windows = true })
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
            "nvim-tree/nvim-web-devicons",
        },
        config = true,
    },
    {
        "jakewvincent/mkdnflow.nvim",
        config = {
            links = {
                -- TODO: add highlighting for links, then re-enable this
                -- conceal = true,
            },
            mappings = {
                MkdnTab = { "i", "<Tab>" },
                MkdnSTab = { "i", "<S-Tab>" },
                MkdnTableNextCell = false,
                MkdnTablePrevCell = false,
            },
        },
    },
    -- {
    --     "nvim-neorg/neorg",
    --     build = ":Neorg sync-parsers",
    --     opts = {
    --         load = {
    --             ["core.defaults"] = {}, -- Loads default behaviour
    --             ["core.norg.concealer"] = {}, -- Adds pretty icons to your documents
    --             ["core.norg.dirman"] = { -- Manages Neorg workspaces
    --                 config = {
    --                     workspaces = {
    --                         notes = "~/notes",
    --                     },
    --                 },
    --             },
    --         },
    --     },
    --     dependencies = { { "nvim-lua/plenary.nvim" } },
    -- },
    {
        "akinsho/toggleterm.nvim",
        version = "2.*",
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<c-q>]],
                insert_mappings = true,
                hide_numbers = true,
                close_on_exit = true,
                shade_terminals = false,
                winblend = 0,
                direction = "float",
                height = 20,
                shell = "zsh",
            })
        end,
    },

    -- Lua
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = true,
    },
    {
        "ldelossa/gh.nvim",
        dependencies = { "ldelossa/litee.nvim" },
        config = function()
            require("litee.lib").setup()
            require("litee.gh").setup()
        end,
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
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            { "L3MON4D3/LuaSnip",         version = "1.*" },
            "hrsh7th/nvim-cmp",
            "onsails/lspkind.nvim",
            "nvim-treesitter/nvim-treesitter",

            -- cmp sources
            "davidsierradz/cmp-conventionalcommits",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-nvim-lua", -- Optional
            "dmitmel/cmp-cmdline-history",
            "petertriho/cmp-git",
            { "tzachar/cmp-fuzzy-path",   dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" } },
            { "tzachar/cmp-fuzzy-buffer", dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" } },
            "saadparwaiz1/cmp_luasnip",

            "lukas-reineke/lsp-format.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
        },
        priority = 102,
        branch = "v2.x",
        config = function()
            require("config.lsp")
        end,
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
        config = function()
            require("config.null-ls") -- require your null-ls config here (example below)
        end,
    },
    --{
    --    dependencies = {},
    --    priority = 1, -- load after cmp (and most plugins)
    --    config = function()
    --        require("config.lsp")
    --    end,
    --},
    {
        "mfussenegger/nvim-dap",
        dependencies = { "leoluz/nvim-dap-go" },
        config = function()
            local dapgo = require("dap-go")
            dapgo.setup()
            local vimp = require("vimp")
            vimp.nnoremap("<leader>dt", function()
                dapgo.debug_test()
            end)
            local dap = require("dap")
            vimp.nnoremap({ "silent" }, "<F5>", dap.continue, { desc = "debugger continue" })
            vimp.nnoremap({ "silent" }, "<F10>", dap.step_over, { desc = "debugger step over" })
            vimp.nnoremap({ "silent" }, "<F11>", dap.step_into, { desc = "debugger step into" })
            vimp.nnoremap({ "silent" }, "<F12>", dap.step_out, { desc = "debugger step out" })
            vimp.nnoremap({ "silent" }, "<Leader>b", dap.toggle_breakpoint, { desc = "debugger toggle breakpoint" })
            vimp.nnoremap({ "silent" }, "<Leader>B", function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "debugger set breakpoint condition" })
            vimp.nnoremap({ "silent" }, "<Leader>lp", function()
                require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end, { desc = "debugger set log point message" })
            vimp.nnoremap({ "silent" }, "<Leader>ds", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.scopes)
            end, { desc = "Open scopes in sidebar" })
            vimp.nnoremap({ "silent" }, "<Leader>dh", function()
                require("dap.ui.widgets").hover()
            end, { desc = "View value of expression under cursor" })
            vimp.nnoremap({ "silent" }, "<Leader>dr", dap.repl.open, { desc = "open debugger repl" })
            vimp.nnoremap({ "silent" }, "<Leader>dl", dap.run_last, { desc = "run last debugger" })
        end,
    },
    {
        "crispgm/nvim-go",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- TODO - enable this + figure out what it is
            "rcarriga/nvim-notify",
        },
        build = ":GoInstallBinaries",
        config = function()
            require("go").setup({
                -- notify: use nvim-notify
                auto_format = false,
                auto_lint = false,
                notify = true,
                auto_format = false,
                lint_prompt_style = "vt",
                -- auto_lint = false,
            })
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
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- optional, for file icons
        },
        tag = "nightly",                   -- optional, updated every week. (see issue #1193)
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
    { "akinsho/bufferline.nvim", version = "2.*", dependencies = { "nvim-tree/nvim-web-devicons" } },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("config.treesitter")
        end,
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", "HiPhish/nvim-ts-rainbow2" },
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
                detection_methods = { "pattern", "lsp" },
                patterns = { ".git", ".hg", ".svn", "package.json" },
                show_hidden = true,
                datapath = datapath,
            })
            require("telescope").load_extension("projects")
        end,
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
}, {
    concurrency = 20,
    install = {
        colorscheme = { "tokyonight" },
    },
})
