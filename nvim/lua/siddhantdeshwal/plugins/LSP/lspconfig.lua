return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/nvim-cmp", -- Completion engine
    "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", opts = {} },
  },

  config = function()
    -- Import dependencies safely
    local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if not ok_cmp_lsp then
      vim.notify("cmp_nvim_lsp not found! Please ensure 'hrsh7th/cmp-nvim-lsp' is installed.", vim.log.levels.ERROR)
      return
    end

    local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not ok_mason_lspconfig then
      vim.notify(
        "mason-lspconfig not found! Please ensure 'williamboman/mason-lspconfig.nvim' is installed.",
        vim.log.levels.ERROR
      )
      return
    end

    -- Use the new vim.lsp.config API (Neovim 0.11+)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = true,
    })

    -- Setup Mason and all installed servers
    mason_lspconfig.setup()

    for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
      vim.lsp.config(server, {
        capabilities = capabilities,
        on_attach = function(_, bufnr)
          local keymap = vim.keymap
          local opts = { buffer = bufnr, silent = true }

          -- Hover docs
          keymap.set("n", "K", vim.lsp.buf.hover, opts)

          -- Rename & Code actions
          keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

          -- Diagnostics
          keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

          -- Declaration
          keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

          ----------------------------------------------------------------------
          -- 🚀 Open LSP Definition in a new tab (instead of same window)
          ----------------------------------------------------------------------
          -- Go to definition — open in new tab only if it's in another file
          keymap.set("n", "gd", function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
              if err or not result or vim.tbl_isempty(result) then
                vim.notify("No definition found", vim.log.levels.WARN)
                return
              end

              local target = result[1]
              local current_buf = vim.api.nvim_buf_get_name(0)

              -- Only open in a new tab if the definition is in a different file
              if target.uri and vim.uri_to_fname(target.uri) ~= current_buf then
                vim.cmd("tabnew")
              end

              vim.lsp.util.jump_to_location(target, "utf-8")
            end)
          end, opts)

          vim.lsp.config(server, {
            capabilities = capabilities,
            on_attach = function(_, bufnr)
              local keymap = vim.keymap
              local opts = { buffer = bufnr, silent = true }

              keymap.set("n", "K", vim.lsp.buf.hover, opts)
              keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
              keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
              keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
              keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
              keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

              ----------------------------------------------------------------------
              -- 🚀 Open LSP Definition in a new tab (Java included)
              ----------------------------------------------------------------------
              keymap.set("n", "gd", function()
                local params = vim.lsp.util.make_position_params()
                vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
                  if err or not result or vim.tbl_isempty(result) then
                    vim.notify("No definition found", vim.log.levels.WARN)
                    return
                  end

                  local target = result[1]
                  local current_buf = vim.api.nvim_buf_get_name(0)

                  -- Only open new tab if it's another file
                  if target.uri and vim.uri_to_fname(target.uri) ~= current_buf then
                    vim.cmd("tabnew")
                  end

                  vim.lsp.util.jump_to_location(target, "utf-8")
                end)
              end, opts)
            end,
          })
        end,
      })
    end
  end,
}
