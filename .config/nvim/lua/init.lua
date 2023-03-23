-- vim.env.CURL_CA_BUNDLE = "/Library/Application Support/Netskope/STAgent/download/nscacert.pem"
require("set")

vim.g.mapleader = " "

vim.g.python3_host_prog = "python3"

-- TODO - use `nvm exec 17 which node` to set this
-- vim.g.copilot_node_command = "/Users/zdufour/.nvm/versions/node/v17.9.1/bin/node"

if vim.g.neovide ~= nil then
    print("changing directory to home")
    vim.cmd.cd()
end

require("colorscheme")

require("plugins")

require("neovide")
require("fonts")
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

vim.g.do_filetype_lua = 1
vim.filetype.add({
    extension = {
        hcl = "hcl",
        tf = "terraform",
        tfvars = "terraform",
        tfstate = "json",
        plist = "xml",
        shell = "bash",
        ["tfstate.backup"] = "json",
    },
    filename = {
        [".terraformrc"] = "hcl",
        ["terraform.rc"] = "hcl",
        [".yamllint"] = "yaml",
    },
    pattern = {
        ["${HOME}/%.ssh/config%.d/.*"] = "sshconfig",
        [".*"] = {
            priority = -math.huge,
            function(path, bufnr)
                local content = vim.filetype.getlines(bufnr, 1)
                if vim.filetype.matchregex(content, [[^#!.*\<node\>]]) then
                    return "javascript"
                end
            end,
        },
    },
})
