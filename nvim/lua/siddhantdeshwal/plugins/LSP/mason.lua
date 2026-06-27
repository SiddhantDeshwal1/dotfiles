return {
    "williamboman/mason.nvim",
    dependencies = {
        "whoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        -- Safely import mason
        local mason_status_ok, mason = pcall(require, "mason")
        if not mason_status_ok then
            return
        end

        -- Safely import mason-tool-installer
        local installer_status_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
        if not installer_status_ok then
            return
        end

        -- Configure Mason UI
        mason.setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        -- Configure tools to automatically install
        mason_tool_installer.setup({
            ensure_installed = {
                -- Web Dev
                "prettier",
                "eslint_d",

                -- Python
                "black",      -- Formatter
                "isort",      -- Import sorter
                "ruff",       -- Extremely fast linter

                -- C / C++
                "clang-format",
                "cpplint",

                -- Java / Spring Boot
                "google-java-format",
                "checkstyle",

                -- DevOps (Bash, Docker, Terraform, YAML)
                "shfmt",      -- Shell script formatter
                "shellcheck", -- Shell script linter
                "hadolint",   -- Dockerfile linter
                "tflint",     -- Terraform linter
                "yamllint",   -- YAML linter

                -- Database / SQL
                "sqlfluff",   -- SQL linter and formatter
            },
            
            -- Automatically update these tools when an update is available
            auto_update = true,
            
            -- Automatically trigger installation/checking when Neovim starts
            run_on_start = true,
        })
    end,
}
