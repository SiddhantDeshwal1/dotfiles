local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- use { 'windwp/windline.nvim', requires = { 'nvim-tree/nvim-web-devicons' }}

-- In your lazy.lua or init.lua where you configure plugins
-- require('lazy').setup({
--     {'windwp/windline.nvim', config = function() require('windline').setup() end},
-- })

require("lazy").setup({
	{ import = "siddhantdeshwal.plugins" },
	{ import = "siddhantdeshwal.plugins.lsp" },

	{
		"navarasu/onedark.nvim",
		opts = {
			style = "deep" ,
		},
		config = function(_, opts)
			require("onedark").setup(opts) -- optional setup call
			require("onedark").load()
		end,
	},
-- {
--         'windwp/windline.nvim',
--         config = function()
--             local windline = require('windline')
--             -- Load the Bubble theme
--             require('wlsample.bubble2')
--
--             -- Windline setup
--             windline.setup({
--                 colors_name = function(colors)
--                     return colors
--                 end,
--                 statuslines = {},  -- Start with an empty statuslines table
--             })
--         end,
--     },
}, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
