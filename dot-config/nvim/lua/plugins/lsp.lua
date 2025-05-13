return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
    },
    config = function()
      local lspconfig = require("lspconfig")

      -- Mason setup
      require("mason").setup({})
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities()
            })
          end,
        },
      })

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
    end,
  },
}
