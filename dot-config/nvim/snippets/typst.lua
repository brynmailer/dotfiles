local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- `fig`: figure referencing fig/<doc>/<label>.<ext>. Tab through label, the
  -- extension (cycle with <C-l>) and caption. Draw the image with <leader>ff
  -- on the path; tinymist re-renders it on save.
  s({ trig = "fig", desc = "create a figure" }, fmt(
[[#figure(
  image("fig/{doc}/{label}.{ext}"),
  caption: [{caption}],
) <{ref}>]],
    {
      doc = f(function()
        return vim.fn.expand("%:t:r")
      end),
      label = i(1, "label"),
      ext = c(2, { t("svg"), t("jpg"), t("png") }),
      caption = i(3, "Caption"),
      ref = rep(1),
    }
  )),
}
