---@type LazySpec
local prefix = "<Leader>w"

return {
  {
    "anuvyklack/windows.nvim",
    lazy = false,
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim",
      {
        "AstroNvim/astrocore",
        opts = {
          options = {
            opt = {
              winwidth = 10,
              winminwidth = 10,
              equalalways = false,
            },
          },
          mappings = {
            n = {
              [prefix .. "c"] = { "<C-w>c", desc = "Close current screen" },
              [prefix .. "o"] = { "<C-w>o", desc = "Close other screen" },
              [prefix] = { desc = "󱂬 Window" },
              [prefix .. "m"] = {
                function() vim.cmd [[WindowsMaximize]] end,
                desc = "Maximize Window",
              },
              [prefix .. "|"] = {
                function() vim.cmd [[WindowsMaximizeHorizontally]] end,
                desc = "Maximize Window Horizontally",
              },
              [prefix .. "\\"] = {
                function() vim.cmd [[WindowsMaximizeVertically]] end,
                desc = "Maximize Window Vertically",
              },
              [prefix .. "e"] = {
                function() vim.cmd [[WindowsEqualize]] end,
                desc = "Equalize Window",
              },
            },
          },
        },
      },
    },
    opts = {
      ignore = {
        -- :echo "Buffer Name: " . expand('%') . ", Buffer Type: " . &buftype
        buftype = { "quickfix", "nofile", "terminal" },
        filetype = { "NvimTree", "neo-tree", "undotree", "gundo" },
      },
    },
    cmd = {
      "WindowsMaximize",
      "WindowsMaximizeVertically",
      "WindowsMaximizeHorizontally",
      "WindowsEqualize",
      "WindowsEnableAutowidth",
      "WindowsDisableAutowidth",
      "WindowsToggleAutowidth",
    },
  },
}
