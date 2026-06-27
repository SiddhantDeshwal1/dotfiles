return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason.nvim", -- Dependency added to fetch Lombok path
    },
    config = function()
        local ok, jdtls = pcall(require, "jdtls")
        if not ok then
            return
        end

        local home = os.getenv("HOME")
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

        -- Find root files for Java project environments
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

        -- Dynamic path resolution for Mason-installed components (like Lombok)
        local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
        local lombok_param = ""
        
        if mason_registry_ok and mason_registry.is_installed("jdtls") then
            local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
            local lombok_path = jdtls_path .. "/lombok.jar"
            if vim.fn.filereadable(lombok_path) == 1 then
                lombok_param = string.format("-javaagent:%s", lombok_path)
            end
        end

        -- Build the JDTLS command dynamically line by line
        local cmd = { "jdtls", "-data", workspace_dir }
        if lombok_param ~= "" then
            table.insert(cmd, lombok_param)
        end

        local config = {
            cmd = cmd,
            root_dir = root_dir,
            capabilities = capabilities,
            settings = {
                java = {
                    signatureHelp = { enabled = true },
                    contentProvider = { preferred = "fernflower" }, -- Better class file decompiler
                    completion = {
                        favoriteStaticMembers = {
                            "org.hamcrest.MatcherAssert.assertThat",
                            "org.hamcrest.Matchers.*",
                            "org.hamcrest.CoreMatchers.*",
                            "org.junit.jupiter.api.Assertions.*",
                            "java.util.Objects.requireNonNull",
                            "java.util.Objects.requireNonNullElse",
                            "org.mockito.Mockito.*",
                        },
                        filteredTypes = {
                            "com.sun.*",
                            "sun.*",
                            "org.graalvm.*",
                            "vk.*",
                        },
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = "${object.className}[fields=${member.name()}=${member.value}, ${otherMembers}]",
                        },
                        useBlocks = true,
                    },
                },
            },

            on_attach = function(_, bufnr)
                -- Fix jdt:// buffer options so decompiled class files read correctly
                vim.api.nvim_create_autocmd("BufReadCmd", {
                    pattern = "jdt://*",
                    callback = function(args)
                        pcall(vim.api.nvim_buf_set_option, args.buf, "modifiable", true)
                        pcall(vim.api.nvim_buf_set_option, args.buf, "readonly", false)
                    end,
                })

                local opts = { buffer = bufnr, silent = true }
                local keymap = vim.keymap.set

                -- Core LSP Keymaps
                keymap("n", "K", vim.lsp.buf.hover, opts)
                keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
                keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                keymap("n", "[d", vim.diagnostic.goto_prev, opts)
                keymap("n", "]d", vim.diagnostic.goto_next, opts)
                keymap("n", "gD", vim.lsp.buf.declaration, opts)

                -- Synchronized Smart gd: Opens in a new tab if definition is in another file
                keymap("n", "gd", function()
                    local params = vim.lsp.util.make_position_params()
                    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
                        if err or not result or vim.tbl_isempty(result) then
                            vim.notify("No definition found", vim.log.levels.WARN)
                            return
                        end

                        local target = vim.islist(result) and result[1] or result
                        local uri = target.uri or target.targetUri
                        local target_path = vim.uri_to_fname(uri)
                        local current_path = vim.api.nvim_buf_get_name(0)

                        if target_path ~= current_path then
                            vim.cmd("tabnew " .. vim.fn.fnameescape(target_path))
                        end

                        vim.schedule(function()
                            vim.lsp.util.jump_to_location(target, "utf-8")
                        end)
                    end)
                end, opts)

                -- Java Specific Specialized Shortcuts
                keymap("n", "<leader>jo", jdtls.organize_imports, { buffer = bufnr, desc = "Organize Imports" })
                keymap("n", "<leader>jt", jdtls.test_class, { buffer = bufnr, desc = "Test Java Class" })
                keymap("n", "<leader>jn", jdtls.test_nearest_method, { buffer = bufnr, desc = "Test Nearest Java Method" })
            end,
        }

        jdtls.start_or_attach(config)
    end,
}
