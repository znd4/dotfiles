require("orgmode").setup_ts_grammar()

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"go",
		"gomod",
		"json",
		"lua",
		"markdown",
		"org",
		"python",
		"sql",
	},
	auto_install = true,
	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = { "org" },
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	indent = {
		enable = true,
	},
})
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

require("orgmode").setup({
	org_agenda_files = { "~/Dropbox/org/*", "~/my-orgs/**/*" },
	org_default_notes_file = "~/Dropbox/org/refile.org",
})
