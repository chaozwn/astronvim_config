local utils = require "astrocore"

-- test filter
-- string.find(
--   'vim.lsp.get_active_clients() is deprecated. Run ":checkhealth vim.deprecated" for more information',
--   ".*vim.lsp.get_active_clients() is deprecated.*"
-- )

---@type LazySpec
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "karb94/neoscroll.nvim",
    },
    specs = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@param opts AstroLSPOpts
        opts = function(_, opts)
          local noice_opts = require("astrocore").plugin_opts "noice.nvim"
          -- disable the necessary handlers in AstroLSP
          if not opts.lsp_handlers then opts.lsp_handlers = {} end
          if vim.tbl_get(noice_opts, "lsp", "hover", "enabled") ~= false then
            opts.lsp_handlers["textDocument/hover"] = false
          end
          if vim.tbl_get(noice_opts, "lsp", "signature", "enabled") ~= false then
            opts.lsp_handlers["textDocument/signatureHelp"] = false
          end
        end,
      },
      {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
          if opts.ensure_installed ~= "all" then
            opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "regex", "vim" })
          end
        end,
      },
      {
        "rebelot/heirline.nvim",
        optional = true,
        opts = function(_, opts)
          local noice_opts = require("astrocore").plugin_opts "noice.nvim"
          if vim.tbl_get(noice_opts, "lsp", "progress", "enabled") ~= false then -- check if lsp progress is enabled
            opts.statusline[9] = require("astroui.status").component.lsp { lsp_progress = false }
          end
        end,
      },
    },
    opts = function(_, opts)
      return utils.extend_tbl(opts, {
        lsp = {
          hover = {
            enabled = false,
            silent = true,
          },
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          signature = {
            enabled = false,
            auto_open = {
              enabled = true,
              trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
              luasnip = false, -- Will open signature help when jumping to Luasnip insert nodes
              throttle = 50, -- Debounce lsp signature help request by 50ms
            },
            view = nil, -- when nil, use defaults from documentation
            opts = {}, -- merged with defaults from documentation
          },
          message = {
            enabled = true,
            view = "mini",
            opts = {},
          },
        },
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        routes = {
          { filter = { event = "msg_show", find = "DB: Query%s" }, opts = { skip = true } },
          { filter = { event = "msg_show", find = "%swritten" }, opts = { skip = true } },
          { filter = { event = "msg_show", find = "%schange;%s" }, opts = { skip = true } },
          { filter = { event = "msg_show", find = "%s已写入" }, opts = { skip = true } },
          { filter = { event = "msg_show", find = ".*行发生改变.*" }, opts = { skip = true } },
          { filter = { event = "msg_show", find = ".*fewer lines" }, opts = { skip = true } },
          { filter = { event = "msg_show", find = ".*vim.tbl_islist is deprecated.*" }, opts = { skip = true } },
          {
            filter = { event = "msg_show", find = '.*Run ":checkhealth vim.deprecated".*' },
            opts = { skip = true },
          },
          {
            filter = { event = "msg_show", find = "%-32603: Invalid offset" },
            opts = { skip = true },
          },
        },
      })
    end,
  },
}
