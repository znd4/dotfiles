local org_dir = os.getenv("HOME") .. "/Documents/org"

require("orgmode").setup({
    org_agenda_files = { org_dir .. "/*" },
    org_default_notes_file = org_dir .. "/refile.org",
    org_agenda_templates = {
        m = {
            description = "Magic card wishlist",
            target = org_dir .. "/magic_wishlist.org",
            template = "%^{Card name}",
        },
        t = { description = "Task", template = "* TODO %?\n  %u" },
    },
})
