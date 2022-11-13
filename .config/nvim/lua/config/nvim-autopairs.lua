require("nvim-autopairs").setup({ fast_wrap = {} })

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
