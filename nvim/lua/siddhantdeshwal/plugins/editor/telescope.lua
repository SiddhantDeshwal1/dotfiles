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
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")

    -- Custom action: open file + reveal and expand in NvimTree
    local function open_file_and_reveal(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if not selection or not selection.path then
        actions.close(prompt_bufnr)
        return
      end

      local file_path = selection.path

      -- First: close Telescope (important order)
      actions.close(prompt_bufnr)

      -- Open the file in Neovim (using vim.cmd to avoid picker issues)
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))

      -- Then reveal and expand in NvimTree
      local ok, api = pcall(require, "nvim-tree.api")
      if ok then
        api.tree.find_file({ open = true, focus = false, buf = file_path })
      end
    end

    telescope.setup({
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
            ["<CR>"] = open_file_and_reveal,
          },
          n = {
            ["<CR>"] = open_file_and_reveal,
          },
        },
        find_command = {
          "fd",
          "--type", "f",
          "--hidden",
          "--follow",
          "--no-ignore",
          "--no-ignore-vcs",
          "--strip-cwd-prefix",
        },
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
      pickers = {
        find_files = {
          find_command = {
            "fd",
            "--type", "f",
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

    -- Keymaps
    local keymap = vim.keymap.set
    keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files (ignore .gitignore)" })
    keymap("n", "<leader>fs", builtin.live_grep, { desc = "Search text (ignore .gitignore)" })
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
  end,
}
