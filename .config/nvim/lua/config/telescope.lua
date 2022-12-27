local actions = require("telescope.actions")
local telescope = require("telescope")
telescope.setup({
    extensions = {
        zoxide = {
            mappings = {
                default = {
                    action = function(selection)
                        vim.cmd.cd({ selection.path })
                        vim.cmd.edit({ selection.path })
                    end,
                },
            },
        },
    },
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--trim", -- add this value
        },
        mappings = {
            n = {
                [","] = telescope.extensions.hop.hop,
            },
            i = {
                ["<C-,>"] = telescope.extensions.hop.hop, -- hop.hop_toggle_selection
                -- custom hop loop to multi selects and sending selected entries to quickfix list
                ["<C-space>"] = function(prompt_bufnr)
                    local opts = {
                        callback = actions.toggle_selection,
                        loop_callback = actions.send_selected_to_qflist,
                    }
                    require("telescope").extensions.hop._hop_loop(prompt_bufnr, opts)
                end,
            },
        },
    },
})
telescope.load_extension("hop")
