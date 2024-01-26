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
      function()
        require("oil").open()
      end,
      "Open parent directory",
    },
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
