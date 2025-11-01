--------------------------------------------------------------------------------
-- 📘 flash.nvim — Super-fast navigation and jumping in Neovim
--
-- ⚡ WHAT IT DOES
--  • Lets you jump anywhere on screen instantly (like Hop/EasyMotion but faster)
--  • Enhances f/t/F/T motions and adds Treesitter-aware movement
--  • Useful for large files, classes, or functions where scrolling is slow
--
-- 🧭 BASIC USAGE
--  s  → Jump to any visible text (shows letter labels)
--  S  → Treesitter jump (by code blocks, functions, etc.)
--  r  → Use in operator mode (like dr → delete until target)
--  R  → Treesitter search (jump between syntax nodes)
--  <C-s> → Toggle Flash search in command-line mode
--
-- 💡 EXAMPLES
--  • Press `s`, see letters on screen → type one → instantly jump
--  • Press `S` inside a function to jump to nearby code blocks
--  • Use `dr` (delete + Flash) to delete until a label position
--
-- 🧩 RECOMMENDED SETUP
--  Add to your Lazy.nvim plugin list.
--  You don’t need any config beyond this; it’s lightweight & auto-loads.
--------------------------------------------------------------------------------

return {
  "folke/flash.nvim",
  event = "VeryLazy", -- Load lazily to keep startup fast
  opts = {},

  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash Jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Flash Remote",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Flash Treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}
