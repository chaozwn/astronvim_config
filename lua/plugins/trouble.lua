---@type LazySpec
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  specs = {
    { "stevearc/aerial.nvim", optional = true, enabled = false },
    { "AstroNvim/astroui", opts = { icons = { Trouble = "󱍼" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        local prefix = "<Leader>x"
        maps.n[prefix] = { desc = require("astroui").get_icon("Trouble", 1, true) .. "Trouble" }
        maps.n[prefix .. "x"] = {
          "<cmd>Trouble diagnostics toggle<cr>",
          desc = "Diagnostics (Trouble)",
        }
        maps.n[prefix .. "X"] =
          { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" }
        maps.n["<Leader>ls"] = {
          "<cmd>Trouble symbols toggle focus=false<cr>",
          desc = "Symbols (Trouble)",
        }
        maps.n["<Leader>lS"] = {
          "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
          desc = "LSP references/definitions/... (Trouble)",
        }
        maps.n[prefix .. "L"] = { "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" }
        maps.n[prefix .. "Q"] = { "<cmd>Trouble quickfix toggle<cr>", desc = "Quickfix List (Trouble)" }
        maps.n["[q"] = {
          function()
            if require("trouble").is_open() then
              require("trouble").prev { skip_groups = true, jump = true }
            else
              local ok, err = pcall(vim.cmd.cprev)
              if not ok then vim.notify(err, vim.log.levels.ERROR) end
            end
          end,
          desc = "Previous Trouble/Quickfix Item",
        }

        maps.n["]q"] = {
          function()
            if require("trouble").is_open() then
              require("trouble").next { skip_groups = true, jump = true }
            else
              local ok, err = pcall(vim.cmd.cnext)
              if not ok then vim.notify(err, vim.log.levels.ERROR) end
            end
          end,
          desc = "Next Trouble/Quickfix Item",
        }
      end,
    },
    { "lewis6991/gitsigns.nvim", opts = { trouble = true } },
  },
  opts = function(_, opts)
    if not opts.icons then opts.icons = {} end
    if not opts.icons.kinds then
      opts.icons.kinds = {
        Array = " ",
        Boolean = "󰨙 ",
        Class = " ",
        Constant = "󰏿 ",
        Constructor = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Function = "󰊕 ",
        Interface = " ",
        Key = " ",
        Method = "󰊕 ",
        Module = " ",
        Namespace = "󰦮 ",
        Null = " ",
        Number = "󰎠 ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        String = " ",
        Struct = "󰆼 ",
        TypeParameter = " ",
        Variable = "󰀫 ",
      }
    end
    for kind, _ in pairs(opts.icons.kinds) do
      local icon, _, _ = require("mini.icons").get("lsp", kind)
      opts.icons.kinds[kind] = icon
    end
    return vim.tbl_deep_extend("force", opts, {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
      keys = {
        ["<ESC>"] = "close",
        ["q"] = "close",
        ["<C-E>"] = "close",
      },
      auto_preview = true, -- automatically open preview when on an item
      auto_refresh = true, -- auto refresh when open
    })
  end,
}
