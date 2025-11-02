return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },

  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        prompt_prefix = "  ",
        selection_caret = " ",
        path_display = { "smart" },

        -- ✅ force fd to ignore .gitignore and include hidden files
        find_command = {
          "fd",
          "--type",
          "f",
          "--hidden",
          "--follow",
          "--no-ignore",
          "--no-ignore-vcs",
          "--strip-cwd-prefix",
        },

        -- ✅ force ripgrep to ignore .gitignore too
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--no-ignore",
          "--no-ignore-global",
          "--no-ignore-vcs",
        },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
          },
        },
      },

      pickers = {
        -- 🔍 Make sure find_files picker always ignores .gitignore
        find_files = {
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--follow",
            "--no-ignore",
            "--no-ignore-vcs",
            "--strip-cwd-prefix",
          },
        },
        live_grep = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore",
            "--no-ignore-global",
            "--no-ignore-vcs",
          },
        },
      },
    })

    telescope.load_extension("fzf")

    local keymap = vim.keymap.set
    keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files (ignore .gitignore)" })
    keymap("n", "<leader>fs", builtin.live_grep, { desc = "Search text (ignore .gitignore)" })
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
  end,
}
