return {
  {
    "RRethy/base16-nvim",
    config = function()
      local base16 = require("base16-colorscheme")

      base16.with_config({
        telescope = false,
      })
    end,
    priority = 1000,
  },
}
