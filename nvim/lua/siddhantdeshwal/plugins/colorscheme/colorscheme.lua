-- return {
--   "craftzdog/solarized-osaka.nvim",
--   opts = {
--     transparent = true,
--   },
--
--   config = function(_, opts)
--     require("solarized-osaka").setup(opts) -- optional setup call
--     require("solarized-osaka").load()
--   end,
-- }
--
-- Using Lazy
return {
  "morhetz/gruvbox",
  priority = 1000,
  config = function()
    vim.opt.termguicolors = true
    vim.o.background = "dark"

    -- gruvbox options
    vim.g.gruvbox_contrast_dark = "hard"
    vim.g.gruvbox_transparent_bg = 1

    vim.cmd("colorscheme gruvbox")
  end,
}
