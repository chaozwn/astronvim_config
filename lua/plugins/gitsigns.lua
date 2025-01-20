return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    on_attach = function(buffer)
      local get_icon = require("astroui").get_icon
      local astrocore = require "astrocore"
      local prefix, maps = "<Leader>g", astrocore.empty_map_table()
      for _, mode in ipairs { "n", "v" } do
        maps[mode][prefix] = { desc = get_icon("Git", 1, true) .. "Git" }
      end

      local gs = package.loaded.gitsigns
      maps.n["]h"] = {
        function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gs.nav_hunk "next"
          end
        end,
        desc = "Next Hunk",
      }

      maps.n["[h"] = {
        function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end,
        desc = "Prev Hunk",
      }
      maps.n["]H"] = { function() gs.nav_hunk "last" end, desc = "Last Hunk" }
      maps.n["[H"] = { function() gs.nav_hunk "first" end, desc = "First Hunk" }
      maps.n[prefix .. "hs"] = {
        ":Gitsigns stage_hunk<CR>",
        desc = "Stage Hunk",
      }
      maps.v[prefix .. "hs"] = {
        ":Gitsigns stage_hunk<CR>",
        desc = "Stage Hunk",
      }
      maps.n[prefix .. "hr"] = { ":Gitsigns reset_hunk<CR>", desc = "Reset Hunk" }
      maps.v[prefix .. "hr"] = { ":Gitsigns reset_hunk<CR>", desc = "Reset Hunk" }
      maps.n[prefix .. "hS"] = { gs.stage_buffer, desc = "Stage Buffer" }
      maps.n[prefix .. "hu"] = { gs.undo_stage_hunk, desc = "Undo Stage Hunk" }
      maps.n[prefix .. "hR"] = { gs.reset_buffer, desc = "Reset Buffer" }
      maps.n[prefix .. "hp"] = { gs.preview_hunk_inline, desc = "Preview Hunk Inline" }
      maps.n[prefix .. "hb"] = { function() gs.blame_line { full = true } end, desc = "Blame Line" }
      maps.n[prefix .. "hB"] = { function() gs.blame() end, desc = "Blame Buffer" }
      maps.n[prefix .. "hd"] = { gs.diffthis, desc = "Diff This" }
      maps.n[prefix .. "hD"] = { function() gs.diffthis "~" end, desc = "Diff This ~" }
      maps.o["ih"] = { ":<C-U>Gitsigns select_hunk<CR>", desc = "GitSigns Select Hunk" }
      maps.x["ih"] = { ":<C-U>Gitsigns select_hunk<CR>", desc = "GitSigns Select Hunk" }

      astrocore.set_mappings(maps, { buffer = buffer })
    end,
  },
}
