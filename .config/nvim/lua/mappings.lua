local vimp = require("vimp")
vimp.nmap("<D-q>", ":qa")
vimp.nnoremap("<leader>xx", ":TroubleToggle<cr>")
vimp.nnoremap("<leader>xw", ":TroubleToggle workspace_diagnostics<cr>")
vimp.nnoremap("<leader>xd", ":TroubleToggle document_diagnostics<cr>")
vimp.nnoremap("<leader>xq", ":TroubleToggle quickfix<cr>")
vimp.nnoremap("<leader>xl", ":TroubleToggle loclist<cr>")

vimp.nnoremap("<leader>nf", ":NvimTreeFocus<cr>")
vimp.nnoremap("<leader>nt", ":NvimTreeToggle<cr>")

vimp.nnoremap("<leader>gc", ":Git commit<cr>")
vimp.nnoremap("<leader>gp", ":Git pull<cr>")
vimp.nnoremap("<leader>gP", ":Git push<cr>")

vimp.nnoremap("gR", ":TroubleToggle lsp_references<cr>")
