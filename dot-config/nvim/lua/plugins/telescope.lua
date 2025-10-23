return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            ".git/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          live_grep = {
            hidden = true,
          },
          grep_string = {
            hidden = true,
          },
        },
        extensions = {
          file_browser = {
            path = "%:p:h",
            hijack_netrw = true,
            display_stat = false,
            hidden = true,
          },
        },
      })

      telescope.load_extension("file_browser")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Telescope find files find_command=rg,--ignore,--hidden,--files" })
      vim.keymap.set("n", "<leader>ps", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>pg", builtin.grep_string, { desc = "Telescope grep string" })

      vim.keymap.set("n", "<space>pv", function()
        telescope.extensions.file_browser.file_browser()
      end)
    end,
  }
}
