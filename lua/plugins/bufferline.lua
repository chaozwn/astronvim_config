return {
  "akinsho/bufferline.nvim",
  specs = {
    {
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        opts.tabline = nil -- remove tabline
      end,
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local get_icon = require("astroui").get_icon
        local maps = opts.mappings or {}
        -- remove before heirline buffer mapping
        for k, _ in pairs(opts.mappings.n) do
          if k:find "^<Leader>b" then maps.n[k] = false end
        end
        maps.n["<Leader>b"] = { name = get_icon("Tab", 1, true) .. "Buffers" }
        maps.n["]b"] = { function() require("bufferline.commands").cycle(vim.v.count1) end, desc = "Next buffer" }
        maps.n["[b"] = { function() require("bufferline.commands").cycle(-vim.v.count1) end, desc = "Previous buffer" }
        maps.n[">b"] =
          { function() require("bufferline.commands").move(vim.v.count1) end, desc = "Move buffer tab right" }
        maps.n["<b"] =
          { function() require("bufferline.commands").move(-vim.v.count1) end, desc = "Move buffer tab left" }
        maps.n["<Leader>bb"] = {
          function() require("bufferline.commands").pick() end,
          desc = "Navigate to buffer tab with interactive picker",
        }
        maps.n["<Leader>bo"] = {
          function() require("bufferline.commands").close_others() end,
          desc = "Close all buffers except the current",
        }
        maps.n["<Leader>bd"] = {
          function() require("bufferline.commands").close_with_pick() end,
          desc = "Delete a buffer tab with interactive picker",
        }
        maps.n["<Leader>bl"] = {
          function() require("bufferline.commands").close_in_direction "left" end,
          desc = "Close all buffers to the left of the current",
        }
        maps.n["<Leader>br"] = {
          function() require("bufferline.commands").close_in_direction "right" end,
          desc = "Close all buffers to the right of the current",
        }
        maps.n["<Leader>bp"] = { "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin buffer" }
        maps.n["<Leader>bse"] =
          { function() require("bufferline.commands").sort_by "extension" end, desc = "Sort buffers by extension" }
        maps.n["<Leader>bsi"] =
          { function() require("bufferline.commands").sort_by "id" end, desc = "Sort buffers by buffer number" }
        maps.n["<Leader>bsm"] = {
          function()
            require("bufferline.commands").sort_by(function(a, b) return a.modified and not b.modified end)
          end,
          desc = "Sort buffers by last modification",
        }
        maps.n["<Leader>bsp"] =
          { function() require("bufferline.commands").sort_by "directory" end, desc = "Sort buffers by directory" }
        maps.n["<Leader>bsr"] = {
          function() require("bufferline.commands").sort_by "relative_directory" end,
          desc = "Sort buffers by relative directory",
        }
        maps.n["<Leader>b\\"] = {
          function()
            require("bufferline.pick").choose_then(function(id)
              vim.cmd "split"
              vim.cmd("buffer " .. id)
            end)
          end,
          desc = "Open a buffer tab in a new horizontal split with interactive picker",
        }
        maps.n["<Leader>b|"] = {
          function()
            require("bufferline.pick").choose_then(function(id)
              vim.cmd "vsplit"
              vim.cmd("buffer " .. id)
            end)
          end,
          desc = "Open a buffer tab in a new vertical split with interactive picker",
        }
        return vim.tbl_deep_extend("force", opts, {
          options = {
            opt = {
              showtabline = 2,
            },
          },
        })
      end,
    },
  },
  dependencies = {
    "echasnovski/mini.icons",
  },
  event = "VeryLazy",
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      diagnostics_indicator = function(_, _, diag)
        local get_icon = require("astroui").get_icon
        local Error = get_icon("DiagnosticError", 1, true)
        local Warn = get_icon("DiagnosticWarn", 1, true)
        local ret = (diag.error and Error .. diag.error .. " " or "") .. (diag.warning and Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      ---@param opts bufferline.IconFetcherOpts
      get_element_icon = function(opts)
        local mini_icons = require "mini.icons"
        local icon, hl, _ = mini_icons.get("filetype", opts.filetype)
        return icon, hl
      end,
    },
  },
}
