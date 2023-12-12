-- neovide-specific configuration
if vim.g.neovide == nil then
  return
end

local function get_background_color()
  local normal = vim.api.nvim_exec("hi normal", true)
  local color = string.match(normal, "guibg=(#%w+)")
  local transparency = vim.fn.printf("%x", vim.fn.float2nr(255 * vim.g.transparency))
  return color .. transparency
end

vim.cmd.cd()
vim.g.neovide_transparency = 0.0
vim.g.transparency = 0.95
vim.g.magic = true
vim.g.neovide_fullscreen = true
vim.g.neovide_confirm_quit = true
vim.g.neovide_background_color = get_background_color()
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_input_use_logo = true
