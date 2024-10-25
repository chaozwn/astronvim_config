local prefix_diff_view = "<Leader>g"

---@type LazySpec
return {
  {
    ---@type AstroCoreOpts
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      if vim.fn.executable "git" == 1 then
        maps.n[prefix_diff_view .. "s"] =
          { function() require("telescope.builtin").git_stash { use_file_path = true } end, desc = "Git stash" }
        maps.n[prefix_diff_view .. "g"] = {
          function() vim.cmd [[DiffviewOpen]] end,
          desc = "Open Git Diffview",
        }
        maps.n[prefix_diff_view .. "d"] = {
          function() vim.cmd [[DiffviewClose]] end,
          desc = "Close Git Diffview",
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
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "sindrets/diffview.nvim",
        event = "User AstroGitFile",
        cmd = { "DiffviewOpen" },
        opts = function(_, opts)
          local actions = require "diffview.actions"
          local prefix = "<Leader>D"
          local build_keymaps = function(maps)
            local out = {}
            local i = 1
            for lhs, def in
              pairs(require("astrocore").extend_tbl(maps, {
                [prefix .. "q"] = { "<Cmd>DiffviewClose<CR>", desc = "Quit Diffview" }, -- Toggle the file panel.
                ["]D"] = { actions.select_next_entry, desc = "Next Difference" }, -- Open the diff for the next file
                ["[D"] = { actions.select_prev_entry, desc = "Previous Difference" }, -- Open the diff for the previous file
                ["[C"] = { actions.prev_conflict, desc = "Next Conflict" }, -- In the merge_tool: jump to the previous conflict
                ["]C"] = { actions.next_conflict, desc = "Previous Conflict" }, -- In the merge_tool: jump to the next conflict
                ["Cl"] = { actions.cycle_layout, desc = "Cycle Diff Layout" }, -- Cycle through available layouts.
                ["Ct"] = { actions.listing_style, desc = "Cycle Tree Style" }, -- Cycle through available layouts.
                ["<Leader>e"] = { actions.toggle_files, desc = "Toggle Explorer" }, -- Toggle the file panel.
                ["<Leader>o"] = { actions.focus_files, desc = "Focus Explorer" }, -- Bring focus to the file panel
              }))
            do
              local opts
              local rhs = def
              local mode = { "n" }
              if type(def) == "table" then
                if def.mode then mode = def.mode end
                rhs = def[1]
                def[1] = nil
                def.mode = nil
                opts = def
              end
              out[i] = { mode, lhs, rhs, opts }
              i = i + 1
            end
            return out
          end

          require("astrocore").extend_tbl(opts, {
            enhanced_diff_hl = true,
            view = {
              default = { winbar_info = true },
              file_history = { winbar_info = true },
              merge_tool = { layout = "diff3_mixed" },
            },
            hooks = { diff_buf_read = function(bufnr) vim.b[bufnr].view_activated = false end },
            keymaps = {
              disable_defaults = true,
              view = build_keymaps {
                [prefix .. "o"] = { actions.conflict_choose "ours", desc = "Take Ours" }, -- Choose the OURS version of a conflict
                [prefix .. "t"] = { actions.conflict_choose "theirs", desc = "Take Theirs" }, -- Choose the THEIRS version of a conflict
                [prefix .. "b"] = { actions.conflict_choose "base", desc = "Take Base" }, -- Choose the BASE version of a conflict
                [prefix .. "a"] = { actions.conflict_choose "all", desc = "Take All" }, -- Choose all the versions of a conflict
                [prefix .. "0"] = { actions.conflict_choose "none", desc = "Take None" }, -- Delete the conflict region
              },
              diff3 = build_keymaps {
                [prefix .. "O"] = { actions.diffget "ours", mode = { "n", "x" }, desc = "Get Our Diff" }, -- Obtain the diff hunk from the OURS version of the file
                [prefix .. "T"] = { actions.diffget "theirs", mode = { "n", "x" }, desc = "Get Their Diff" }, -- Obtain the diff hunk from the THEIRS version of the file
              },
              diff4 = build_keymaps {
                [prefix .. "B"] = { actions.diffget "base", mode = { "n", "x" }, desc = "Get Base Diff" }, -- Obtain the diff hunk from the OURS version of the file
                [prefix .. "O"] = { actions.diffget "ours", mode = { "n", "x" }, desc = "Get Our Diff" }, -- Obtain the diff hunk from the OURS version of the file
                [prefix .. "T"] = { actions.diffget "theirs", mode = { "n", "x" }, desc = "Get Their Diff" }, -- Obtain the diff hunk from the THEIRS version of the file
              },
              file_panel = build_keymaps {
                j = actions.next_entry, -- Bring the cursor to the next file entry
                k = actions.prev_entry, -- Bring the cursor to the previous file entry.
                o = actions.select_entry,
                S = actions.stage_all, -- Stage all entries.
                U = actions.unstage_all, -- Unstage all entries.
                X = actions.restore_entry, -- Restore entry to the state on the left side.
                L = actions.open_commit_log, -- Open the commit log panel.
                Cf = { actions.toggle_flatten_dirs, desc = "Flatten" }, -- Flatten empty subdirectories in tree listing style.
                R = actions.refresh_files, -- Update stats and entries in the file list.
                ["-"] = actions.toggle_stage_entry, -- Stage / unstage the selected entry.
                ["<Down>"] = actions.next_entry,
                ["<Up>"] = actions.prev_entry,
                ["<CR>"] = actions.select_entry, -- Open the diff for the selected entry.
                ["<2-LeftMouse>"] = actions.select_entry,
                ["<C-b>"] = actions.scroll_view(-0.25), -- Scroll the view up
                ["<C-f>"] = actions.scroll_view(0.25), -- Scroll the view down
                ["<Tab>"] = actions.select_next_entry,
                ["<S-tab>"] = actions.select_prev_entry,
              },
              file_history_panel = build_keymaps {
                j = actions.next_entry,
                k = actions.prev_entry,
                o = actions.select_entry,
                y = actions.copy_hash, -- Copy the commit hash of the entry under the cursor
                L = actions.open_commit_log,
                zR = { actions.open_all_folds, desc = "Open all folds" },
                zM = { actions.close_all_folds, desc = "Close all folds" },
                ["?"] = { actions.options, desc = "Options" }, -- Open the option panel
                ["<Down>"] = actions.next_entry,
                ["<Up>"] = actions.prev_entry,
                ["<CR>"] = actions.select_entry,
                ["<2-LeftMouse>"] = actions.select_entry,
                ["<M-C-D>"] = actions.open_in_diffview, -- Open the entry under the cursor in a diffview
                ["<C-B>"] = actions.scroll_view(-0.25),
                ["<C-F>"] = actions.scroll_view(0.25),
                ["<Tab>"] = actions.select_next_entry,
                ["<S-Tab>"] = actions.select_prev_entry,
              },
              option_panel = {
                q = actions.close,
                o = actions.select_entry,
                ["<CR>"] = actions.select_entry,
                ["<2-LeftMouse"] = actions.select_entry,
              },
            },
          })
        end,
      },
    },
    opts = function(_, opts)
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"
      local utils = require "telescope.utils"

      local compare_local_file_with_specify_branch_with_diffview = function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection == nil then
          utils.__warn_no_selection "extensions.diffviewer.diffview"
          return
        end

        actions.close(prompt_bufnr)

        vim.cmd.DiffviewOpen { selection.value }
      end

      return require("astrocore").extend_tbl(opts, {
        pickers = {
          git_commits = {
            mappings = {
              n = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
              i = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
            },
          },
          git_bcommits = {
            mappings = {
              n = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
              i = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
            },
          },
          git_branches = {
            mappings = {
              n = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
              i = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
            },
          },
          git_stash = {
            mappings = {
              n = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
              i = { ["<C-r>d"] = compare_local_file_with_specify_branch_with_diffview },
            },
          },
        },
      })
    end,
  },
}
