-- State to track our input/output windows
local cp_io_wins = { input = nil, output = nil }

local function toggle_cp_io()
    local input_valid = cp_io_wins.input and vim.api.nvim_win_is_valid(cp_io_wins.input)
    local output_valid = cp_io_wins.output and vim.api.nvim_win_is_valid(cp_io_wins.output)

    if input_valid or output_valid then
        if input_valid then vim.api.nvim_win_close(cp_io_wins.input, true) end
        if output_valid then vim.api.nvim_win_close(cp_io_wins.output, true) end
        cp_io_wins.input = nil
        cp_io_wins.output = nil
        return
    end

    local main_win = vim.api.nvim_get_current_win()
    local dir = vim.fn.expand('%:p:h')
    if dir == "" then dir = vim.fn.getcwd() end

    local input_file = dir .. '/input.txt'
    local output_file = dir .. '/output.txt'

    if vim.fn.filereadable(input_file) == 0 then io.open(input_file, "w"):close() end
    if vim.fn.filereadable(output_file) == 0 then io.open(output_file, "w"):close() end

    local total_width = vim.o.columns
    local right_width = math.floor(total_width * 0.3)

    -- 1. Create the right-hand column for input.txt (botright vsplit is correct here)
    vim.cmd('botright vsplit ' .. vim.fn.fnameescape(input_file))
    cp_io_wins.input = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(cp_io_wins.input, right_width)

    -- 2. Split THAT specific column horizontally for output.txt
    -- (Changed 'botright split' to 'belowright split')
    vim.cmd('belowright split ' .. vim.fn.fnameescape(output_file))
    cp_io_wins.output = vim.api.nvim_get_current_win()

    -- Turn off line numbers for clean UI
    vim.opt.number = true      -- Keep the line number column on
    vim.opt.relativenumber = false -- Force standard, sequential numbering
    vim.api.nvim_set_current_win(cp_io_wins.input)
    vim.opt.number = true      -- Keep the line number column on
    vim.opt.relativenumber = false -- Force standard, sequential numbering

    -- Return cursor to main window
    vim.api.nvim_set_current_win(main_win)
end

vim.keymap.set('n', '<leader>io', toggle_cp_io, { noremap = true, silent = true, desc = "Toggle CP Input/Output Split" })
