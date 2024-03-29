local vault_path = os.getenv("OBSIDIAN_VAULT") or vim.fn.expand("~") .. "/obsidian-vault"
return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  cmd = {
    "ObsidianSearch",
    "ObsidianQuickSwitch",
    "ObsidianNew",
    "ObsidianOpen",
  },
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre "
      .. vault_path
      .. "/**.md",
    -- "BufReadPre path/to/my-vault/**.md",
    -- "BufNewFile path/to/my-vault/**.md",
  },
  keys = {
    {
      "<leader>c",
      function()
        local Path = require("plenary.path")
        local fp = Path:new(vault_path):joinpath("journals", os.date("%Y_%m_%d.md"))
        fp:touch()
        vim.cmd.edit(fp:absolute())
        -- emit 'Go- TODO ' after opening the file
        vim.api.nvim_feedkeys("Go- TODO ", "n", true)
      end,
    },
    { "<leader>os", vim.cmd.ObsidianSearch },
    { "<leader>on", vim.cmd.ObsidianQuickSwitch },
  },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- for searching
    "nvim-telescope/telescope.nvim",

    -- for completion
    "hrsh7th/nvim-cmp",

    -- Optional, alternative to nvim-treesitter for syntax highlighting.
    "nvim-treesitter/nvim-treesitter",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = vault_path,
      },
    },
  },
}
