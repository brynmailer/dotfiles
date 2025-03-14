return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- LSP Support
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp = require("cmp")

      -- Mason setup
      require("mason").setup({})
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({})
          end,
        },
      })

      -- Add cmp_nvim_lsp capabilities settings to lspconfig
      local lspconfig_defaults = lspconfig.util.default_config
      lspconfig_defaults.capabilities = vim.tbl_deep_extend(
        "force",
        lspconfig_defaults.capabilities,
        require("cmp_nvim_lsp").default_capabilities()
      )

      -- Enable features that only work if there
      -- is a language server active in the file
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          local opts = {buffer = event.buf}

          vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
          vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
          vim.keymap.set("n", "<leader>vws", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", opts)
          vim.keymap.set("n", "<leader>vd", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
          vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
          vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
          vim.keymap.set("n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
          vim.keymap.set("n", "<leader>vrr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
          vim.keymap.set("n", "<leader>vrn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
          vim.keymap.set("i", "<C-h>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        end,
      })


      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({}),
      })
    end,
  },
}
