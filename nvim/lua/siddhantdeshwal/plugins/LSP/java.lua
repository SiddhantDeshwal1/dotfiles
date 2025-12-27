return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local ok, jdtls = pcall(require, "jdtls")
    if not ok then
      return
    end

    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

    local root_dir = require("jdtls.setup").find_root({
      ".git",
      "mvnw",
      "gradlew",
      "pom.xml",
      "build.gradle",
    })

    if root_dir == "" then
      return
    end

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local config = {
      cmd = { "jdtls", "-data", workspace_dir },
      root_dir = root_dir,
      capabilities = capabilities,
      settings = {
        java = {
          signatureHelp = { enabled = true },
        },
      },

      on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufReadCmd", {
          pattern = "jdt://*",
          callback = function(args)
            pcall(vim.api.nvim_buf_set_option, args.buf, "modifiable", true)
            pcall(vim.api.nvim_buf_set_option, args.buf, "readonly", false)
          end,
        })

        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", function()
          vim.lsp.buf.definition()
        end, opts)
      end,
    }

    jdtls.start_or_attach(config)
  end,
}
