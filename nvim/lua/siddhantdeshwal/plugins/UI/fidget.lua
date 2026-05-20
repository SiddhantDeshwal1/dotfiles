return {
    "j-hui/fidget.nvim",
    -- opts = {} automatically calls require("fidget").setup({}) with default settings
    opts = {
        -- You can leave this empty to use the default look and feel
        notification = {
            window = {
                winblend = 0, -- Makes the background fully opaque (great for your pure black setup)
            },
        },
    },
}
