-- Lazy.nvim bootstrap
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

-- Setup Lazy with structured imports
require("lazy").setup({
	-- Core plugin folder imports
	{ import = "siddhantdeshwal.plugins.coding" },
	{ import = "siddhantdeshwal.plugins.colorscheme" },
	{ import = "siddhantdeshwal.plugins.editor" },
	{ import = "siddhantdeshwal.plugins.formatting" },
	{ import = "siddhantdeshwal.plugins.linting" },
	{ import = "siddhantdeshwal.plugins.LSP" },
	{ import = "siddhantdeshwal.plugins.treesitter" },
	{ import = "siddhantdeshwal.plugins.UI" },
	{ import = "siddhantdeshwal.plugins.util" },
	{ import = "siddhantdeshwal.plugins.extra" },

	-- Optionally keep a base plugins folder (for global or misc plugins)
	{ import = "siddhantdeshwal.plugins" },
}, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
