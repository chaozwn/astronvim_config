-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  version = false,
  branch = "v3",
  dependencies = { "echasnovski/mini.icons" },
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "tokyonight-storm",
    highlights = {
      init = function()
        local get_hlgroup = require("astroui").get_hlgroup
        -- get highlights from highlight groups
        local lsp_icons = require("mini.icons").list "lsp"

        local colors = {
          white = "#cdcecf",
          darker_black = "#121c29",
          black = "#192330",
          black2 = "#202a37",
          one_bg = "#252f3c", -- real bg of onedark
          one_bg2 = "#313b48",
          one_bg3 = "#3d4754",
          grey = "#495360",
          grey_fg = "#535d6a",
          grey_fg2 = "#5c6673",
          light_grey = "#646e7b",
          red = "#c94f6d",
          baby_pink = "#e26886",
          pink = "#d85e7c",
          line = "#2a3441",
          green = "#8ebaa4",
          vibrant_green = "#6ad4d6",
          blue = "#719cd6",
          nord_blue = "#86abdc",
          yellow = "#dbc074",
          sun = "#e0c989",
          purple = "#baa1e2",
          dark_purple = "#9d79d6",
          teal = "#5cc6c8",
          orange = "#fe9373",
          cyan = "#8be5e7",
          statusline_bg = "#202a37",
          lightbg = "#313b48",
          pmenu_bg = "#719cd6",
          folder_bg = "#719cd6",
        }

        local hls = {
          TelescopeNormal = { bg = colors.darker_black },

          TelescopePreviewTitle = {
            fg = colors.black,
            bg = colors.green,
          },

          TelescopePromptTitle = {
            fg = colors.black,
            bg = colors.red,
          },

          TelescopeSelection = { bg = colors.black2, fg = colors.white },
          TelescopeResultsDiffAdd = { fg = colors.green },
          TelescopeResultsDiffChange = { fg = colors.yellow },
          TelescopeResultsDiffDelete = { fg = colors.red },

          TelescopeMatching = { bg = colors.one_bg, fg = colors.blue },

          TelescopeBorder = { fg = colors.darker_black, bg = colors.darker_black },
          TelescopePromptBorder = { fg = colors.black2, bg = colors.black2 },
          TelescopePromptNormal = { fg = colors.white, bg = colors.black2 },
          TelescopeResultsTitle = { fg = colors.darker_black, bg = colors.darker_black },
          TelescopePromptPrefix = { fg = colors.red, bg = colors.black2 },
        }

        for _, icon_key in pairs(lsp_icons) do
          local _, hl, _ = require("mini.icons").get("lsp", icon_key)
          local icon_hl = get_hlgroup(hl)
          hls["CmpMini" .. hl] = { fg = icon_hl.fg, bg = "#2F3731" }
        end

        -- return a table of highlights for telescope based on
        -- colors gotten from highlight groups
        return hls
      end,
    },
  },
}
