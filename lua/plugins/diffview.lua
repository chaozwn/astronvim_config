local prefix_diff_view = "<Leader>g"
local set_mappings = require("astrocore").set_mappings

---@type LazySpec
return {
  "sindrets/diffview.nvim",
  event = "User AstroGitFile",
  cmd = { "DiffviewOpen" },
  specs = {
    {
      ---@type AstroCoreOpts
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        if vim.fn.executable "git" == 1 then
          maps.n[prefix_diff_view .. "g"] = {
            function() vim.cmd [[DiffviewOpen]] end,
            desc = "Open Git Diffview",
          }
          maps.n[prefix_diff_view .. "H"] = {
            function() vim.cmd [[DiffviewFileHistory]] end,
            desc = "Open current branch git history",
          }
          maps.n[prefix_diff_view .. "h"] = {
            function() vim.cmd [[DiffviewFileHistory %]] end,
            desc = "Open current file git history",
          }
        end
      end,
    },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { winbar_info = false, disable_diagnostics = true },
      file_history = { winbar_info = false, disable_diagnostics = true },
    },
    file_panel = {
      win_config = { -- See |diffview-config-win_config|
        position = "bottom",
        height = require("utils").size(vim.o.lines, 0.25),
      },
    },
    hooks = {
      view_enter = function()
        set_mappings {
          n = {
            [prefix_diff_view .. "g"] = {
              function() vim.cmd [[DiffviewClose]] end,
              desc = "Close Git Diffview",
            },
          },
        }
      end,
      view_leave = function()
        set_mappings {
          n = {
            [prefix_diff_view .. "g"] = {
              function() vim.cmd [[DiffviewOpen]] end,
              desc = "Open Git Diffview",
            },
          },
        }
      end,
    },
  },
}
