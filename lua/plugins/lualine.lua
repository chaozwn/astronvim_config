return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    specs = {
      {
        "rebelot/heirline.nvim",
        enabled = false,
        optional = true,
        opts = function(_, opts) opts.statusline = nil end,
      },
    },
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      local lualine_require = require "lualine_require"
      lualine_require.require = require

      local get_icon = require("astroui").get_icon

      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          lualine_c = {
            require("utils.lualine").root_dir(),
            {
              "diagnostics",
              symbols = {
                error = get_icon("DiagnosticError", 1),
                warn = get_icon("DiagnosticWarn", 1),
                info = get_icon("DiagnosticInfo", 1),
                hint = get_icon("DiagnosticHint", 1),
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { require("utils.lualine").pretty_path() },
          },
          lualine_x = {
            require("snacks").profiler.status(),
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = require("snacks").util.color("Statement") } end,
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = function() return { fg = require("snacks").util.color("Constant") } end,
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = require("snacks").util.color("Debug") } end,
            },
            -- stylua: ignore
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function() return { fg = require("snacks").util.color("Special") } end,
            },
            {
              "diff",
              symbols = {
                added = get_icon("GitAdd", 1),
                modified = get_icon("GitChange", 1),
                removed = get_icon("GitDelete", 1),
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function() return " " .. os.date "%R" end,
          },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }

      -- do not add trouble symbols if aerial is enabled
      -- And allow it to be overriden for some buffer types (see autocmds)
      if vim.g.trouble_lualine and require("astrocore").is_available "trouble.nvim" then
        local trouble = require "trouble"
        local symbols = trouble.statusline {
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        }
        table.insert(opts.sections.lualine_c, {
          symbols and symbols.get,
          cond = function() return vim.b.trouble_lualine ~= false and symbols.has() end,
        })
      end

      if require("astrocore").is_available "overseer.nvim" then
        table.insert(opts.sections.lualine_x, { "overseer" })
      end

      return opts
    end,
  },
}
