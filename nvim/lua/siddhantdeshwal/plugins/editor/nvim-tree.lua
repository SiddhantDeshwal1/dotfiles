return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    -- disable netrw (required)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      view = {
        width = 35,
      },

      renderer = {
        indent_markers = {
          enable = true,
        },

        icons = {
          show = {
            modified = true, -- reused for focused arrow
          },
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
            modified = "➜", -- arrow glyph
          },
        },

        highlight_opened_files = "name",
        highlight_modified = "icon",
      },

      modified = {
        enable = true,
      },

      git = {
        ignore = false,
      },

      filters = {
        custom = { ".DS_Store" },
      },

      actions = {
        open_file = {
          window_picker = { enable = false },
        },
      },

      update_focused_file = {
        enable = true,
        update_root = false,
      },
    })

    -- single source of truth for highlights
    local function set_nvimtree_hl()
      -- transparency
      vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
      vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", {
        fg = "#444444",
        bg = "none",
      })

      -- focused file (text + arrow)
      vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
        fg = "#ff0000", -- red
        bold = true,
      })

      -- opened but not focused
      vim.api.nvim_set_hl(0, "NvimTreeOpenedFile", {
        fg = "#89b4fa", -- blue
      })

      -- real modified (unsaved) file name
      vim.api.nvim_set_hl(0, "NvimTreeModifiedFile", {
        fg = "#f9e2af", -- yellow
      })

      -- hide arrow for real modified files
      vim.api.nvim_set_hl(0, "NvimTreeModifiedIcon", {
        fg = "none",
      })
    end

    set_nvimtree_hl()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_nvimtree_hl,
    })

    -- keymaps
    local map = vim.keymap.set
    map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle tree" })
    map("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Find file" })
    map("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse tree" })
    map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh tree" })
  end,
}
