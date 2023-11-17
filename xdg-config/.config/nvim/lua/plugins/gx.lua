-- if the current neovim version is 0.10.0 or greater, then return nothing
if vim.fn.has("nvim-0.10.0") == 1 then
  print("gx.nvim: neovim version is 0.10.0 or greater, skipping setup")
  return
end

return {
  "chrishrb/gx.nvim",
  event = { "BufEnter" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = true, -- default settings
}
