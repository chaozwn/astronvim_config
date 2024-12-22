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
    return (label:match "%.[^/]+$" and mini_icons.get("file", label) or mini_icons.get("directory", label))
  elseif source == "codeium" then
    return mini_icons.get("lsp", "event")
  else
    return ctx.kind_icon, "BlinkCmpKind" .. ctx.kind, false
  end
end

return {
  {
    "Saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "echasnovski/mini.icons",
    },
    opts = {
      -- remember to enable your providers here
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[])
            transform_items = function(ctx, items)
              for _, item in ipairs(items) do
                if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                  item.score_offset = item.score_offset - 3
                end
              end

              ---@diagnostic disable-next-line: redundant-return-value
              return vim.tbl_filter(function(item)
                local c = ctx.get_cursor()
                local cursor_line = ctx.line
                local cursor = {
                  row = c[1],
                  col = c[2] + 1,
                  line = c[1] - 1,
                }
                local cursor_before_line = string.sub(cursor_line, 1, cursor.col - 1)
                -- remove text
                if item.kind == vim.lsp.protocol.CompletionItemKind.Text then return false end

                if vim.bo.filetype == "vue" then
                  -- For events
                  if cursor_before_line:match "(@[%w]*)%s*$" ~= nil then
                    return item.label:match "^@" ~= nil
                  -- For props also exclude events with `:on-` prefix
                  elseif cursor_before_line:match "(:[%w]*)%s*$" ~= nil then
                    return item.label:match "^:" ~= nil and not item.label:match "^:on%-" ~= nil
                  -- For slot
                  elseif cursor_before_line:match "(#[%w]*)%s*$" ~= nil then
                    return item.kind == vim.lsp.protocol.CompletionItemKind.Method
                  end
                end

                return true
              end, items)
            end,
          },
        },
      },
      keymap = {
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-N>"] = {
          "snippet_forward",
        },
        ["<C-P>"] = {
          "snippet_backward",
        },
        ["<C-J>"] = { "select_next", "fallback" },
        ["<C-K>"] = { "select_prev", "fallback" },
        ["<C-U>"] = { "scroll_documentation_up", "fallback" },
        ["<C-D>"] = { "scroll_documentation_down", "fallback" },
        ["<C-E>"] = { "hide", "fallback" },
        ["<CR>"] = { "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.accept()
            elseif has_words_before() then
              return cmp.show()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if cmp.is_visible() then return cmp.select_prev() end
          end,
          "fallback",
        },
      },
      appearance = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        -- useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release, assuming themes add support
        use_nvim_cmp_as_default = false,
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },
      signature = {
        enabled = true,
        trigger = {
          blocked_trigger_characters = {},
          blocked_retrigger_characters = {},
          -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
          show_on_insert_on_trigger_character = true,
        },
        window = {
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
      },
      completion = {
        menu = {
          scrollbar = false,
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          draw = {
            treesitter = { "lsp" },
            components = {
              kind_icon = {
                ellipsis = true,
                text = function(ctx)
                  local icon, _, _ = get_icon(ctx)
                  return icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  local _, hl, _ = get_icon(ctx)
                  return hl
                end,
              },
            },
          },
        },
        -- Disable auto brackets
        -- NOTE: some LSPs may add auto brackets themselves anyway
        accept = {
          auto_brackets = { enabled = true },
        },
        -- Insert completion item on selection, don't select by default
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            scrollbar = false,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
        },
        ghost_text = {
          enabled = true,
        },
      },
    },
    specs = {
      {
        "folke/lazydev.nvim",
        optional = true,
        specs = {
          {
            "Saghen/blink.cmp",
            opts = function(_, opts)
              if pcall(require, "lazydev.integrations.blink") then
                return require("astrocore").extend_tbl(opts, {
                  sources = {
                    -- add lazydev to your completion providers
                    default = { "lazydev" },
                    providers = {
                      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                    },
                  },
                })
              end
            end,
          },
        },
      },
      -- disable built in completion plugins
      { "hrsh7th/nvim-cmp", enabled = false },
      { "rcarriga/cmp-dap", enabled = false },
      { "petertriho/cmp-git", enabled = false },
      { "L3MON4D3/LuaSnip", enabled = false },
      { "onsails/lspkind.nvim", enabled = false },
    },
  },
}
