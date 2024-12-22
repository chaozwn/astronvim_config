local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then ctx.symbols_filter = require("utils").get_kind_filter(ctx.bufnr) or false end
  if ctx.symbols_filter == false then return true end
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

local function match_commit_hash(line, opts)
  if type(opts.fn_match_commit_hash) == "function" then
    return opts.fn_match_commit_hash(line, opts)
  else
    return line:match "[^ ]+"
  end
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  specs = {
    { "nvim-telescope/telescope.nvim", optional = true, enabled = false },
    { "nvim-telescope/telescope-fzf-native.nvim", optional = true, enabled = false },
    { "stevearc/dressing.nvim", optional = true, opts = { select = { backend = { "fzf_lua" } } } },
    {
      "AstroNvim/astrolsp",
      optional = true,
      opts = function(_, opts)
        if require("astrocore").is_available "fzf-lua" then
          local maps = opts.mappings

          maps.n["<Leader>lD"] =
            { function() require("fzf-lua").diagnostics_document() end, desc = "Search diagnostics" }
          if maps.n.gd then
            maps.n.gd[1] = "<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>"
          end
          if maps.n.gI then
            maps.n.gI[1] = "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>"
          end
          if maps.n["<Leader>lR"] then
            maps.n["<Leader>lR"][1] =
              "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>"
          end
          if maps.n.gy then
            maps.n.gy[1] = "<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>"
          end
          if maps.n["<Leader>lG"] then
            maps.n["<Leader>lG"][1] = function() require("fzf-lua").lsp_workspace_symbols() end
          end
          maps.n.gr = {
            "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>",
            desc = "References",
          }
        end
      end,
    },
  },
  dependencies = {
    "echasnovski/mini.icons",
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>f"] = vim.tbl_get(opts, "_map_sections", "f")
        if vim.fn.executable "git" == 1 then
          maps.n["<Leader>g"] = vim.tbl_get(opts, "_map_sections", "g")
          maps.n["<Leader>gb"] = { function() require("fzf-lua").git_branches() end, desc = "Git branches" }
          maps.n["<Leader>gc"] = { function() require("fzf-lua").git_commits() end, desc = "Git commits (repository)" }
          maps.n["<Leader>gC"] =
            { function() require("fzf-lua").git_bcommits() end, desc = "Git commits (current file)" }
          maps.n["<Leader>gt"] = { function() require("fzf-lua").git_status() end, desc = "Git status" }
        end
        maps.n["<Leader>f<CR>"] = { function() require("fzf-lua").resume() end, desc = "Resume previous search" }
        maps.n["<Leader>f'"] = { function() require("fzf-lua").marks() end, desc = "Find marks" }
        maps.n["<Leader>f/"] =
          { function() require("fzf-lua").lgrep_curbuf() end, desc = "Find words in current buffer" }
        maps.n["<Leader>fa"] = {
          function() require("fzf-lua").files { prompt = "Config> ", cwd = vim.fn.stdpath "config" } end,
          desc = "Find AstroNvim config files",
        }
        maps.n["<Leader>fx"] = {
          function() require("fzf-lua").diagnostics_document() end,
          desc = "Find Document Diagnostics",
        }
        maps.n["<Leader>fX"] = {
          function() require("fzf-lua").diagnostics_workspace() end,
          desc = "Find Workspace Diagnostics",
        }
        maps.n["<Leader>fa"] = { function() require("fzf-lua").autocmds() end, desc = "Find autocmds" }
        maps.n["<Leader>fb"] = { function() require("fzf-lua").buffers() end, desc = "Find buffers" }
        maps.n["<Leader>fc"] = { function() require("fzf-lua").grep_cword() end, desc = "Find word under cursor" }
        maps.n["<Leader>fC"] = { function() require("fzf-lua").commands() end, desc = "Find commands" }
        maps.n["<Leader>fH"] = { function() require("fzf-lua").command_history() end, desc = "Find command history" }
        maps.n["<Leader>ff"] = { function() require("fzf-lua").files() end, desc = "Find files" }
        maps.n["<Leader>fh"] = { function() require("fzf-lua").helptags() end, desc = "Find help" }
        maps.n["<Leader>fk"] = { function() require("fzf-lua").keymaps() end, desc = "Find keymaps" }
        maps.n["<Leader>fm"] = { function() require("fzf-lua").manpages() end, desc = "Find man" }
        maps.n["<Leader>fo"] = { function() require("fzf-lua").oldfiles() end, desc = "Find history" }
        maps.n["<Leader>fr"] = { function() require("fzf-lua").registers() end, desc = "Find registers" }
        maps.n["<Leader>fT"] = { function() require("fzf-lua").colorschemes() end, desc = "Find themes" }
        maps.n["<Leader>fg"] = {
          function() require("fzf-lua").git_files() end,
          desc = "Find Files (git-files)",
        }
        if vim.fn.executable "rg" == 1 or vim.fn.executable "grep" == 1 then
          maps.n["<Leader>fw"] = { function() require("fzf-lua").live_grep_native() end, desc = "Find words" }
        end
        maps.n["<Leader>fs"] = {
          function()
            require("fzf-lua").lsp_document_symbols {
              regex_filter = symbols_filter,
            }
          end,
          desc = "Search symbols",
        }
        maps.n["<Leader>fS"] = {
          function()
            require("fzf-lua").lsp_live_workspace_symbols {
              regex_filter = symbols_filter,
            }
          end,
          desc = "Goto Symbol (Workspace)",
        }
        if require("astrocore").is_available "todo-comments.nvim" then
          maps.n["ft"] = {
            function() require("todo-comments.fzf").todo() end,
            desc = "Todo",
          }
        end
      end,
    },
  },
  opts = function()
    local config = require "fzf-lua.config"
    local actions = require "fzf-lua.actions"

    -- Quickfix
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "preview-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-u>"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-d>"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "half-page-up"

    -- Trouble
    if require("astrocore").is_available "trouble.nvim" then
      config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
    end

    if require("astrocore").is_available "diffview.nvim" then
      config.defaults.git.commits.actions["ctrl-r"] = function(selected, opts)
        local commit_hash = match_commit_hash(selected[1], opts)
        vim.cmd.DiffviewOpen { commit_hash }
      end
    end

    if require("astrocore").is_available "diffview.nvim" then
      config.defaults.git.bcommits.actions["ctrl-r"] = function(selected, opts)
        local commit_hash = match_commit_hash(selected[1], opts)
        vim.cmd.DiffviewOpen { commit_hash }
      end
    end

    if require("astrocore").is_available "diffview.nvim" then
      config.defaults.git.branches.actions["ctrl-r"] = function(selected, opts)
        local branch = selected[1]:match "[^%s%*]+"
        vim.cmd.DiffviewOpen { branch }
      end
    end

    local img_previewer ---@type string[]?
    for _, v in ipairs {
      { cmd = "ueberzug", args = {} },
      { cmd = "chafa", args = { "{file}", "--format=symbols" } },
      { cmd = "viu", args = { "-b" } },
    } do
      if vim.fn.executable(v.cmd) == 1 then
        img_previewer = vim.list_extend({ v.cmd }, v.args)
        break
      end
    end

    return {
      "default-title",
      fzf_colors = true,
      fzf_opts = {
        ["--no-scrollbar"] = true,
      },
      defaults = {
        -- formatter = "path.filename_first",
        formatter = "path.dirname_first",
      },
      previewers = {
        builtin = {
          extensions = {
            ["png"] = img_previewer,
            ["jpg"] = img_previewer,
            ["jpeg"] = img_previewer,
            ["gif"] = img_previewer,
            ["webp"] = img_previewer,
          },
          ueberzug_scaler = "fit_contain",
        },
      },
      winopts = {
        width = 0.8,
        height = 0.8,
        row = 0.5,
        col = 0.5,
        preview = {
          scrollchars = { "┃", "" },
        },
      },
      files = {
        cwd_prompt = false,
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["ctrl-z"] = { actions.toggle_hidden },
        },
      },
      grep = {
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["ctrl-z"] = { actions.toggle_hidden },
        },
      },
      lsp = {
        symbols = {
          symbol_hl = function(s) return "TroubleIcon" .. s end,
          symbol_fmt = function(s) return s:lower() .. "\t" end,
          child_prefix = false,
        },
        code_actions = {
          previewer = vim.fn.executable "delta" == 1 and "codeaction_native" or nil,
        },
      },
    }
  end,
  config = function(_, opts)
    if opts[1] == "default-title" then
      -- use the same prompt for all pickers for profile `default-title` and
      -- profiles that use `default-title` as base profile
      local function fix(t)
        t.prompt = t.prompt ~= nil and " " or nil
        for _, v in pairs(t) do
          if type(v) == "table" then fix(v) end
        end
        return t
      end
      opts = vim.tbl_deep_extend("force", fix(require "fzf-lua.profiles.default-title"), opts)
      opts[1] = nil
    end
    require("fzf-lua").setup(opts)
  end,
  init = function()
    require("utils").on_very_lazy(function()
      rawset(vim.ui, "select", function(...)
        require("fzf-lua").register_ui_select(function(fzf_opts, items)
          return vim.tbl_deep_extend("force", fzf_opts, {
            prompt = " ",
            winopts = {
              title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
              title_pos = "center",
            },
          }, fzf_opts.kind == "codeaction" and {
            winopts = {
              layout = "vertical",
              -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
              height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
              width = 0.5,
              preview = not vim.tbl_isempty(require("utils").get_clients { bufnr = 0, name = "vtsls" }) and {
                layout = "vertical",
                vertical = "down:15,border-top",
                hidden = "hidden",
              } or {
                layout = "vertical",
                vertical = "down:15,border-top",
              },
            },
          } or {
            winopts = {
              width = 0.5,
              -- height is number of items, with a max of 80% screen height
              height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
            },
          })
        end)
        return vim.ui.select(...)
      end)
    end)
  end,
  keys = {
    { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
    { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
  },
}
