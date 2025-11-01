return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      mode = "tabs", -- show tabs instead of buffers
      separator_style = "slant", -- nice diagonal separators
      show_buffer_close_icons = true,
      show_close_icon = false,
      always_show_bufferline = true,
      color_icons = true, -- use devicons colors
      show_tab_indicators = true,
      diagnostics = "nvim_lsp", -- show LSP diagnostics
      diagnostics_indicator = function(count, level, _, _)
        local icon = level:match("error") and " " or (level:match("warn") and " " or " ")
        return " " .. icon .. count
      end,
      hover = {
        enabled = true, -- enable hover events
        delay = 100,
        reveal = { "close" }, -- reveal close button on hover
      },
      offsets = {
        {
          filetype = "NvimTree", -- if using NvimTree
          text = "File Explorer",
          text_align = "center",
          separator = true,
        },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
  end,
}
