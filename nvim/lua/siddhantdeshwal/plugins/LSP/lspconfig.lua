return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/nvim-cmp", -- Completion engine
    "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", opts = {} },
    { "williamboman/mason-lspconfig.nvim" },
  },

  config = function()
    ---------------------------------------------------------------------------
    -- ✅ Safe imports
    ---------------------------------------------------------------------------
    local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if not ok_cmp_lsp then
      vim.notify("cmp_nvim_lsp not found!", vim.log.levels.ERROR)
      return
    end

    local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not ok_mason_lspconfig then
      vim.notify("mason-lspconfig not found!", vim.log.levels.ERROR)
      return
    end

    ---------------------------------------------------------------------------
    -- 🧠 Capabilities + Diagnostics
    ---------------------------------------------------------------------------
    local capabilities = cmp_nvim_lsp.default_capabilities()

    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = true,
      severity_sort = true,
    })

    ---------------------------------------------------------------------------
    -- ⚡ on_attach: LSP-specific keymaps
    ---------------------------------------------------------------------------
    local on_attach = function(_, bufnr)
      local keymap = vim.keymap
      local opts = { buffer = bufnr, silent = true }

      keymap.set("n", "K", vim.lsp.buf.hover, opts)
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

      -- 🚀 Go to definition (opens in new tab if file differs)
      keymap.set("n", "gd", function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
          if err or not result or vim.tbl_isempty(result) then
            vim.notify("No definition found", vim.log.levels.WARN)
            return
          end
          local target = result[1]
          local target_path = vim.uri_to_fname(target.uri)
          local current_path = vim.api.nvim_buf_get_name(0)
          if target_path ~= current_path then
            vim.cmd("tabnew " .. vim.fn.fnameescape(target_path))
          end
          vim.schedule(function()
            vim.lsp.util.jump_to_location(target, "utf-8")
          end)
        end)
      end, opts)
    end

    ---------------------------------------------------------------------------
    -- 🧩 Mason + LSPConfig Setup
    ---------------------------------------------------------------------------
    mason_lspconfig.setup()
    local lspconfig = require("lspconfig")

    for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end
  end,
}
