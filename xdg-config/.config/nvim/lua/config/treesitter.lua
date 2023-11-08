require("orgmode").setup_ts_grammar()

local ft_to_lang_tbl = {
  ["zsh"] = "bash",
  ["xml"] = "html",
  ["tiltfile"] = "python",
  -- ["helm"] = "yaml",
}

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.gotmpl = {
  install_info = {
    url = "https://github.com/ngalaiko/tree-sitter-go-template",
    files = { "src/parser.c" },
  },
  filetype = "gotmpl",
  used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" },
}

-- trick treesitter into thinking zsh files are bash
local ft_to_lang = require("nvim-treesitter.parsers").ft_to_lang
require("nvim-treesitter.parsers").ft_to_lang = function(ft)
  if ft_to_lang_tbl[ft] == nil then
    return ft_to_lang(ft)
  end
  return ft_to_lang_tbl[ft]
end

vim.filetype.add({
  extension = {
    sh = "bash",
    yml = "yaml",
  },
  filename = {
    ["justfile"] = "justfile",
  },
})
local function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end
vim.treesitter.query.add_directive("colzero!", function(match, pattern, bufnr, predicate, metadata)
  for i, m in pairs(metadata) do
    m.range[2] = 0
  end
end)

require("nvim-treesitter.install").prefer_git = true

require("nvim-treesitter.configs").setup({
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",

        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",

        ["al"] = "@call.outer",
        ["il"] = { query = "@call.inner", desc = "Select inner part of a function call" },
      },
      -- You can choose the select mode (default is charwise 'v')
      selection_modes = {
        ["@parameter.outer"] = "v", -- charwise
        ["@function.outer"] = "V", -- linewise
        ["@class.outer"] = "<c-v>", -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding xor succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      -- include_surrounding_whitespace = true,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
        ["<leader>o"] = "@binary_operator",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
        ["<leader>O"] = "@binary_operator",
      },
    },
  },
  ensure_installed = {
    "bash",
    "comment",
    "go",
    "gomod",
    "gotmpl",
    "json",
    "kotlin",
    "lua",
    "markdown",
    "org",
    "python",
    "sql",
    "typescript",
  },
  auto_install = true,
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = { "org", "vim", "markdown" },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    strategy = require("ts-rainbow.strategy.global"),
  },
  context_commentstring = {
    enable = true,
  },
})
require("ts_context_commentstring").setup({})
