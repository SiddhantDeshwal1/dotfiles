return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- Needs to load early to hijack virtual text safely
    config = function()
        -- 1. Safely import the plugin
        local status_ok, inline_diag = pcall(require, "tiny-inline-diagnostic")
        if not status_ok then
            return
        end

        -- 2. Configure tiny-inline-diagnostic
        inline_diag.setup({
            preset = "modern", -- Style options: "modern", "classic", "minimal", "powerline"
            options = {
                -- Show the source of the diagnostic (e.g., pyright, clangd, jdtls)
                show_source = {
                    enabled = true,
                },
                -- Enable multi-line diagnostics for long, detailed backend stack traces
                multilines = {
                    enabled = true,
                    always_show = false,
                },
                -- Show diagnostic count on the line if multiple issues exist
                add_messages = {
                    enabled = true,
                    display_count = true,
                },
            },
        })

        -- 3. Turn off Neovim's default raw virtual text to prevent duplicate overlays
        vim.diagnostic.config({ virtual_text = false })

        -- 4. Convenient Toggle Keymaps
        local keymap = vim.keymap.set
        local opts = { silent = true }

        keymap("n", "<leader>dt", "<cmd>TinyInlineDiag toggle<cr>", vim.tbl_extend("force", opts, { desc = "Toggle Inline Diagnostics" }))
        keymap("n", "<leader>dc", "<cmd>TinyInlineDiag toggle_cursor_only<cr>", vim.tbl_extend("force", opts, { desc = "Toggle Diagnostics Under Cursor Only" }))
    end,
}
