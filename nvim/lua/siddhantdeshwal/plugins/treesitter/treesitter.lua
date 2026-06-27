return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        -- Safely import treesitter
        local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
        if not status_ok then
            return
        end

        -- Configure treesitter
        treesitter.setup({
            -- Enable syntax highlighting
            highlight = {
                enable = true,
            },
            
            -- Enable indentation
            indent = { 
                enable = true, 
                disable = { "cpp", "c" } 
            },

            -- Enable incremental selection
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },

            -- Ensure these language parsers are installed
            ensure_installed = {
                -- Web Dev
                "html", "css", "javascript", "typescript", "tsx", "json", "graphql", "svelte", "markdown", "markdown_inline",
                
                -- Java / Spring Boot
                "java",
                
                -- C++
                "c", "cpp",
                
                -- Python & Backend
                "python", "sql", "prisma",
                
                -- DevOps
                "bash", "yaml", "toml", "dockerfile", "gitignore", "terraform",
                
                -- Neovim core
                "lua", "vim", "vimdoc", "query",
            },
        })

        -- Configure nvim-ts-autotag
        local autotag_status_ok, autotag = pcall(require, "nvim-ts-autotag")
        if autotag_status_ok then
            autotag.setup()
        end
    end,
}
