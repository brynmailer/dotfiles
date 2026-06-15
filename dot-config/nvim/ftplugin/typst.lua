-- typst (tinymist LSP) buffer-local config

-- Live preview: start tinymist's incremental preview without opening the
-- default browser, then show the URL in a tiled qutebrowser window. Cache it
-- so reopening a closed window doesn't restart (and abort) the server.
vim.keymap.set("n", "<leader>fp", function()
  local function open(url)
    vim.fn.jobstart({ "qutebrowser", "--target", "window", url }, { detach = true })
  end

  if vim.g.typst_preview_url then
    open(vim.g.typst_preview_url)
    return
  end

  local client = vim.lsp.get_clients({ name = "tinymist", bufnr = 0 })[1]
  if not client then
    vim.notify("tinymist not attached", vim.log.levels.WARN)
    return
  end

  client:exec_cmd(
    {
      command = "tinymist.doStartPreview",
      arguments = { { "--no-open", vim.api.nvim_buf_get_name(0) } },
    },
    { bufnr = 0 },
    function(err, result)
      if err then
        vim.notify("preview failed: " .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end
      local port = result and result.staticServerPort
      if not port then
        vim.notify("tinymist returned no preview port", vim.log.levels.ERROR)
        return
      end
      local url = string.format("http://127.0.0.1:%d", port)
      vim.g.typst_preview_url = url
      open(url)
    end
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
