local org_dir = os.getenv("HOME") .. "/Documents/org"

require("orgmode").setup({
    org_agenda_files = { org_dir .. "/*" },
    org_default_notes_file = org_dir .. "/refile.org",
})
