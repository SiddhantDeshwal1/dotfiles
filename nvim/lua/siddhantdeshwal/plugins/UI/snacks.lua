--[[
  🧃 Snacks.nvim Setup (UI + Utilities)
  ------------------------------------
  🧠 What this file does:
    - Replaces Dressing.nvim popups with Snacks' input & picker UIs
    - Makes fuzzy finders open **at the bottom** (not in popup)
    - Adds buffer/zen/dashboard management utilities

  ⚙️ Features enabled here:
    ✅ Dashboard with shortcuts
    ✅ Zen mode toggle
    ✅ File rename integration (Oil support)
    ✅ Buffer deletion helpers
    ✅ Input & Picker UIs (replaces Dressing.nvim)
    ✅ Picker layout customized → open as bottom panel

  🧩 Tip: Remove or disable 'stevearc/dressing.nvim' plugin from your lazy setup
          since Snacks will now handle all UI prompts and fuzzy finders.
]]

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,

  init = function()
    -- Handle file renames from Oil (so that LSP gets notified properly)
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(event)
        if event.data.actions.type == "move" then
          Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
        end
      end,
    })
  end,

  keys = {
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Buffer delete",
      mode = "n",
    },
    {
      "<leader>ba",
      function()
        Snacks.bufdelete.all()
      end,
      desc = "Buffer delete all",
      mode = "n",
    },
    {
      "<leader>bo",
      function()
        Snacks.bufdelete.other()
      end,
      desc = "Buffer delete other",
      mode = "n",
    },
    {
      "<leader>bz",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
      mode = "n",
    },
  },

  opts = {
    bigfile = { enabled = true },

    -- 🏠 Dashboard (Startup screen)
    dashboard = {
      preset = {
        pick = nil,
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
                                                                             
               ████ ██████           █████      ██                     
              ███████████             █████                             
              █████████ ███████████████████ ███   ███████████   
             █████████  ███    █████████████ █████ ██████████████   
            █████████ ██████████ █████████ █████ █████ ████ █████   
          ███████████ ███    ███ █████████ █████ █████ ████ █████  
         ██████  █████████████████████ ████ █████ █████ ████ ██████ 
      ]],
      },
      sections = {
        { section = "header" },
        { section = "keys", indent = 1, padding = 1 },
        { section = "recent_files", icon = " ", title = "Recent Files", indent = 3, padding = 2 },
        { section = "startup" },
      },
    },

    -- 🍭 Enable core modules
    input = { enabled = true }, -- replaces Dressing's input popup
    picker = {
      enabled = true, -- replaces Dressing's select popup
      layout = "bottom", -- 👇 make fuzzy finder open below, not floating
      height = 12, -- height of the bottom panel
      border = "rounded", -- aesthetic border
    },
    notifier = { enabled = true },
    indent = { enabled = true },
    rename = { enabled = true },
    quickfile = { enabled = true },
    bigfile = { enabled = true },
    explorer = { enabled = false },
    scope = { enabled = false },
    words = { enabled = false },

    -- 🧘 Zen Mode setup
    zen = {
      enabled = true,
      toggles = {
        ufo = true,
        dim = true,
        git_signs = false,
        diagnostics = false,
        line_number = false,
        relative_number = false,
        signcolumn = "no",
        indent = false,
      },
    },
  },

  config = function(_, opts)
    require("snacks").setup(opts)

    -- Optional: add toggle command for folding
    Snacks.toggle.new({
      id = "ufo",
      name = "Enable/Disable ufo",
      get = function()
        return require("ufo").inspect()
      end,
      set = function(state)
        if state == nil then
          require("noice").enable()
          require("ufo").enable()
          vim.o.foldenable = true
          vim.o.foldcolumn = "1"
        else
          require("noice").disable()
          require("ufo").disable()
          vim.o.foldenable = false
          vim.o.foldcolumn = "0"
        end
      end,
    })
  end,
}
