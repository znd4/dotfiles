-- vim.env.CURL_CA_BUNDLE = "/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
vim.opt_global.tabstop = 4
vim.opt_global.shiftwidth = 4
vim.g.mapleader = " "

vim.g.python3_host_prog = "python3.10"
vim.o.relativenumber = true

if vim.g.neovide ~= nil then
	vim.cmd.cd()
end

require("plugins")
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

-- vim.cmd.colorscheme("tokyonight")
vim.cmd.colorscheme("onenord")
vim.cmd.colorscheme("nightfly")
-- vim.cmd.colorscheme("material")
-- vim.g.material_style = "deep ocean"
