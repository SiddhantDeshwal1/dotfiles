return {
    "williamboman/mason.nvim",
    dependencies = {
        "whoIsSethDaniel/mason-tool-installer.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

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
            ensure_installed = {
                -- "tsserver", -- FIXED: correct TypeScript server
                "html",
                "clangd",
                "cssls",
                "tailwindcss",
                "jedi_language_server",
                "svelte",
                "lua_ls",
                "graphql",
                "emmet_ls",
                "prismals",
                "pyright",
                "marksman",
                "jdtls",
            },
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier",
                "isort",
                "black",
                "ruff",
                "flake8",
                "eslint_d",
                "pylint",
                "shfmt",
                "beautysh",
                "shellcheck",
                "jsonlint",
                "yamllint",
                "djlint",
                "mypy",
                "google-java-format",
                "checkstyle",
            },
        })
    end,
}
