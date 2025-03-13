local lsp = require("lsp-zero")
local lspconfig = require("lspconfig");

lsp.preset("recommended")

lsp.ensure_installed({
    'tsserver',
    'clangd',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local load_local_settings = function(path, server_name)
    vim.validate { path = { path, 's' } }

    local fname = string.format("%s/.nvim/%s.json", path, server_name)
    local ok, result = pcall(vim.fn.readfile, fname)
    if not ok then return nil end

    result = table.concat(result)
    result = vim.json.decode(result)
    return result
end

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<Tab>'] = cmp.mapping({
        i = function(fallback)
            if not cmp.select_next_item() then
                if vim.bo.buftype ~= 'prompt' and has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end
        end,
    }),

    ['<S-Tab>'] = cmp.mapping({
        i = function(fallback)
            if not cmp.select_prev_item() then
                if vim.bo.buftype ~= 'prompt' and has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end
        end,
    }),

    ["<CR>"] = cmp.mapping({
        i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
                fallback()
            end
        end,
        s = cmp.mapping.confirm({ select = true }),
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    }),

    ["<C-Space>"] = cmp.mapping.complete(),
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lspconfig.util.on_setup = lspconfig.util.add_hook_before(lspconfig.util.on_setup, function(config)
    local new_default_config = load_local_settings(vim.fn.getcwd(), config.name)
    if new_default_config ~= nil then
        config.cmd = new_default_config.cmd
    end
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
