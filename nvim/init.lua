require("siddhantdeshwal.core")
require("siddhantdeshwal.lazy")
require("siddhantdeshwal.core.commands")

vim.opt.termguicolors = true
-- vim.o.showtabline = 0

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })

vim.g.mapleader = " "

-- alias of :W to work like :w
vim.cmd("command! W w")
-- alias of :Qa to work like q
vim.cmd("command! Qa qa")
-- Move current line up
vim.api.nvim_set_keymap("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
-- Move current line down
vim.api.nvim_set_keymap("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })

-- Ensure Django templates are recognized as htmldjango
vim.cmd([[
  autocmd BufRead,BufNewFile *.html set filetype=htmldjango
]])

vim.keymap.set("n", "<leader>r", ":Runcpp<CR>", { noremap = true, silent = true })

-- Map Ctrl + Backspace to delete the previous word in insert mode
-- Detect what Ctrl+Backspace sends and handle it in insert mode
vim.api.nvim_set_keymap("i", "<C-h>", "<C-w>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-?>", "<C-w>", { noremap = true, silent = true })

-- Move selected lines up in visual mode
vim.api.nvim_set_keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Move selected lines down in visual mode
vim.api.nvim_set_keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- copy current line down
vim.api.nvim_set_keymap("i", "<C-d>", "<Esc>mzyy`zP`za", { noremap = true, silent = true })

-- Move lines down in normal mode
vim.api.nvim_set_keymap("n", "<A-j>", ":move .+1<CR>==", { noremap = true, silent = true })

-- Move lines up in normal mode
vim.api.nvim_set_keymap("n", "<A-k>", ":move .-2<CR>==", { noremap = true, silent = true })

-- Move selected lines down in visual mode
vim.api.nvim_set_keymap("v", "<A-j>", ":move '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Move selected lines up in visual mode
vim.api.nvim_set_keymap("v", "<A-k>", ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_create_user_command("Snippet", function()
  -- Run js file
  vim.api.nvim_set_keymap("n", "<leader>js", ":!node %<CR>", { noremap = true, silent = true })

  local currDateTime = os.date("%dth %B %Y, %H:%M")

  -- Define the snippet as a table of strings
  local snippet = {
    "/****************************************************",
    "*                                                  *",
    "        author :  siddhantDeshwal                 ",
    "        date   : " .. currDateTime .. "           ",
    "*                                                  *",
    "****************************************************/",
    "",
    "#include <algorithm>",
    "#include <chrono>",
    "#include <climits>",
    "#include <cmath>",
    "#include <cstring>",
    "#include <iostream>",
    "#include <map>",
    "#include <queue>",
    "#include <set>",
    "#include <string>",
    "#include <unordered_map>",
    "#include <vector>",
    "",
    "using namespace std;",
    "using ll = signed long long int;",
    "",
    "// ;(",
    "struct custom_hash {",
    "  static uint64_t splitmix64(uint64_t x) {",
    "    x += 0x9e3779b97f4a7c15;",
    "    x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9;",
    "    x = (x ^ (x >> 27)) * 0x94d049bb133111eb;",
    "    return x ^ (x >> 31);",
    "  }",
    "",
    "  size_t operator()(uint64_t x) const {",
    "    static const uint64_t FIXED_RANDOM = chrono::steady_clock::now().time_since_epoch().count();",
    "    return splitmix64(x + FIXED_RANDOM);",
    "  }",
    "};",
    "",
    "ll isqrt(ll x) {",
    "  ll val = sqrtl(x) + 5;",
    "  while (val * val > x) val--;",
    "  return val;",
    "};",
    "",
    "const ll M = 1e9 + 7;",
    "",
    "#define ff first",
    "#define ss second",
    "#define pb push_back",
    "#define fl(i,start,end) for (int i = start ; i < end; i++)",
    "#define rfl(i,start,end) for (int i = start ; i >= end; i--)",
    "#define in(v) fl(i,0,v.size()) cin >> v[i];",
    "#define all(v) v.begin(), v.end()",
    "#define rall(v) v.end(), v.begin()",
    "#define csort(nums) sort(nums.begin(), nums.end());",
    "#define int long long",
    "",
    "typedef vector<ll> vll;",
    "typedef unordered_map<ll, ll, custom_hash> safehash;",
    "typedef vector<vector<int>> mat;",
    "",
    "template <typename T>",
    "void printvec(vector<T> v) {",
    "  ll n = v.size();",
    '  fl(i,0,n) cout << v[i] << " ";',
    '  cout << "\\n";',
    "}",
    "template <typename T>",
    "ll sumvec(vector<T> v) {",
    "  ll n = v.size();",
    "  ll s = 0;",
    "  fl(i,0,n) s += v[i];",
    "  return s;",
    "}",
    "",
    "ll moduloMultiplication(ll a, ll b, ll mod) {",
    "  ll res = 0;",
    "  a %= mod;",
    "  while (b) {",
    "    if (b & 1) res = (res + a) % mod;",
    "    a = (2 * a) % mod;",
    "    b >>= 1;",
    "  }",
    "  return res;",
    "}",
    "ll powermod(ll x, ll y, ll p) {",
    "  ll res = 1;",
    "  x = x % p;",
    "  if (x == 0) return 0;",
    "  while (y > 0) {",
    "    if (y & 1) res = (res * x) % p;",
    "    y = y >> 1;",
    "    x = (x * x) % p;",
    "  }",
    "  return res;",
    "}",
    "",
    "void solve() {",
    "    ",
    "}",
    "",
    "int32_t main() {",
    "  ios_base::sync_with_stdio(false);",
    "  cin.tie(NULL);",
    "",
    "  int t = 1;",
    "  cin >> t;",
    "  while (t--) {",
    "    solve();",
    "  }",
    "  return 0;",
    "}",
  }

  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, snippet)
  vim.cmd.normal({ "14k4l", bang = true })
  vim.api.nvim_command("startinsert!")
end, {})
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })

vim.keymap.set("n", "Qa", ":q<CR>", { noremap = true, silent = true })

vim.api.nvim_create_user_command("Html", function()
  local html = {
    "<!DOCTYPE html>",
    '<html lang="en">',
    "<head>",
    '    <meta charset="UTF-8">',
    '    <meta name="viewport" content="width=device-width, initial-scale=1.0">',
    "    <title>Document</title>",
    "</head>",
    "<body>",
    "",
    "</body>",
    "</html>",
  }
  local bufnr = vim.api.nvim_get_current_buf()

  -- Insert the snippet into the buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, html)

  -- Move cursor 18 lines up (or down if needed)
  vim.api.nvim_command("normal! 18k")
  vim.api.nvim_command("normal! 4l")
  vim.api.nvim_command("startinsert!")
end, {})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*/src/test/java/**/*.java",
  callback = function()
    -- Only insert if file is empty (avoid overwriting)
    if vim.fn.line("$") > 1 or vim.fn.getline(1) ~= "" then
      return
    end

    local filename = vim.fn.expand("%:t:r")
    local path = vim.fn.expand("%:p:h")
    local pkg = path:match("src/test/java/(.+)")
    if pkg then
      pkg = pkg:gsub("/", ".")
    else
      pkg = "com.example"
    end

    local boilerplate = string.format(
      [[
package %s;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class %s {
    @Test
    void testSomething() {
        // TODO: implement test
    }
}
]],
      pkg,
      filename
    )

    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(boilerplate, "\n"))
    vim.cmd("normal! G")
  end,
})

-- require('lualine').setup {
--   options = {
--     icons_enabled = true,
--     theme = 'auto',
--     component_separators = { left = '', right = ''},
--     section_separators = { left = '', right = ''},
--     disabled_filetypes = {
--       statusline = {},
--       winbar = {},
--     },
--     ignore_focus = {},
--     always_divide_middle = true,
--     always_show_tabline = true,
--     globalstatus = false,
--     refresh = {
--       statusline = 100,
--       tabline = 100,
--       winbar = 100,
--     }
--   },
--   sections = {
--     lualine_a = {'mode'},
--     lualine_b = {'branch', 'diff', 'diagnostics'},
--     lualine_c = {'filename'},
--     lualine_x = {'encoding', 'fileformat', 'filetype'},
--     lualine_y = {'progress'},
--     lualine_z = {'location'}
--   },
--   inactive_sections = {
--     lualine_a = {},
--     lualine_b = {},
--     lualine_c = {'filename'},
--     lualine_x = {'location'},
--     lualine_y = {},
--     lualine_z = {}
--   },
--   tabline = {},
--   winbar = {},
--   inactive_winbar = {},
--   extensions = {}
-- }
