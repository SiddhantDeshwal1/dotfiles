return {
    "williamboman/mason.nvim",
    dependencies = {
        "whoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        require("mason-tool-installer").setup({
            ensure_installed = {
                -- Formatters & Linters
                "prettier",
                "black",
                "isort",
                "clang-format",
                "google-java-format",
                "eslint_d",
                "shfmt",
            },
        })
    end,
}
