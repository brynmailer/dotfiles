return {
  {
    "susliko/tla.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "tla",
    config = function()
      require("tla").setup({
        java_executable = "/usr/lib/jvm/default/bin/java",
        java_opts = { "-XX:+UseParallelGC" },
        tla2tools = vim.fn.expand("~/.local/share/tla/tla2tools.jar"),
      })
      vim.keymap.set("n", "<leader>tt", "<cmd>TlaTranslate<cr>", { desc = "PlusCal → TLA+" })
      vim.keymap.set("n", "<leader>tc", "<cmd>TlaCheck<cr>", { desc = "Run TLC" })
      vim.keymap.set("n", "<leader>ts", "<cmd>!sany %<cr>", { desc = "SANY parse" })
    end,
  },
  { "tlaplus-community/tlaplus-nvim-plugin", ft = "tla" },
}
