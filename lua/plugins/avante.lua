local prefix = "<Leader>P"

---@type LazySpec
return {
  "yetone/avante.nvim",
  build = "make",
  event = "User AstroFile",
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteEdit",
    "AvanteRefresh",
    "AvanteSwitchProvider",
    "AvanteChat",
    "AvanteToggle",
    "AvanteClear",
  },
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },
  },
  opts = {
    provider = "copilot",
    auto_suggestions_provider = "claude",
    behaviour = {
      auto_suggestions = false, -- Experimental stage
    },
    file_selector = {
      provider = "fzf",
      provider_opts = {},
    },
    mappings = {
      ask = prefix .. "<CR>",
      edit = prefix .. "e",
      refresh = prefix .. "r",
      focus = prefix .. "f",
      toggle = {
        default = prefix .. "t",
        debug = prefix .. "d",
        hint = prefix .. "h",
        suggestion = prefix .. "s",
        repomap = prefix .. "R",
      },
      diff = {
        next = "]c",
        prev = "[c",
      },
      files = {
        add_current = prefix .. ".",
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        opts.mappings.n[prefix] = { desc = " Avante" }
        opts.options.opt.laststatus = 3
      end,
    },
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = "InsertEnter",
      opts = {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 150,
          keymap = {
            accept = "<C-;>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.file_types then opts.file_types = { "markdown" } end
        opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
      end,
    },
    {
      "saghen/blink.cmp",
      optional = true,
      opts = function(_, opts)
        if not opts.sources then opts.sources = {} end
        return require("astrocore").extend_tbl(opts, {
          sources = {
            compat = require("astrocore").list_insert_unique(
              opts.sources.compat or {},
              { "avante_commands", "avante_mentions", "avante_files" }
            ),
            providers = {
              avante_commands = {
                kind = "AvanteCommands",
                score_offset = 90,
                async = true,
              },
              avante_files = {
                kind = "AvanteFiles",
                score_offset = 100,
                async = true,
              },
              avante_mentions = {
                name = "AvanteMentions",
                score_offset = 1000,
                async = true,
              },
            },
          },
        })
      end,
    },
  },
}
