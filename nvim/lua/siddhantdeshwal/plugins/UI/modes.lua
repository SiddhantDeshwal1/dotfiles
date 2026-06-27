return {
    "mvllow/modes.nvim",
    config = function()
        require("modes").setup({
            colors = {
                copy    = "#F9E2AF", -- Vibrant Yellow (Yanking)
                delete  = "#F38BA8", -- Bright Red (Deleting)
                insert  = "#A6E3A1", -- Striking Green (Insert mode)
                visual  = "#CBA6F7", -- Popping Purple (Visual mode)
                replace = "#F38BA8", -- Bright Red (Replace mode)
            },
            line_opacity = 0.35,
        })
    end
}
