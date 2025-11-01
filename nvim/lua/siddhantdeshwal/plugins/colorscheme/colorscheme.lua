return {
  "craftzdog/solarized-osaka.nvim",
  opts = {
    transparent = true,
  },

  config = function(_, opts)
    require("solarized-osaka").setup(opts) -- optional setup call
    require("solarized-osaka").load()
  end,
}
