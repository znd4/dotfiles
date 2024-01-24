return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, for file icons
  },
  tag = "nightly", -- optional, updated every week. (see issue #1193)
  config = {
    view = {
      side = "right",
      width = {
        max = -1,
      },
    },
    sync_root_with_cwd = true,
    -- respect_buf_cwd = false,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    hijack_directories = { enable = false },
  },
}
