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
                prompt_prefix = " ",
                selection_caret = " ",
                path_display = { "smart" },
                border = false,
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<esc>"] = actions.close,
                        -- Note: We removed the <CR> override.
                        -- Telescope's native <CR> already handles opening files and exact line jumps instantly.
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

        keymap("n", "<leader>fs", builtin.live_grep, { desc = "Search text in project (jump to line)" })
        keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
        keymap("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
        keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
        keymap("n", "<leader>fr", builtin.resume, { desc = "Resume last Telescope search" })
    end,
}
