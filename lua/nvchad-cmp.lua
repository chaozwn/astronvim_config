local cmp_ui = {
  icons_left = false, -- only for non-atom styles!
  lspkind_text = true,
  style = "default", -- default/flat_light/flat_dark/atom/atom_colored
  format_colors = {
    tailwind = true, -- will work for css lsp too
    icon = "󱓻",
  },
}

local cmp_style = cmp_ui.style
local format_kk = require "nvchad-cmp-format"

local atom_styled = cmp_style == "atom" or cmp_style == "atom_colored"
local fields = (atom_styled or cmp_ui.icons_left) and { "kind", "abbr", "menu" } or { "abbr", "kind", "menu" }

local M = {
  formatting = {
    format = function(entry, item)
      local icons = require "nvchad-cmp-icons-lspkind"
      local array = require("mini.icons").get("lsp", "array")

      item.abbr = item.abbr .. " "
      item.menu = cmp_ui.lspkind_text and item.kind or ""
      item.menu_hl_group = atom_styled and "LineNr" or "CmpItemKind" .. (item.kind or "")
      item.kind = (require("mini.icons").get("lsp", item.kind) or "") .. " "

      if not cmp_ui.icons_left then item.kind = " " .. item.kind end

      if cmp_ui.format_colors.tailwind then format_kk.tailwind(entry, item) end

      return item
    end,

    fields = fields,
  },

  window = {
    completion = {
      scrollbar = false,
      side_padding = atom_styled and 0 or 1,
      winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder",
      border = atom_styled and "none" or "single",
    },

    documentation = {
      border = "single",
      winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
    },
  },
}

return M
