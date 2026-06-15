-- typst (tinymist LSP) buffer-local config

-- Live preview: tinymist's background preview server (configured in
-- plugins/lsp.lua) follows the focused .typ file, so there's nothing to start
-- per file — just open its one stable URL in a tiled qutebrowser window.
vim.keymap.set("n", "<leader>fp", function()
  vim.fn.jobstart(
    { "qutebrowser", "--target", "window", "http://127.0.0.1:23635" },
    { detach = true }
  )
end, { buffer = true, silent = true, desc = "Typst: live preview (qutebrowser side pane)" })

-- Edit the figure path under the cursor in Inkscape; typst-figure creates it
-- from a blank template if missing. Saving re-renders it in the preview.
vim.keymap.set("n", "<leader>ff", function()
  local fname = vim.fn.expand("<cfile>")
  if fname == "" then
    vim.notify("no figure path under cursor", vim.log.levels.WARN)
    return
  end
  -- Resolve relative to the document dir, as typst resolves image() paths.
  if not vim.startswith(fname, "/") then
    fname = vim.fn.expand("%:p:h") .. "/" .. fname
  end
  vim.fn.jobstart({ "typst-figure", fname }, { detach = true })
end, { buffer = true, silent = true, desc = "Typst: edit figure under cursor (Inkscape)" })
