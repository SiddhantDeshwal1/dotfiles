-- ~/.config/nvim/lua/siddhantdeshwal/plugins/lspconfig.lua
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/lazydev.nvim",                  opts = {} },
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- 1. Setup Global Capabilities for Autocompletion
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- 2. Setup Global UI Diagnostics
        vim.diagnostic.config({
            virtual_text = false,
            signs = true,
            underline = true,
            update_in_insert = true,
            severity_sort = true,
            float = { border = "rounded" },
        })

        -- 3. Global Keymaps (Attached only when an LSP connects to a buffer)
        local on_attach = function(_, bufnr)
            local keymap = vim.keymap.set
            local opts = { buffer = bufnr, silent = true }

            keymap("n", "K", vim.lsp.buf.hover, opts)
            keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
            keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            keymap("n", "[d", vim.diagnostic.goto_prev, opts)
            keymap("n", "]d", vim.diagnostic.goto_next, opts)
            keymap("n", "gD", vim.lsp.buf.declaration, opts)

            -- Smart gd: opens in new tab if file is different
            keymap("n", "gd", function()
                local params = vim.lsp.util.make_position_params()
                vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
                    if err or not result or vim.tbl_isempty(result) then
                        vim.notify("No definition found", vim.log.levels.WARN)
                        return
                    end

                    local target = vim.islist(result) and result[1] or result
                    local uri = target.uri or target.targetUri
                    local target_path = vim.uri_to_fname(uri)
                    local current_path = vim.api.nvim_buf_get_name(0)

                    if target_path ~= current_path then
                        vim.cmd("tabnew " .. vim.fn.fnameescape(target_path))
                    end

                    vim.schedule(function()
                        vim.lsp.util.jump_to_location(target, "utf-8")
                    end)
                end)
            end, opts)
        end

        -- 4. Tell Mason to install specific LSPs and define their handlers natively
        mason_lspconfig.setup({
            ensure_installed = {
                "clangd",   -- C/C++
                "pyright",  -- Python
                "jdtls",    -- Java
                "ts_ls",    -- JavaScript/TypeScript
                "html",     -- HTML
                "cssls",    -- CSS
                "lua_ls",   -- Lua
                "marksman", -- Markdown
            },

            -- This replaces the broken 'setup_handlers' function
            handlers = {
                -- Default handler applied to all servers
                function(server_name)
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,

                -- Specific Override for Lua
                ["lua_ls"] = function()
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = { globals = { "vim" } },
                                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                                telemetry = { enable = false },
                            },
                        },
                    })
                end,

                -- Specific Override for Java
                ["jdtls"] = function()
                    lspconfig.jdtls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
            }
        })
    end,
}
