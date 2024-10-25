return {
		"navarasu/onedark.nvim",
		opts = {
			style = "deep" ,
		},
		config = function(_, opts)
			require("onedark").setup(opts) -- optional setup call
			require("onedark").load()
		end,
	}
