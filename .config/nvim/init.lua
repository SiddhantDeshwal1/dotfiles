require("siddhantdeshwal.core")
require("siddhantdeshwal.lazy")

vim.opt.termguicolors = true

vim.g.mapleader = " "

-- Move current line up
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true })
-- Move current line down
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true })

-- Move selected lines up in visual mode
vim.api.nvim_set_keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Move selected lines down in visual mode
vim.api.nvim_set_keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- copy current line down
vim.api.nvim_set_keymap('i', '<C-d>', '<Esc>mzyy`zP`za', { noremap = true, silent = true })

-- Move lines down in normal mode
vim.api.nvim_set_keymap('n', '<A-j>', ':move .+1<CR>==', { noremap = true, silent = true })

-- Move lines up in normal mode
vim.api.nvim_set_keymap('n', '<A-k>', ':move .-2<CR>==', { noremap = true, silent = true })

-- Move selected lines down in visual mode
vim.api.nvim_set_keymap('v', '<A-j>', ":move '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Move selected lines up in visual mode
vim.api.nvim_set_keymap('v', '<A-k>', ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_create_user_command("Snippet", function()

-- Run js file
vim.api.nvim_set_keymap('n', '<leader>js', ':!node %<CR>', { noremap = true, silent = true })

    local currDateTime = os.date("%dth %B %Y, %H:%M")

	-- Define the snippet as a table of strings
	local snippet = {
	"/****************************************************",
	"*                                                  *",
	"        Author : siddhantDeshwal                 ",
	"        Date   : " .. currDateTime .. "           ",
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
		"struct custom_hash",
		"{",
		"  static uint64_t",
		"  splitmix64 (uint64_t x)",
		"  {",
		"    x += 0x9e3779b97f4a7c15;",
		"    x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9;",
		"    x = (x ^ (x >> 27)) * 0x94d049bb133111eb;",
		"    return x ^ (x >> 31);",
		"  }",
		"",
		"  size_t",
		"  operator() (uint64_t x) const",
		"  {",
		"    static const uint64_t FIXED_RANDOM",
		"        = chrono::steady_clock::now ().time_since_epoch ().count ();",
		"    return splitmix64 (x + FIXED_RANDOM);",
		"  }",
		"};",
		"",
		"const ll M = 1e9 + 7;",
		"",
		"// Typedef",
		"typedef vector<ll> vll;",
		"typedef unordered_map<ll, ll, custom_hash> safehash;",
		"",
		"// Macros",
		"#define ff first",
		"#define ss second",
		"#define pb push_back",
		"#define mp make_pair",
		"#define fl(i, n) for (int i = 0; i < n; i++)",
		"#define in(v) fl (i, v.size ()) cin >> v[i];",
		'#define py cout << "YES\\n";',
		'#define pm cout << "-1\\n";',
		'#define pn cout << "NO\\n";',
		'#define pimp cout << "IMPOSSIBLE\\n";',
		"#define vr(v) v.begin (), v.end ()",
		"#define rv(v) v.end (), v.begin ()",
		"#define csort(nums) sort (nums.begin (), nums.end ());",
		"#define sum(v) accumulate (v.begin (), v.end (), 0LL);",
		"#define int long long",
        "#define print(x) cout << x << endl ;",
		"",
		"// Utility functions",
		"template <typename T>",
		"void",
		"printvec (vector<T> v)",
		"{",
		"  ll n = v.size ();",
		'  fl (i, n) cout << v[i] << " ";',
		'  cout << "\\n";',
		"}",
		"template <typename T>",
		"ll",
		"sumvec (vector<T> v)",
		"{",
		"  ll n = v.size ();",
		"  ll s = 0;",
		"  fl (i, n) s += v[i];",
		"  return s;",
		"}",
		"",
		"// Mathematical functions",
		"ll",
		"gcd (ll a, ll b)",
		"{",
		"  if (b == 0)",
		"    return a;",
		"  return gcd (b, a % b);",
		"} //__gcd",
		"ll",
		"lcm (ll a, ll b)",
		"{",
		"  return (a / gcd (a, b) * b);",
		"}",
		"ll",
		"moduloMultiplication (ll a, ll b, ll mod)",
		"{",
		"  ll res = 0;",
		"  a %= mod;",
		"  while (b)",
		"    {",
		"      if (b & 1)",
		"        res = (res + a) % mod;",
		"      b >>= 1;",
		"    }",
		"  return res;",
		"}",
		"ll",
		"powermod (ll x, ll y, ll p)",
		"{",
		"  ll res = 1;",
		"  x = x % p;",
		"  if (x == 0)",
		"    return 0;",
		"  while (y > 0)",
		"    {",
		"      if (y & 1)",
		"        res = (res * x) % p;",
		"      y = y >> 1;",
		"      x = (x * x) % p;",
		"    }",
		"  return res;",
		"}",
		"// Check",
		"bool",
		"isPrime (ll n)",
		"{",
		"  if (n <= 1)",
		"    return false;",
		"  if (n <= 3)",
		"    return true;",
		"  if (n % 2 == 0 || n % 3 == 0)",
		"    return false;",
		"  for (int i = 5; i * i <= n; i = i + 6)",
		"    if (n % i == 0 || n % (i + 2) == 0)",
		"      return false;",
		"  return true;",
		"}",
		"",
		"void",
		"solve ()",
		"{",
		"  ",
		"}",
		"",
		"int32_t",
		"main ()",
		"{",
		"  ios_base::sync_with_stdio (false);",
		"  cin.tie (NULL);",
		"",
		"  int t = 1;",
		"  cin >> t ;",
		"",
		"  while (t--)",
		"    {",
		"      solve ();",
		"    }",
		"",
		"  return 0;",
		"}",
	}

	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- Insert the snippet into the buffer
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, snippet)

	-- Move cursor 18 lines up (or down if needed)
	vim.api.nvim_command("normal! 19k")

	vim.api.nvim_command("startinsert!")
end, {})

-- vim.keymap.set("i", "<C-H>", "<C-w>", { noremap = true, silent = true })

vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })


vim.api.nvim_create_user_command("Html", function()
        local html = {
        "<!DOCTYPE html>",
            "<html lang=\"en\">",
            "<head>",
            "    <meta charset=\"UTF-8\">",
            "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
            "    <title>Document</title>",
            "</head>",
            "<body>",
            "",
            "</body>",
            "</html>"

    }
	local bufnr = vim.api.nvim_get_current_buf()

	-- Insert the snippet into the buffer
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, html)

	-- Move cursor 18 lines up (or down if needed)
	vim.api.nvim_command("normal! 3k")

	vim.api.nvim_command("startinsert!")
end, {})
