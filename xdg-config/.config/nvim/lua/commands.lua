local leader = "<leader>"

local nnoremap = function(...)
  vim.keymap.set("n", ...)
end
nnoremap(leader .. "fo", ":Octo actions<CR>")
