return {
  {
    "tinted-theming/tinted-nvim",
    config = function()
      local tinted = require("tinted-colorscheme")

      tinted.with_config({
        highlights = {
          telescope_borders = true,
        },
      })

      tinted.setup()
    end,
  },
}
