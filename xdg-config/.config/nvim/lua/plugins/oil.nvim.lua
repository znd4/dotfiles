return {
  "stevearc/oil.nvim",
  config = {
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    {
      "-",
      require("oil").open,
      "Open parent directory",
    },
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
