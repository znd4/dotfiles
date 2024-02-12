local vimp = require("vimp")
vimp.nmap("<D-q>", ":qa")

-- Don't yank when pasting over a selection
-- see: https://vi.stackexchange.com/a/39151
vimp.xnoremap("p", "P")

------------------------------------------------------
-- MacOS system clipboard mappings
------------------------------------------------------

vimp.nmap("<D-c>", '"+y')
vimp.vmap("<D-c>", '"+y')
vimp.nmap("<D-v>", '"+p')
vimp.cnoremap("<D-v>", "<C-r>+")
vimp.inoremap("<D-v>", "<C-r>+")
vimp.tnoremap("<D-v>", [[<c-\><c-n><c-r>+]])

local factory = function(func, ...)
  local args = { ... }
  return function()
    func(unpack(args))
  end
end

vimp.nnoremap("<leader>xx", vim.cmd.TroubleToggle)
vimp.nnoremap("<leader>xw", factory(vim.cmd.TroubleToggle, "workspace_diagnostics"))
vimp.nnoremap("<leader>xd", factory(vim.cmd.TroubleToggle, "document_diagnostics"))
vimp.nnoremap("<leader>xq", factory(vim.cmd.TroubleToggle, "quickfix"))
vimp.nnoremap("<leader>xl", factory(vim.cmd.TroubleToggle, "loclist"))

vimp.nnoremap("<leader>nf", vim.cmd.NvimTreeFocus)
vimp.nnoremap("<leader>nt", vim.cmd.NvimTreeToggle)

vimp.nnoremap("<leader>gp", factory(vim.cmd.Git, "pull"))
vimp.nnoremap("<leader>gP", factory(vim.cmd.Git, "push"))
vimp.nnoremap("<leader>gc", factory(vim.cmd.Git, "commit"))

vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then
      vim.opt.hlsearch = new_hlsearch
    end
  end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

local function escape()
  require("notify").dismiss()
  -- check if location window is open
  if vim.fn.winnr("$") > 1 then
    print("closing location window")
    vim.cmd("lclose")
    return
  end

  --TODO: check if in command history window, then return

  -- check if a quickfix window is open
  vim.cmd("cclose")
end

local leader = "<leader>"
vimp.nnoremap(leader .. "fo", factory(vim.cmd.Octo, "actions"))

-- vimp.nnoremap("<esc>", ":noh<cr>")
vimp.cnoremap("<C-r>", ":Telescope command_history<cr>")

vimp.nnoremap("gR", factory(vim.cmd.TroubleToggle, "lsp_references"))
