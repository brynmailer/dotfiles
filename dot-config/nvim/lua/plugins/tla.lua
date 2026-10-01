return {
  {
    "susliko/tla.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "tla",
    config = function()
      require("tla").setup({
        java_executable = "/usr/lib/jvm/default/bin/java",
        java_opts = { "-XX:+UseParallelGC" },
        tla2tools = vim.fn.expand("~/.local/share/tla/tla2tools.jar"),
      })

      vim.keymap.set("n", "<leader>tt", function()
        local buf = vim.api.nvim_get_current_buf()
        local file = vim.api.nvim_buf_get_name(buf)
        vim.cmd("silent write")
        vim.system({ "pcal", "-nocfg", file }, { cwd = vim.fs.dirname(file), text = true }, function(res)
          vim.schedule(function()
            if res.code ~= 0 then
              vim.notify(vim.trim((res.stdout or "") .. (res.stderr or "")),
                vim.log.levels.ERROR, { title = "pcal" })
              return
            end
            -- pick up the rewritten file
            vim.api.nvim_buf_call(buf, function() vim.cmd("checktime") end)
          end)
        end)
      end, { desc = "PlusCal → TLA+" })

      vim.keymap.set("n", "<leader>tc", "<cmd>TlaCheck<cr>", { desc = "Run TLC" })

      vim.keymap.set("n", "<leader>ts", "<cmd>!sany %<cr>", { desc = "SANY parse" })
    end,
  },
  { "tlaplus-community/tlaplus-nvim-plugin", ft = "tla" },
}
