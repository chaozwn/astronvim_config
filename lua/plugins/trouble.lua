---@type LazySpec
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  specs = {
    { "AstroNvim/astroui", opts = { icons = { Trouble = "󱍼" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        local prefix = "<Leader>x"
        maps.n[prefix] = { desc = require("astroui").get_icon("Trouble", 1, true) .. "Trouble" }
        maps.n[prefix .. "X"] = {
          "<Cmd>Trouble diagnostics toggle<CR>",
          desc = "Workspace Diagnostics (Trouble)",
        }
        maps.n[prefix .. "x"] =
          { "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Document Diagnostics (Trouble)" }
        maps.n[prefix .. "l"] = { "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" }
        maps.n[prefix .. "q"] = { "<Cmd>Trouble quickfix toggle<CR>", desc = "Quickfix List (Trouble)" }
        if require("astrocore").is_available "todo-comments.nvim" then
          maps.n[prefix .. "t"] = {
            "<cmd>Trouble todo<cr>",
            desc = "Todo (Trouble)",
          }
          maps.n[prefix .. "T"] = {
            "<cmd>Trouble todo filter={tag={TODO,FIX,FIXME}}<cr>",
            desc = "Todo/Fix/Fixme (Trouble)",
          }
        end
      end,
    },
    { "lewis6991/gitsigns.nvim", opts = { trouble = true } },
  },
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon
    local lspkind_avail, lspkind = pcall(require, "lspkind")
    return vim.tbl_deep_extend("force", opts, {
      keys = {
        ["<ESC>"] = "close",
        ["q"] = "close",
        ["<C-E>"] = "close",
      },
      icons = {
        indent = {
          fold_open = get_icon "FoldOpened",
          fold_closed = get_icon "FoldClosed",
        },
        folder_closed = get_icon "FolderClosed",
        folder_open = get_icon "FolderOpen",
        kinds = lspkind_avail and lspkind.symbol_map,
      },
      auto_preview = true, -- automatically open preview when on an item
      auto_refresh = true, -- auto refresh when open
    })
  end,
}
