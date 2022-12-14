local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_setup = function()
    local cmp = require("cmp")
    if cmp == nil then
        print("need to install cmp")
        return
    end

    local luasnip = require("luasnip")

    local function cmp_map(...)
        return cmp.mapping(..., { "i", "s", "c" })
    end

    local function filter_mode(mappings, mode)
        local res = {}
        for k, v in pairs(mappings) do
            if v[mode] then
                res[k] = { [mode] = v[mode] }
            end
        end
        return res
    end

    local select_behavior = cmp.SelectBehavior.Insert
    -- local select_behavior = cmp.SelectBehavior.Select

    local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
    local luasnip_next = function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif has_words_before() then
            cmp.complete()
        else
            fallback()
        end
    end
    local luasnip_prev = function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end
    local ultisnips_next = cmp_ultisnips_mappings.compose({ "jump_forwards", "select_next_item" })
    local snippet_source = "luasnip"

    local next
    local prev
    local snippet_expand_func

    if snippet_source == "luasnip" then
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()
        next = luasnip_next
        prev = luasnip_prev
        snippet_expand_func = function(args)
            require("luasnip").lsp_expand(args.body)
        end
    elseif snippet_source == "ultisnips" then
        next = ultisnips_next
        prev = cmp_ultisnips_mappings.jump_backwards
        snippet_expand_func = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
        end
    else
        print("Did not recognize snip framework " .. snippet_source)
        return
    end

    local cmd_next = function()
        if cmp.visible() then
            cmp.select_next_item({ behavior = select_behavior })
        else
            cmp.complete()
        end
    end
    local cmd_prev = function()
        if cmp.visible() then
            cmp.select_prev_item({ behavior = select_behavior })
        else
            cmp.complete()
        end
    end

    local mappings = { -- Preset: ^n, ^p, ^y, ^e, you know the drill..
        ["<Down>"] = { i = cmp.mapping.select_next_item({ behavior = select_behavior }) },
        ["<Up>"] = { i = cmp.mapping.select_prev_item({ behavior = select_behavior }) },
        ["<C-n>"] = {
            i = next,
            s = next,
            c = cmd_next,
        },
        -- ["<Tab>"] = {
        -- 	i = next,
        -- 	s = next,
        -- 	c = cmd_next,
        -- },
        ["<C-p>"] = {
            i = prev,
            s = prev,
            c = cmd_prev,
        },
        -- ["<S-Tab>"] = {
        -- 	i = prev,
        -- 	s = prev,
        -- 	c = cmd_prev,
        -- },
        ["<C-d>"] = cmp_map(cmp.mapping.scroll_docs(-4)),
        ["<C-f>"] = cmp_map(cmp.mapping.scroll_docs(4)),
        ["<C-Space>"] = cmp_map(cmp.mapping.complete()),
        ["<C-e>"] = {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        },
        ["<C-y>"] = cmp_map(cmp.mapping.confirm({ behavior = select_behavior, select = true })),
        -- ["<CR>"] = cmp_map(cmp.mapping.confirm({ select = false })),
    }

    local lspkind = require("lspkind")

    cmp.setup({
        formatting = {
            format = lspkind.cmp_format({
                -- mode = "symbol",
                with_text = true,
                -- maxwidth = 50,
                menu = {
                    buffer = "[buf]",
                    nvim_lsp = "[LSP]",
                    nvim_lua = "[api]",
                    path = "[path]",
                    luasnip = "[snip]",
                    tn = "[TabNine]",
                },
            }),
        },
        snippet = {
            expand = snippet_expand_func,
        },
        sources = {
            { name = "orgmode" },
            { name = "nvim_lsp" },
            { name = snippet_source },
            { name = "path" },
            -- { name = "buffer", keyword_length = 2 },
            { name = "buffer" },
            { name = "emoji", insert = true },
            { name = "nvim_lua" },
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert(mappings),
        -- completion = { autocomplete = true },
    })

    -- command mode completion
    local cmdline_mappings = cmp.mapping.preset.cmdline(filter_mode(mappings, "c"))
    local cmdline_view = { entries = "wildmenu" }
    cmdline_view = { entries = "custom" }

    cmp.setup.cmdline(":", {
        mapping = cmdline_mappings,
        view = cmdline_view,
        sources = {
            { name = "cmdline" },
            { name = "path" },
        },
        completion = { autocomplete = true },
    })

    cmp.setup.cmdline("/", {
        mapping = cmdline_mappings,
        view = cmdline_view,
        sources = {
            { name = "buffer" },
        },
        completion = { autocomplete = true },
    })
    -- Set configuration for specific filetype.
    cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
            { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
            { name = "buffer" },
        }),
    })
    -- vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
    -- 	callback = function()
    -- 		local line = vim.api.nvim_get_current_line()
    -- 		local cursor = vim.api.nvim_win_get_cursor(0)[2]
    --
    -- 		local current = string.sub(line, cursor, cursor + 1)
    -- 		if current == "." or current == "," or current == " " then
    -- 			require("cmp").close()
    -- 		end
    --
    -- 		local before_line = string.sub(line, 1, cursor + 1)
    -- 		local after_line = string.sub(line, cursor + 1, -1)
    -- 		if not string.match(before_line, "^%s+$") then
    -- 			if after_line == "" or string.match(before_line, " $") or string.match(before_line, "%.$") then
    -- 				require("cmp").complete()
    -- 			end
    -- 		end
    -- 	end,
    -- 	pattern = "*",
    -- })
    --  see https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-add-visual-studio-code-dark-theme-colors-to-the-menu
    -- 	vim.cmd([[
    --   highlight! link CmpItemMenu Comment
    --   " gray
    --   highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
    --   " blue
    --   highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
    --   highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
    --   " light blue
    --   highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
    --   highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
    --   highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
    --   " pink
    --   highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
    --   highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
    --   " front
    --   highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
    --   highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
    --   highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    -- ]])
end

vim.opt.completeopt = { "menu", "menuone", "noselect" }
cmp_setup()
