-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment 11
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })                   -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })                 -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })                    -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })               -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })                     -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })              -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })                     --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })                 --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- LSP
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

-- Save/Quit aliases
vim.cmd("command! W w")
vim.cmd("command! Qa qa")
vim.keymap.set("n", "Qa", ":q<CR>", opts)

-- Move lines up/down (normal mode)
map("n", "<A-j>", ":move .+1<CR>==", opts)
map("n", "<A-k>", ":move .-2<CR>==", opts)

-- Move lines up/down (visual mode)
map("v", "<A-j>", ":move '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":move '<-2<CR>gv=gv", opts)

-- Ctrl+Backspace to delete previous word (insert mode)
map("i", "<C-h>", "<C-w>", opts)
map("i", "<C-BS>", "<C-w>", opts)
map("i", "<C-?>", "<C-w>", opts)

-- Duplicate current line (insert mode)
map("i", "<C-d>", "<Esc>mzyy`zP`za", opts)

-- Instantly opens NvimTree and highlights the file you are currently viewing
vim.keymap.set("n", "<leader>nf", "<cmd>NvimTreeFindFile<CR>",
    { noremap = true, silent = true, desc = "Reveal current file in NvimTree" })
