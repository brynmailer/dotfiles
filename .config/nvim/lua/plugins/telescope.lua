return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.load_extension("file_browser")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>ps", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>pg", builtin.grep_string, { desc = "Telescope grep string" })

      vim.keymap.set("n", "<space>fb", function()
        telescope.extensions.file_browser.file_browser()
      end)
    end,
  }
}
