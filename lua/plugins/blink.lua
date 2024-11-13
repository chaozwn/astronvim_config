local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local function get_icon(ctx)
  local mini_icons = require "mini.icons"
  local source = ctx.item.source_name
  local label = ctx.item.label
  local color = ctx.item.documentation

  if source == "LSP" then
    if color and type(color) == "string" and color:match "^#%x%x%x%x%x%x$" then
      local hl = "hex-" .. color:sub(2)
      if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then vim.api.nvim_set_hl(0, hl, { fg = color }) end
      return "󱓻", hl, false
    else
      return mini_icons.get("lsp", ctx.kind)
    end
  elseif source == "Path" then
    return (label:match "%.[^/]+$" and mini_icons.get("file", label) or mini_icons.get("directory", ctx.item.label))
  elseif source == "codeium" then
    return mini_icons.get("lsp", "event")
  else
    return ctx.kind_icon, "BlinkCmpKind" .. ctx.kind, false
  end
end

return {
  "Saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",
  dependencies = { "rafamadriz/friendly-snippets", "echasnovski/mini.icons" },
  opts_extend = { "sources.completion.enabled_providers" },
  opts = {
    -- remember to enable your providers here
    sources = { completion = { enabled_providers = { "lsp", "path", "snippets", "buffer" } } },
    -- experimental auto-brackets support
    accept = {
      auto_brackets = { enabled = true },
    },
    trigger = {
      signature_help = {
        enabled = true,
      },
    },
    keymap = {
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-N>"] = {
        "snippet_forward",
        "fallback",
      },
      ["<C-P>"] = {
        "snippet_backward",
        "fallback",
      },
      ["<C-J>"] = { "select_next", "fallback" },
      ["<C-K>"] = { "select_prev", "fallback" },
      ["<C-U>"] = { "scroll_documentation_up", "fallback" },
      ["<C-D>"] = { "scroll_documentation_down", "fallback" },
      ["<C-E>"] = { "hide", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = {
        function(cmp)
          if cmp.windows.autocomplete.win:is_open() then
            return cmp.accept()
          elseif has_words_before() then
            return cmp.show()
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.windows.autocomplete.win:is_open() then return cmp.select_prev() end
        end,
        "fallback",
      },
    },
    windows = {
      autocomplete = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        draw = function(ctx)
          local icon, hl, _ = get_icon(ctx)
          return {
            " ",
            { icon, ctx.icon_gap, hl_group = hl },
            {
              ctx.label,
              ctx.kind == "Snippet" and "~" or "",
              (ctx.item.labelDetails and ctx.item.labelDetails.detail) and ctx.item.labelDetails.detail or "",
              fill = true,
              hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
              max_width = 40,
            },
            " ",
          }
        end,
      },
      documentation = {
        auto_show = true,
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      },
      signature_help = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
  },
  specs = {
    -- disable built in completion plugins
    { "hrsh7th/nvim-cmp", enabled = false },
    { "rcarriga/cmp-dap", enabled = false },
    { "L3MON4D3/LuaSnip", enabled = false },
  },
}
