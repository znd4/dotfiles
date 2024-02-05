-- vim.env.CURL_CA_BUNDLE = "/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
require("env")
require("set")

vim.g.mapleader = " "

vim.g.python3_host_prog = "python3"

-- set clipboard+=unnamedplus
vim.o.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "custom_clipboard",
  copy = {
    ["+"] = { "cb", "copy" },
    ["*"] = { "cb", "copy" },
  },
  paste = {
    ["+"] = { "cb", "paste" },
    ["*"] = { "cb", "paste" },
  },
  cache_enabled = 1,
}

-- TODO - use `nvm exec 17 which node` to set this
-- vim.g.copilot_node_command = "/Users/zdufour/.nvm/versions/node/v17.9.1/bin/node"

if vim.g.neovide ~= nil then
  print("changing directory to home")
  vim.cmd.cd()
end

require("colorscheme")

require("config.lazy")
vim.cmd.colorscheme("tokyonight")

require("neovide")
require("fonts")
require("mappings")
require("commands")

if vim.fn.executable("fd") ~= 1 then
  print("please brew install fd")
end
if vim.fn.executable("rg") ~= 1 then
  print("please brew install ripgrep")
end

require("filetype")
