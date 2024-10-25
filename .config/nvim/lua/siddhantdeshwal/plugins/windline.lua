return{
        'windwp/windline.nvim',
        config = function()
            local windline = require('windline')
            -- Load the Bubble theme
            require('wlsample.bubble2')

            -- Windline setup
            windline.setup({
                colors_name = function(colors)
                    return colors
                end,
                statuslines = {},  -- Start with an empty statuslines table
            })
        end,
}
