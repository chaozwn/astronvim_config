---@type LazySpec
return {
  { "stevearc/aerial.nvim", enabled = false },
  {
    "hedyhli/outline.nvim",
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>lS"] = { function() vim.cmd [[Outline]] end, desc = "Toggle Outline" }
        end,
      },
      "echasnovski/mini.icons",
    },
    cmd = "Outline",
    opts = function()
      local defaults = require("outline.config").defaults
      local opts = {
        symbols = {
          icons = {},
          filter = {
            default = {
              "Class",
              "Constructor",
              "Enum",
              "Field",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Property",
              "Struct",
              "Trait",
            },
            markdown = false,
            help = false,
            -- you can specify a different filter for each filetype
            lua = {
              "Class",
              "Constructor",
              "Enum",
              "Field",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              -- "Package", -- remove package since luals uses it for control flow structures
              "Property",
              "Struct",
              "Trait",
            },
          },
        },
        keymaps = {
          up_and_jump = "<up>",
          down_and_jump = "<down>",
        },
      }

      for kind, _ in pairs(defaults.symbols.icons) do
        local icon, hl, _ = require("mini.icons").get("lsp", kind)
        opts.symbols.icons[kind] = {
          icon = icon,
          hl = hl,
        }
      end
      return opts
    end,
  },
}
