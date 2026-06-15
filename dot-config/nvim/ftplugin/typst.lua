-- typst (tinymist LSP) buffer-local config

-- Live preview: start tinymist's incremental preview server (updates on every
-- keystroke) without auto-opening the default browser, then open the served
-- URL in a dedicated qutebrowser window. Hyprland tiles that new window in the
-- focused workspace, so the preview sits as a side pane next to the editor
-- rather than as a tab in the browser on another workspace.
--
-- The server persists for the whole nvim session, so re-pressing the key after
-- closing the browser must NOT call doStartPreview again: a second start would
-- re-bind the same data-plane port and abort tinymist. Cache the URL on first
-- start and just reopen the window on later presses.
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
