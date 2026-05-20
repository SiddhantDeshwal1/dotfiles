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

-- return {
--     "tanvirtin/monokai.nvim",
--     lazy = false,
--     priority = 1000,
--     config = function()
--         -- 1. Initialize the plugin first
--         require("monokai").setup()
--
--         -- 2. Set the trap BEFORE loading the colorscheme
--         vim.api.nvim_create_autocmd("ColorScheme", {
--             pattern = "monokai",
--             callback = function()
--                 local set = vim.api.nvim_set_hl
--
--                 -- Force pure black overrides
--                 set(0, "Normal", { bg = "#000000" })
--                 set(0, "NormalNC", { bg = "#000000" })
--                 set(0, "NormalFloat", { bg = "#000000" })
--                 set(0, "FloatBorder", { bg = "#000000" })
--                 set(0, "SignColumn", { bg = "#000000" })
--                 set(0, "EndOfBuffer", { bg = "#000000" })
--                 set(0, "LineNr", { bg = "#000000" })
--                 set(0, "StatusLine", { bg = "#000000" })
--                 set(0, "VertSplit", { bg = "#000000" })
--             end,
--         })
--
--         -- 3. Trigger the load, which immediately fires the autocmd above
--         vim.cmd.colorscheme("monokai")
--     end,
-- }
--
return {
    "zootedb0t/citruszest.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        -- 1. Setup the theme (using default settings)
        local status_ok, citruszest = pcall(require, "citruszest")
        if status_ok then
            citruszest.setup({
                -- You can add plugin-specific options here later
            })
        end

        -- 2. Actually load and apply the theme
        vim.cmd("colorscheme citruszest")

        -- 3. Forcefully override core backgrounds to pure black natively
        local black_bg_groups = {
            "Normal",
            "NormalNC",
            "SignColumn",
            "EndOfBuffer",
            "NormalFloat",
        }

        for _, group in ipairs(black_bg_groups) do
            -- Get the current highlight properties to preserve text colors
            local current_hl = vim.api.nvim_get_hl(0, { name = group })

            -- Override only the background color
            current_hl.bg = "#000000"

            -- Reapply the modified highlight group
            vim.api.nvim_set_hl(0, group, current_hl)
        end
    end,
}
