return {
  "phaazon/hop.nvim",
  branch = "v2", -- optional but strongly recommended
  config = function()
    -- you can configure Hop the way you like here; see :h hop-config
    local hop = require("hop")
    hop.setup({})
  end,
  keys = {
    {
      "<A-.>",
      function()
        require("hop").hint_words({ multi_windows = true })
      end,
      desc = "Hop words",
    },
  },
  dependencies = { "svermeulen/vimpeccable" },
}
