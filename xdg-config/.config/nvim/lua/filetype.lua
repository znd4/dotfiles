vim.g.do_filetype_lua = 1
vim.filetype.add({
    extension = {
        hcl = "hcl",
        tf = "terraform",
        tfvars = "terraform",
        tfstate = "json",
        plist = "xml",
        shell = "bash",
        kbd = "clojure",
        ["tfstate.backup"] = "json",
    },
    filename = {
        [".terraformrc"] = "hcl",
        ["terraform.rc"] = "hcl",
        [".yamllint"] = "yaml",
        [".devcontainer.json"] = "jsonc",
        ["devcontainer.json"] = "jsonc",
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
