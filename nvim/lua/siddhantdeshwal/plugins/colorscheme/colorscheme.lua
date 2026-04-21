-- return {
--     "craftzdog/solarized-osaka.nvim",
--     opts = {
--         transparent = false,
--     },
--
--     config = function(_, opts)
--         require("solarized-osaka").setup(opts) -- optional setup call
--         require("solarized-osaka").load()
--     end,
-- }

return {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        -- 1. Initialize the plugin first
        require("monokai").setup()

        -- 2. Set the trap BEFORE loading the colorscheme
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "monokai",
            callback = function()
                local set = vim.api.nvim_set_hl

                -- Force pure black overrides
                set(0, "Normal", { bg = "#000000" })
                set(0, "NormalNC", { bg = "#000000" })
                set(0, "NormalFloat", { bg = "#000000" })
                set(0, "FloatBorder", { bg = "#000000" })
                set(0, "SignColumn", { bg = "#000000" })
                set(0, "EndOfBuffer", { bg = "#000000" })
                set(0, "LineNr", { bg = "#000000" })
                set(0, "StatusLine", { bg = "#000000" })
                set(0, "VertSplit", { bg = "#000000" })
            end,
        })

        -- 3. Trigger the load, which immediately fires the autocmd above
        vim.cmd.colorscheme("monokai")
    end,
}
