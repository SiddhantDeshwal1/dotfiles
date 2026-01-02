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

    ------------------------------------------------------------------
    -- Custom action: open file, jump to exact line, reveal in NvimTree
    ------------------------------------------------------------------
    local function open_file_jump_and_reveal(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if not entry then
        actions.close(prompt_bufnr)
        return
      end

      local file_path =
        entry.path
        or entry.filename
        or entry.value

      local line =
        entry.row
        or entry.lnum
        or 1

      actions.close(prompt_bufnr)

      -- 1. Open file normally (buffer-safe)
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))

      -- 2. Jump AFTER buffer is fully loaded
      vim.schedule(function()
        pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
      end)

      -- 3. Reveal in NvimTree AFTER file exists
      vim.schedule(function()
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.find_file({
            open = true,
            focus = false,
            buf = file_path,
          })
        end
      end)
    end

    ------------------------------------------------------------------
    -- Telescope setup
    ------------------------------------------------------------------
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
            ["<CR>"] = open_file_jump_and_reveal,
          },
          n = {
            ["<CR>"] = open_file_jump_and_reveal,
          },
        },
      },

      pickers = {
        live_grep = {
          additional_args = function()
            return {
              "--hidden",
              "--no-ignore",
              "--no-ignore-vcs",
            }
          end,
        },

        find_files = {
          hidden = true,
          no_ignore = true,
        },
      },
    })

    telescope.load_extension("fzf")

    ------------------------------------------------------------------
    -- Keymaps
    ------------------------------------------------------------------
    local keymap = vim.keymap.set

    -- Project-wide text search → jumps to exact line
    keymap("n", "<leader>fs", builtin.live_grep, {
      desc = "Search text in project (jump to line)",
    })

    -- Filename search
    keymap("n", "<leader>ff", builtin.find_files, {
      desc = "Find files",
    })

    -- Word under cursor → exact jump
    keymap("n", "<leader>fw", builtin.grep_string, {
      desc = "Grep word under cursor",
    })

    -- TODOs
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", {
      desc = "Find TODOs",
    })

    -- Resume last picker
    keymap("n", "<leader>fr", builtin.resume, {
      desc = "Resume last Telescope search",
    })
  end,
}
