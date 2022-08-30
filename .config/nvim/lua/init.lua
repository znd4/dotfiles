vim.env.CURL_CA_BUNDLE = "/Library/Application Support/Netskope/STAgent/download/nscacert.pem"

require("plugins")
require("fonts")
require("lsp")
require("treesitter")
require("mappings")

if vim.fn.executable("fd") ~= 1 then
	print("please brew install fd")
end
if vim.fn.executable("lolcate") ~= 1 then
	print("please cargo install lolcate-rs")
end
vim.cmd([[colorscheme tokyonight]])
-- TODO - Implement system clipboard interaction with <D-c> and <D-v>
