return {
  {
    "NvChad/nvim-colorizer.lua", -- maintained & compatible with Neovim 0.11+
    event = "BufEnter",
    opts = {
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        css = true,
        css_fn = true,
        hsl_fn = true,
        hsl = true,
      },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
