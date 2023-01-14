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

vim.on_key(function(char)
    if vim.fn.mode() == "n" then
        local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
        if vim.opt.hlsearch:get() ~= new_hlsearch then
            vim.opt.hlsearch = new_hlsearch
        end
    end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

local function escape()
    -- check if location window is open
    if vim.fn.winnr("$") > 1 then
        print("closing location window")
        vim.cmd("lclose")
        return
    end
    -- check if a quickfix window is open
    vim.cmd("cclose")
end

vimp.nnoremap("<esc>", escape)
-- vimp.nnoremap("<esc>", ":noh<cr>")
vimp.cnoremap("<C-r>", ":Telescope command_history<cr>")

vimp.nnoremap("gR", ":TroubleToggle lsp_references<cr>")
