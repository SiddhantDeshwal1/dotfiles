local M = {}

-- Called via autocmd, not a user command
M.insert_junit = function()
    if vim.fn.line("$") > 1 or vim.fn.getline(1) ~= "" then return end

    local filename = vim.fn.expand("%:t:r")
    local path     = vim.fn.expand("%:p:h")
    local pkg      = path:match("src/test/java/(.+)")
    pkg            = pkg and pkg:gsub("/", ".") or "com.example"

    local lines    = {
        "package " .. pkg .. ";",
        "",
        "import org.junit.jupiter.api.Test;",
        "import static org.junit.jupiter.api.Assertions.*;",
        "",
        "public class " .. filename .. " {",
        "    @Test",
        "    void testSomething() {",
        "        // TODO: implement test",
        "    }",
        "}",
        "",
    }

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd("normal! G")
end

return M
