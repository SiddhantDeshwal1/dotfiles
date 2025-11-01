return {
  "williamboman/mason.nvim",
  dependencies = {
    "whoIsSethDaniel/mason-tool-installer.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls",
        "html",
        "clangd",
        "cssls",
        "tailwindcss",
        "jedi_language_server", -- for Python/Django
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "marksman",
        "jdtls", -- <--- Java LSP
      },
    })
    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "stylua",
        "isort",
        "black", -- <- needed with isort
        "ruff",
        "flake8",
        "eslint_d",
        "pylint", -- if you're using it in nvim-lint
        "shfmt", -- for shell script formatting
        "beautysh", -- prettier shell formatter
        "shellcheck", -- shell linter
        "jsonlint", -- optional JSON linter
        "yamllint", -- optional YAML linter
        "djlint",
        "mypy",
        "google-java-format", -- <--- Java formatter
        "checkstyle", -- <--- optional Java linter
      },
    })
  end,
}
