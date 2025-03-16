return {
  {
    "mbrea-c/wal-colors.nvim",
    config = function()
      vim.cmd([[colorscheme mbc]])

      require("wal-colors").setup(
        function(colors)
          return {
            -- Basic syntax elements
            Identifier = { fg = colors.foreground },
            ["@variable"] = { fg = colors.foreground },
            ["@function"] = { fg = colors.color5, bold = true },
            ["@method"] = { fg = colors.color5, bold = true },
            ["@parameter"] = { fg = colors.color6, italic = true },
            ["@property"] = { fg = colors.color3 },
            ["@field"] = { fg = colors.color3 },

            -- Type-related highlights
            ["@type"] = { fg = colors.color2, bold = true },
            ["@type.builtin"] = { fg = colors.color2, italic = true },
            ["@constant"] = { fg = colors.color1 },
            ["@constant.builtin"] = { fg = colors.color1, bold = true },

            -- String and comments
            ["@string"] = { fg = colors.color2 },
            ["@comment"] = { fg = colors.color8, italic = true },

            -- Keywords and operators
            ["@keyword"] = { fg = colors.color4, bold = true },
            ["@operator"] = { fg = colors.color6 },

            -- JSX specific highlighting
            ["@tag"] = { fg = colors.color4, bold = true },
            ["@tag.attribute"] = { fg = colors.color3, italic = true },
            ["@tag.delimiter"] = { fg = colors.color4, bold = true },
            ["@string.special"] = { fg = colors.color2 },

            -- TSX/TypeScript specific
            ["@type.qualifier.tsx"] = { fg = colors.color4, bold = true },
            ["@constructor.tsx"] = { fg = colors.color4, bold = true },

            -- LSP
            ["@lsp.mod.declaration"] = { underdashed = false },

            -- Semantic token overrides (explicit and comprehensive)
            TSVariable = { fg = colors.foreground },
            TSFunction = { fg = colors.color5, bold = true },
            TSMethod = { fg = colors.color5, bold = true },
            TSParameter = { fg = colors.color6, italic = true },
            TSProperty = { fg = colors.color3 },
            TSField = { fg = colors.color3 },
            TSUnderline = { underline = false },

            -- JSX with traditional TS highlights (older versions of tree-sitter)
            TSTag = { fg = colors.color4, bold = true },
            TSTagDelimiter = { fg = colors.color4 },
            TSTagAttribute = { fg = colors.color3, italic = true },

            -- Other UI elements
            CursorLine = { bg = colors.background:lightened(0.2) },
            Visual = { bg = colors.background:lightened(0.2) },
            Search = { bg = colors.color3, fg = colors.background },
            IncSearch = { bg = colors.color3, fg = colors.background, bold = true },

            -- Diagnostics
            DiagnosticError = { fg = colors.color1 },
            DiagnosticWarn = { fg = colors.color3 },
            DiagnosticInfo = { fg = colors.color4 },
            DiagnosticHint = { fg = colors.color6 },
          }
        end,
        { replace = false }
      )
    end,
    priority = 1000,
  },
}
