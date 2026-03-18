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
        require("monokai").setup()

        vim.cmd.colorscheme("monokai")

        -- 🔥 FORCE after colorscheme loads
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "monokai",
            callback = function()
                local set = vim.api.nvim_set_hl

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
    end,
}
