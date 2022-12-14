local exists

local leader = "<leader>"

local vimp
exists, vimp = pcall(require, "vimp")
if not exists then
    print("vimp not installed")
    return
end

local telescope
exists, telescope = pcall(require, "telescope.builtin")
if not exists then
    print("telescope not installed")
    return
end

local telex = require("telescope").extensions

vimp.map_command("Buffers", function()
    telescope.buffers()
end)
-- local projects = ":Telescope projects<cr>"
local projects = function()
    vim.cmd.Telescope("projects")
end

vimp.map_command("Projects", projects)
vimp.map_command("Help", telescope.help_tags)
vimp.map_command("Files", telescope.find_files)
vimp.nnoremap("<C-f>", telescope.find_files)

local nnoremap = function(...)
    vim.keymap.set("n", ...)
end

nnoremap(leader .. "ff", function()
    telescope.find_files({ hidden = true })
end, { desc = "Telescope find files" })
nnoremap(leader .. "fg", telescope.live_grep, { desc = "Telescope grep contents" })
nnoremap(leader .. "fb", telescope.buffers, { desc = "Telescope buffers" })
-- nnoremap(leader .. "ft", telescope.builtins, { desc = "Telescope buffers" })
nnoremap(leader .. "fh", telescope.help_tags, { desc = "Telescope help" })
nnoremap(leader .. "fp", projects, { desc = "Telescope projects" })
-- nnoremap(leader .. "fd", telescope.lsp_document_symbols, { desc = "Telescope lsp_document_symbols" })
nnoremap(leader .. "fd", telescope.current_buffer_fuzzy_find, { desc = "Telescope lsp_document_symbols" })
nnoremap(leader .. "fo", ":Octo actions<CR>")
nnoremap(leader .. "fl", telescope.lsp_dynamic_workspace_symbols, { desc = "Telescope lsp_dynamic_workspace_symbols" })
-- vimp.nnoremap(leader .. "fp", projects)
nnoremap(leader .. "fc", telescope.commands, { desc = "Telescope commands" })
nnoremap(leader .. "fm", telescope.keymaps, { desc = "Telescope commands" })

vimp.map_command("GF", function()
    telescope.git_files()
end)

vimp.map_command("Commands", function()
    telescope.commands()
end)
