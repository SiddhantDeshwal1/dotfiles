return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvimtree = require("nvim-tree")

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = { width = 35 },
      renderer = {
        indent_markers = { enable = true },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
            modified = "➜",  -- Red arrow glyph for current file indicator
          },
          show = {
            modified = true,  -- Show the arrow on current file
          },
        },
        highlight_opened_files = "name",  -- Highlight other opened files (blue)
        highlight_modified = "icon",      -- Use icon color for the arrow (we'll make it red)
      },
      filters = { custom = { ".DS_Store" } },
      git = { ignore = false },
      actions = {
        open_file = { window_picker = { enable = false } },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
        ignore_list = {},
      },
      modified = {
        enable = true,  -- Enable modified system (reused for current file arrow)
      },
    })

    -- Transparency
    vim.cmd([[
      hi NvimTreeNormal guibg=NONE ctermbg=NONE
      hi NvimTreeNormalNC guibg=NONE ctermbg=NONE
      hi NvimTreeEndOfBuffer guibg=NONE ctermbg=NONE
      hi NvimTreeWinSeparator guibg=NONE guifg=#444444
    ]])

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.cmd([[
          hi NvimTreeNormal guibg=NONE ctermbg=NONE
          hi NvimTreeNormalNC guibg=NONE ctermbg=NONE
          hi NvimTreeEndOfBuffer guibg=NONE ctermbg=NONE
          hi NvimTreeWinSeparator guibg=NONE guifg=#444444
        ]])
      end,
    })

    -- Other opened files: Blue font color
    vim.api.nvim_set_hl(0, "NvimTreeOpenedHL", { fg = "#89b4fa" })

    -- Current file: Orange font color
    vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { fg = "#ff8800", bold = true })  -- Orange text on cursor line

    -- Red ➜ arrow for current file (reuses modified icon)
    vim.api.nvim_set_hl(0, "NvimTreeModifiedIcon", { fg = "#ff0000", bold = true })

    -- Re-apply on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.api.nvim_set_hl(0, "NvimTreeOpenedHL", { fg = "#89b4fa" })
        vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { fg = "#ff8800", bold = true })
        vim.api.nvim_set_hl(0, "NvimTreeModifiedIcon", { fg = "#ff0000", bold = true })
      end,
    })

    -- Keymaps
    local keymap = vim.keymap
    keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Find file in explorer" })
    keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse all folders" })
    keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh explorer" })
  end,
}
