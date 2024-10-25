return {
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufEnter", -- Load the plugin when entering a buffer
    opts = function()
      return {
        filetypes = { "*" }, -- Apply colorizer to all file types
        user_default_options = {
          RGB = true, -- Enable RGB hex color codes
          RRGGBB = true, -- Enable RRGGBB hex color codes
          names = true, -- Enable color names (like 'red')
          RRGGBBAA = true, -- Enable RGBA hex color codes
          css = true, -- Enable CSS color formats
          css_fn = true, -- Enable CSS functions
          hsl_fn = true, -- Enable HSL functions
          hsl = true, -- Enable HSL color formats
        },
        -- Optional: Configure specific file types if needed
        -- filetypes = { 'css', 'html', 'javascript', 'lua' },
      }
    end,
    config = function()
      require('colorizer').setup()
    end,
  },
}
