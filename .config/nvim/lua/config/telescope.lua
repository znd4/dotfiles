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
        file_ignore_patterns = { "%.git/*", "rpc/*" },
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

local factory = function(func, ...)
    local args = { ... }
    return function()
        func(unpack(args))
    end
end

local builtin = require("telescope.builtin")

vimp.map_command("Buffers", factory(builtin.buffers))
-- local projects = ":Telescope projects<cr>"
local projects = factory(vim.cmd.Telescope, "projects")

vimp.map_command("Projects", projects)
vimp.map_command("Help", factory(builtin.help_tags))
vimp.map_command("GF", factory(builtin.git_files))
vimp.map_command("GS", factory(builtin.git_status))
vimp.map_command("Commands", factory(builtin.commands))
vimp.map_command("Files", factory(builtin.find_files))

-- vimp.nnoremap("<C-f>", telescope.find_files)

local nnoremap = function(...)
    vim.keymap.set("n", ...)
end

local leader = "<leader>"

nnoremap(leader .. "ff", factory(builtin.find_files, { hidden = true }), { desc = "Telescope find files" })
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
