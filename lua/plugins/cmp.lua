local function tailwind(entry, item)
  local entryItem = entry:get_completion_item()
  local color = entryItem.documentation

  if color and type(color) == "string" and color:match "^#%x%x%x%x%x%x$" then
    local hl = "hex-" .. color:sub(2)

    if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then vim.api.nvim_set_hl(0, hl, { fg = color, bg = "#2F3731" }) end

    -- item.kind = " 󱓻 "
    item.kind_hl_group = hl
  end
end

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local function mapping()
  local cmp = require "cmp"
  local luasnip = require "luasnip"

  return {
    ["<CR>"] = cmp.config.disable,
    -- ctrl + e close cmp window
    -- <C-n> and <C-p> for navigating snippets
    ["<C-N>"] = cmp.mapping(function()
      if luasnip.jumpable(1) then luasnip.jump(1) end
    end, { "i", "s" }),
    ["<C-P>"] = cmp.mapping(function()
      if luasnip.jumpable(-1) then luasnip.jump(-1) end
    end, { "i", "s" }),
    ["<C-K>"] = cmp.mapping(function() cmp.select_prev_item { behavior = cmp.SelectBehavior.Select } end, { "i", "s" }),
    ["<C-J>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
      else
        cmp.complete()
      end
    end, { "i", "s" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      -- get current mode
      local mode = vim.api.nvim_get_mode().mode
      if cmp.visible() then
        if mode == "c" then
          cmp.confirm { select = true }
        else
          if has_words_before() then cmp.confirm {} end
        end
      else
        fallback()
      end
    end, { "i", "s", "c" }),
    ["<S-Tab>"] = cmp.config.disable,
  }
end

---@type LazySpec
return {
  "hrsh7th/nvim-cmp",
  specs = {
    "AstroNvim/astroui",
  },
  dependencies = {
    {
      "vrslev/cmp-pypi",
      ft = "toml",
    },
  },
  opts = function(_, opts)
    local cmp = require "cmp"
    local compare = require "cmp.config.compare"

    return require("astrocore").extend_tbl(opts, {
      sources = cmp.config.sources {
        {
          name = "nvim_lsp",
          priority = 1000,
        },
        { name = "luasnip", priority = 750 },
        { name = "path", priority = 500 },
        { name = "buffer", priority = 250 },
        { name = "pypi", keyword_length = 4 },
      },
      sorting = {
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.recently_used,
          compare.kind,
          compare.sort_text,
          compare.length,
          compare.order,
        },
      },
      completion = {
        -- auto select first item
        completeopt = "menu,menuone,preview,noinsert",
      },
      mapping = mapping(),
      experimental = {
        ghost_text = true,
      },
      formatting = {
        expandable_indicator = true,
        format = function(entry, item)
          local str = require "cmp.utils.str"
          local widths = {
            abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 30,
            menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
          }
          for key, width in pairs(widths) do
            if item[key] and vim.fn.strdisplaywidth(str.trim(item[key])) > width then
              item[key] = vim.fn.strcharpart(str.trim(item[key]), 0, width - 1) .. "…"
            end
          end

          local icon, hl, _ = require("mini.icons").get("lsp", item.kind or "")
          item.abbr = item.abbr
          item.kind = " " .. icon .. " "
          item.kind_hl_group = "CmpMini" .. hl
          tailwind(entry, item)

          return item
        end,

        fields = { "kind", "abbr", "menu" },
      },
      window = {
        completion = {
          col_offset = 0,
          side_padding = 0,
          scrollbar = false,
          winhighlight = "Normal:CmpDocumentation,CursorLine:PmenuSel,Search:None,FloatBorder:CmpDocumentationBorder",
          border = "none",
        },
        documentation = {
          border = "none",
          winhighlight = "Normal:CmpDocumentation,FloatBorder:CmpDocumentationBorder",
        },
      },
    })
  end,
}
