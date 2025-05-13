-- Start flavours
local colors = {
  base00 = "#28233a",
  base01 = "#4d4a5c",
  base02 = "#73717e",
  base03 = "#9998a0",
  base04 = "#bfbfc2",
  base05 = "#e5e7e5",
  base06 = "#e8eae8",
  base07 = "#eceeec",
  base08 = "#549394",
  base09 = "#4a79c0",
  base0A = "#7f7675",
  base0B = "#cec8cd",
  base0C = "#9d9d9a",
  base0D = "#bbbcbb",
  base0E = "#b8aeb7",
  base0F = "#bec8cc",
}
-- End flavours

return {
  {
    "RRethy/base16-nvim",
    config = function()
      local base16 = require("base16-colorscheme")

      base16.with_config({
        telescope = false,
      })

      base16.setup(colors)
    end,
    priority = 1000,
  },
}
