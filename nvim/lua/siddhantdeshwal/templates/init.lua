local function insert_template(mod_name)
    local ok, t = pcall(require, "siddhantdeshwal.templates." .. mod_name)
    if not ok then return end
    local lines = t.lines()

    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {}) -- clears the file (%d equivalent)
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, lines)
    if t.cursor_offset then
        local target_line = #lines + t.cursor_offset -- cursor_offset is negative
        vim.api.nvim_win_set_cursor(0, { math.max(1, target_line), 4 })
    end
    vim.cmd("startinsert!")
end

vim.api.nvim_create_user_command("Cpt", function()
    vim.keymap.set("n", "<leader>js", ":!node %<CR>", { noremap = true, silent = true })
    insert_template("cp")
end, {})

vim.api.nvim_create_user_command("Html", function()
    insert_template("html")
end, {})

local java = require("siddhantdeshwal.templates.java")
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    pattern = "*/src/test/java/**/*.java",
    callback = java.insert_junit,
})
