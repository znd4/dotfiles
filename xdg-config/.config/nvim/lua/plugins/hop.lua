return {
  "phaazon/hop.nvim",
  branch = "v2", -- optional but strongly recommended
  config = function()
    -- you can configure Hop the way you like here; see :h hop-config
    local hop = require("hop")
    hop.setup({})
    local vimp = require("vimp")
    vimp.noremap("<ctrl-,>", function()
      -- hop.hint_char2()
      hop.hint_words({ multi_windows = true })
    end)
  end,
  dependencies = { "svermeulen/vimpeccable" },
}
