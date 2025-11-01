return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar" },
  opts = {
    -- optional defaults
    engine = "ripgrep", -- or "astgrep" if you use it
    preview = true,
    trim_long_lines = true,
  },
  keys = {
    -- Open project-wide search panel
    { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and Replace (GrugFar)" },
  },
}
