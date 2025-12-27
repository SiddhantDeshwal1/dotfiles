-- ~/.config/nvim/lua/siddhantdeshwal/plugins/LSP/lspconfig.lua
return {
    "neovim/nvim-lspconfig", -- Now just provides default configs; Neovim auto-discovers them
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp", -- For capabilities (still needed)
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/lazydev.nvim",                  opts = {} },
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        -- 1. Global Capabilities (unchanged; cmp still uses this)
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- 2. Global Diagnostic Config (unchanged)
        vim.diagnostic.config({
            virtual_text = false,
            signs = true,
            underline = true,
            update_in_insert = true,
            severity_sort = true,
        })

        -- 3. Global on_attach (applies to all servers via vim.lsp.config('*'))
        local on_attach = function(client, bufnr)
            local keymap = vim.keymap.set
            local opts = { buffer = bufnr, silent = true }

            keymap("n", "K", vim.lsp.buf.hover, opts)
            keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
            keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            keymap("n", "[d", vim.diagnostic.goto_prev, opts)
            keymap("n", "]d", vim.diagnostic.goto_next, opts)
            keymap("n", "gD", vim.lsp.buf.declaration, opts)

            -- Smart gd: opens in new tab if file is different (enhanced for multi-results)
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

        -- Apply global defaults to ALL servers (new 0.11+ way)
        vim.lsp.config("*", {
            capabilities = capabilities,
            on_attach = on_attach,
        })

        ---------------------------------------------------------------------------
        -- MASON SETUP (v2.1+: Auto-installs & enables valid servers only)
        ---------------------------------------------------------------------------
        require("mason").setup({
            -- Global Mason opts (e.g., UI tweaks)
            ui = { border = "rounded" },
        })

        require("mason-lspconfig").setup({
            -- Only auto-install VALID servers (prevents spam from invalid ones like 'tsgo')
            ensure_installed = {
                "lua_ls",
                "ts_ls", -- TypeScript (replaces tsserver)
                "pyright", -- Python
                "rust_analyzer",
                "gopls", -- Go
                "clangd", -- C/C++
                "cssls", -- CSS
                "html",
                "jsonls",
                "marksman", -- Markdown
                "harper_ls", -- Grammar/Spelling (installs 'harper-ls' binary)
                -- Add more VALID ones: Run :Mason to see available LSPs
                -- e.g., "dockerls" for Docker (note: it's 'dockerls', not 'docker_language_server')
                -- "emmet_ls", "tailwindcss", "eslint", "volar" (Vue, but use 'ts_ls' + Volar extension for full Vue)
            },
            automatic_enable = true, -- Auto vim.lsp.enable() for installed servers
            -- Handler to skip invalid/unwanted servers (suppresses warnings)
            handlers = {
                -- Default: Enable if installed and config exists
                function(server_name)
                    local config = vim.lsp.config[server_name]
                    if config and require("mason-lspconfig").is_installed(server_name) then
                        vim.lsp.enable(server_name)
                    else
                        -- Silently skip invalid ones (e.g., 'tsgo', 'stylua')
                        vim.notify("Skipping invalid server: " .. server_name, vim.log.levels.DEBUG)
                    end
                end,
            },
        })

        ---------------------------------------------------------------------------
        -- PER-SERVER OVERRIDES (new 0.11+ way: vim.lsp.config('server', { ... }))
        -- These merge with globals and nvim-lspconfig defaults
        ---------------------------------------------------------------------------
        -- Lua LS (unchanged, but now via vim.lsp.config)
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                    telemetry = { enable = false },
                },
            },
        })

        -- Harper-LS (example override: disable aggressive linters for code)
        vim.lsp.config("harper_ls", {
            settings = {
                ["harper-ls"] = {
                    linters = {
                        SentenceCapitalization = false,
                        SpellCheck = false, -- Enable if you want full spelling
                    },
                },
            },
        })

        -- Example for Pyright (add settings if needed)
        -- vim.lsp.config("pyright", {
        --   settings = {
        --     python = {
        --       analysis = {
        --         autoSearchPaths = true,
        --         useLibraryCodeForTypes = true,
        --       },
        --     },
        --   },
        -- })

        -- Enable servers explicitly if not auto-enabled by Mason (rare)
        -- vim.lsp.enable("lua_ls")
        -- vim.lsp.enable("harper_ls")
    end,
}
