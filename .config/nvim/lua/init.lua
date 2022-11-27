
-- vim.env.CURL_CA_BUNDLE = "/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
vim.opt_global.tabstop = 4
vim.opt_global.shiftwidth = 4
vim.g.mapleader = " "

vim.g.python3_host_prog = "python3"
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"

require("plugins")

require("colorscheme")
require("neovide")

require("fonts")
require("lsp")
require("mappings")
require("commands")

if vim.fn.executable("fd") ~= 1 then
	print("please brew install fd")
end
if vim.fn.executable("lolcate") ~= 1 then
	print("please cargo install lolcate-rs")
end
if vim.fn.executable("rg") ~= 1 then
	print("please brew install ripgrep")
end
