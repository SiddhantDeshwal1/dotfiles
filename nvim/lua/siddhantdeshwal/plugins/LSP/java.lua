return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local ok_jdtls, jdtls = pcall(require, "jdtls")
    if not ok_jdtls then
      vim.notify("nvim-jdtls not found. Please install it.", vim.log.levels.ERROR)
      return
    end

    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

    -- 🔍 Find project root
    local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
    if root_dir == "" then
      vim.notify("Could not find Java project root", vim.log.levels.WARN)
      return
    end

    -- 💡 Capabilities for autocompletion
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local config = {
      cmd = { "jdtls", "-data", workspace_dir },
      root_dir = root_dir,
      capabilities = capabilities,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.mockito.Mockito.*",
            },
          },
        },
      },
      on_attach = function(client, bufnr)
        local keymap = vim.keymap
        local opts = { buffer = bufnr, silent = true }

        -- Ensure any jdt virtual buffers are modifiable BEFORE jdtls writes them.
        -- This prevents "Buffer is not 'modifiable'" errors coming from jdtls' BufReadCmd handler.
        -- Creating the autocmd here keeps it scoped to the client lifetime.
        vim.api.nvim_create_autocmd("BufReadCmd", {
          pattern = "jdt://*",
          callback = function(args)
            local b = args.buf
            -- Make sure buffer is modifiable so jdtls can populate it.
            -- Also clear readonly to be safe.
            pcall(vim.api.nvim_buf_set_option, b, "modifiable", true)
            pcall(vim.api.nvim_buf_set_option, b, "readonly", false)
            -- keep the handler minimal: jdtls will still handle populating content.
          end,
          -- make sure the autocommand is cleared when the buffer is unloaded
          once = false,
        })

        -- Hover
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
        -- 🚀 Smart Go-to-Definition
        -- - If definition is in same file: jump there
        -- - If definition is in different file: open a new tab and jump there
        -- - If definition is a jdt:// classfile: use jdtls.open_classfile safely
        ----------------------------------------------------------------------
        keymap.set("n", "gd", function()
          local params = vim.lsp.util.make_position_params()
          vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
            if err then
              vim.notify("LSP error: " .. tostring(err.message or err), vim.log.levels.ERROR)
              return
            end
            if not result or vim.tbl_isempty(result) then
              vim.notify("No definition found", vim.log.levels.WARN)
              return
            end

            -- normalize to first result
            local def = vim.tbl_islist(result) and result[1] or result
            if not def or not def.uri then
              vim.notify("Invalid LSP location", vim.log.levels.WARN)
              return
            end

            local uri = def.uri
            -- If it's a jdt virtual URI, delegate to jdtls open_classfile.
            if type(uri) == "string" and vim.startswith(uri, "jdt://") then
              -- call jdtls.open_classfile within pcall to avoid raising if plugin internals fail.
              local ok, err_open = pcall(function()
                jdtls.open_classfile(uri)
              end)
              if not ok then
                vim.notify("Failed to open JDT classfile: " .. tostring(err_open), vim.log.levels.WARN)
              end
              return
            end

            -- For normal files, compare target file with current buffer name.
            local target_file = vim.uri_to_fname(uri)
            local current_file = vim.api.nvim_buf_get_name(0)

            if target_file == current_file then
              -- same file -> jump in place
              local ok_jump, msg = pcall(function()
                vim.lsp.util.jump_to_location(def, "utf-8")
              end)
              if not ok_jump then
                vim.notify("Jump failed: " .. tostring(msg), vim.log.levels.WARN)
              end
            else
              -- different file -> open new tab first, then jump there
              local ok_tab, tab_err = pcall(function()
                vim.cmd("tabnew " .. vim.fn.fnameescape(target_file))
                vim.lsp.util.jump_to_location(def, "utf-8")
              end)
              if not ok_tab then
                vim.notify("Opening in new tab failed: " .. tostring(tab_err), vim.log.levels.WARN)
              end
            end
          end)
        end, opts)
      end,
    }

    -- 🚀 Start or attach
    jdtls.start_or_attach(config)
  end,
}
