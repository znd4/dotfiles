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

local nnoremap = function(...)
    vim.keymap.set("n", ...)
end
nnoremap(leader .. "fo", ":Octo actions<CR>")
