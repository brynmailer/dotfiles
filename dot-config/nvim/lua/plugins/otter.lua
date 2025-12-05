return {
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local otter = require("otter")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "html",
        callback = function()
          require("otter").activate({ "javascript", "css" }, true, true, nil)
        end,
      })

    end,
  },
}
