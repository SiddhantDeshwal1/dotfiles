return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    -------------------------------------------------------------------------
    -- 🎨 Colors
    -------------------------------------------------------------------------
    local colors = {
      blue = "#3B82F6",
      green = "#22C55E",
      violet = "#A855F7",
      yellow = "#FACC15",
      red = "#EF4444",
      fg = "#E5E5E5",
      bg = "#000000",
      inactive_bg = "#000000",
    }

    -------------------------------------------------------------------------
    -- 🧠 Theme
    -------------------------------------------------------------------------
    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.fg },
        c = { bg = colors.inactive_bg, fg = colors.fg },
      },
    }

    -------------------------------------------------------------------------
    -- ⚙️ Custom Components
    -------------------------------------------------------------------------
    local function lsp_status()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        return ""
      end
      local names = {}
      for _, c in ipairs(clients) do
        table.insert(names, c.name)
      end
      return "  " .. table.concat(names, ", ")
    end

    local function lsp_references()
      local ref_count = vim.b.lsp_references_count or 0
      return ref_count > 0 and (" " .. ref_count .. " refs") or ""
    end

    local function clock()
      if vim.o.columns > 120 then
        return " " .. os.date("%H:%M")
      end
      return ""
    end

    -------------------------------------------------------------------------
    -- 🚀 Setup
    -------------------------------------------------------------------------
    lualine.setup({
      options = {
        theme = my_lualine_theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          {
            function()
              local icons = {
                n = " NORMAL",
                i = " INSERT",
                v = " VISUAL",
                V = " V-LINE",
                [""] = " V-BLOCK",
                c = " COMMAND",
                R = "󰛔 REPLACE",
                t = " TERMINAL",
              }
              return icons[vim.fn.mode()] or vim.fn.mode()
            end,
          },
        },
        lualine_b = { "branch", "diff" },
        lualine_c = {
          { "filename", path = 1 },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            diagnostics_color = {
              error = { fg = colors.red },
              warn = { fg = colors.yellow },
              info = { fg = colors.blue },
              hint = { fg = colors.green },
            },
          },
          { lsp_references, color = { fg = colors.yellow } },
        },
        lualine_x = {
          { lsp_status, color = { fg = colors.violet } },
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat", symbols = { unix = "" } },
          { "filetype" },
          { clock, color = { fg = colors.green } },
        },
        lualine_y = {},
        lualine_z = { "progress", "location" },
      },
    })
  end,
}
