local status_ok, ls = pcall(require, "luasnip")
if not status_ok then return end

ls.cleanup()

require("siddhantdeshwal.snippets.input_output")
require("siddhantdeshwal.snippets.run_debug") -- Add your other file like this

vim.keymap.set({ "i", "s" }, "<Tab>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
    end
end, { silent = true })
