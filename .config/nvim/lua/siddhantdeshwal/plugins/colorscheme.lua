-- return {
-- 		"navarasu/onedark.nvim",
-- 		opts = {
-- 			style = "deep" ,
-- 		},
-- 		config = function(_, opts)
-- 			require("onedark").setup(opts) -- optional setup call
-- 			require("onedark").load()
-- 		end,
-- 	}


-- return{
--   "eldritch-theme/eldritch.nvim",
--   -- lazy = false,
--   -- priority = 1000,
--     opts = {
--             transparent = true,
--         },
--     config = function(_, opts)
--     require("eldritch").setup(opts) -- optional setup call
-- 	require("eldritch").load()
-- 	end,
-- }

return {
  "craftzdog/solarized-osaka.nvim",
  opts = {
        transparent =true,
    },

    config = function(_, opts)
    require("solarized-osaka").setup(opts) -- optional setup call
	require("solarized-osaka").load()
	end,
}
