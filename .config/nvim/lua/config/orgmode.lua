local org_dir = os.getenv("HOME") .. "/Dropbox/org/"
-- mkdir if not exist
if vim.fn.isdirectory(org_dir) == 0 then
    vim.fn.mkdir(org_dir, "p")
end

require("orgmode").setup({
    org_agenda_files = { org_dir .. "/*" },
    org_default_notes_file = org_dir .. "refile.org",
    org_agenda_templates = {
        m = {
            description = "Magic card wishlist",
            target = org_dir .. "magic_wishlist.org",
            template = "%^{Card name}",
        },
        j = {
            description = "Jobs to apply to",
            target = org_dir .. "jobs.org",
            template = "* TODO %?\n  %u",
        },
        t = { description = "Task", template = "* TODO %?\n  %u" },
    },
})
