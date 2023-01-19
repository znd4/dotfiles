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
                -- map backspace to delete_buffer
                ["<BS>"] = actions.delete_buffer,
            },
            i = {
                ["<C-BS>"] = actions.delete_buffer,
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

local vimp = require("vimp")

vimp.map_command("Buffers", function()
    telescope.buffers()
end)
-- local projects = ":Telescope projects<cr>"
local projects = function()
    vim.cmd.Telescope("projects")
end

vimp.map_command("Projects", projects)
vimp.map_command("Help", function()
    telescope.help_tags()
end)
vimp.map_command("GF", function()
    telescope.git_files()
end)
vimp.map_command("GS", function()
    telescope.git_status()
end)
vimp.map_command("Commands", function()
    telescope.commands()
end)
vimp.map_command("Files", function()
    telescope.find_files()
end)

-- vimp.nnoremap("<C-f>", telescope.find_files)

local nnoremap = function(...)
    vim.keymap.set("n", ...)
end

local leader = "<leader>"

local builtin = require("telescope.builtin")

nnoremap(leader .. "ff", function()
    builtin.find_files({ hidden = true })
end, { desc = "Telescope find files" })
nnoremap(leader .. "fg", builtin.live_grep, { desc = "Telescope grep contents" })
nnoremap(leader .. "fb", builtin.buffers, { desc = "Telescope buffers" })
-- nnoremap(leader .. "ft", builtin.builtins, { desc = "Telescope buffers" })
nnoremap(leader .. "fh", builtin.help_tags, { desc = "Telescope help" })
nnoremap(leader .. "fp", projects, { desc = "Telescope projects" })
-- nnoremap(leader .. "fd", builtin.lsp_document_symbols, { desc = "Telescope lsp_document_symbols" })
nnoremap(leader .. "fd", builtin.current_buffer_fuzzy_find, { desc = "Telescope lsp_document_symbols" })
nnoremap(leader .. "fl", builtin.lsp_dynamic_workspace_symbols, { desc = "Telescope lsp_dynamic_workspace_symbols" })
-- vimp.nnoremap(leader .. "fp", projects)
nnoremap(leader .. "fc", builtin.commands, { desc = "Telescope commands" })
nnoremap(leader .. "fs", builtin.git_status, { desc = "Search git status" })
nnoremap(leader .. "fm", builtin.keymaps, { desc = "Telescope keymaps" })
