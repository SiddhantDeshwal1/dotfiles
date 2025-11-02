vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & spaces
opt.tabstop = 4 -- 4 spaces for tabs
opt.shiftwidth = 4 --4 spaces for indent
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indentfrom current line to next line

opt.wrap = false

-- search setting example Example
opt.ignorecase = true -- ignore case while searching
opt.smartcase = true -- if you include mixed case in you search , assumes you want case sentive

-- used for highlighting current line
opt.cursorline = true

opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light dark
opt.signcolumn = "yes" -- show sign column so that text doesnt shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent , end of line or insert mode start posn

--clipboard
opt.clipboard:append("unnamedplus") -- uses system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to right
opt.splitbelow = true -- split horizontal window to bottom

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
