return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
    },
    config = function(_, opts)
      -- mason-lspconfig v2 auto-enables installed servers via vim.lsp.enable().
      -- The old setup({ handlers = ... }) / lspconfig[server].setup() API is gone;
      -- per-server config now goes through vim.lsp.config() (Neovim 0.11 native).
      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "lua_ls", "marksman", "rust_analyzer", "tinymist" },
      })

      -- Apply cmp completion capabilities to every server (merged via the '*' default).
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- tinymist: background "primary" preview on a fixed port that follows the
      -- focused .typ file, so one qutebrowser pane at http://127.0.0.1:23635
      -- tracks the current doc. ftplugin/typst.lua's <leader>fp opens that pane.
      vim.lsp.config("tinymist", {
        init_options = {
          preview = {
            background = {
              enabled = true,
              args = {
                "--data-plane-host=127.0.0.1:23635",
                "--invert-colors=auto",
              },
            },
          },
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
