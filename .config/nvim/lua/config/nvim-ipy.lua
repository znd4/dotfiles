---- NVIM-IPY -----------------------------------------------------------------

vim.g.nvim_ipy_perform_mappings = 0

vim.g.ipy_celldef = "# %%"

local vimp = require("vimp")
vimp.nnoremap("<silent><c-s>", "<Plug>(IPy-Run)")
vimp.nnoremap("<leader>rc", "<Plug>(IPy-RunCell)")
