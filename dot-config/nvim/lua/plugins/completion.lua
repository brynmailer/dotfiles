return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- LSP support
      { "hrsh7th/cmp-nvim-lsp" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_luasnip" },
      { "rafamadriz/friendly-snippets" },

      -- Autopairs
      {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
      },

      -- Visual stuff
      { "onsails/lspkind.nvim" },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local autopairs = require("nvim-autopairs.completion.cmp")

      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        experimental = {
          ghost_text = true,
        },

        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = {
              -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
              -- can also be a function to dynamically calculate max width such as
              -- menu = function() return math.floor(0.45 * vim.o.columns) end,
              menu = 50, -- leading text (labelDetails)
              abbr = 50, -- actual suggestion item
            },
            ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default
          })
        },

        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- Tab for both snippet navigation and cmp completion
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
      })

      cmp.event:on(
        "confirm_done",
        autopairs.on_confirm_done()
      )
    end,
  },
}
