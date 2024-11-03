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

        local hls = {}

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
