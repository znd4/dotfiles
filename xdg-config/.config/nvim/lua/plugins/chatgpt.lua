return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = {
    api_key_cmd = "op read op://private/openai/credential --no-newline",
  },
  cmd = {
    "ChatGPT",
    "ChatGPTRun",
    "ChatGPTActAs",
    "ChatGPTCompleteCode",
    "ChatGPTEditWithInstructions",
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
