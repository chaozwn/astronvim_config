local is_available = require("astrocore").is_available

local function copy_selector()
  local action_state = require "telescope.actions.state"
  local selection = action_state.get_selected_entry()
  local filepath = selection.path
  local filename = selection.ordinal

  local modify = vim.fn.fnamemodify

  local vals = {
    ["BASENAME"] = modify(filename, ":r"),
    ["EXTENSION"] = modify(filename, ":e"),
    ["FILENAME"] = filename,
    ["PATH (CWD)"] = modify(filepath, ":."),
    ["PATH (HOME)"] = modify(filepath, ":~"),
    ["PATH"] = filepath,
    ["URI"] = vim.uri_from_fname(filepath),
  }
  local options = vim.tbl_filter(function(val) return vals[val] ~= "" end, vim.tbl_keys(vals))
  if vim.tbl_isempty(options) then
    vim.notify("No values to copy", vim.log.levels.WARN)
    return
  end
  table.sort(options)
  vim.ui.select(options, {
    prompt = "Choose to copy to clipboard:",
    format_item = function(item) return ("%s: %s"):format(item, vals[item]) end,
  }, function(choice)
    local result = vals[choice]
    if result then
      vim.notify(("Copied: `%s`"):format(result))
      vim.fn.setreg("+", result)
    end
  end)
end

---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings
        if maps then
          -- telescope plugin mappings
          if is_available "telescope.nvim" then
            maps.v["<Leader>f"] = { desc = "󰍉 Find" }
            maps.n["<Leader>fT"] = { "<cmd>TodoTelescope<cr>", desc = "Find TODOs" }

            maps.n["<Leader>fO"] = maps.n["<Leader>fo"]

            maps.n["<Leader>fo"] = {
              "<Cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
              desc = "Open File browser in cwd path",
            }
            maps.n["<Leader>fe"] = { "<Cmd>Telescope file_browser<CR>", desc = "Open File browser in current path" }
          end
        end
        opts.mappings = maps
      end,
    },
  },
  dependencies = {
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    "AstroNvim/astroui",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  opts = function(_, opts)
    local actions = require "telescope.actions"
    local fb_actions = require "telescope._extensions.file_browser.actions"
    local os_sep = require("plenary.path").path.sep
    local action_state = require "telescope.actions.state"

    return require("astrocore").extend_tbl(opts, {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = " ",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
      },
      pickers = {
        find_files = {
          -- dot file
          hidden = true,
        },
        buffers = {
          path_display = { "smart" },
          mappings = {
            i = { ["<C-d>"] = actions.delete_buffer + actions.move_to_top },
            n = { ["d"] = actions.delete_buffer + actions.move_to_top },
          },
        },
      },
      extensions = {
        file_browser = {
          on_input_filter_cb = function(prompt)
            if prompt:sub(-1, -1) == os_sep then
              local prompt_bufnr = vim.api.nvim_get_current_buf()
              if vim.bo[prompt_bufnr].filetype == "TelescopePrompt" then
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                if current_picker.finder.files then
                  fb_actions.toggle_browser(prompt_bufnr, { reset_prompt = true })
                  current_picker:set_prompt(prompt:sub(1, -2))
                end
              end
            end
          end,
          hijack_netrw = true,
          initial_mode = "insert",
          auto_depth = true,
          collapse_dirs = true,
          quiet = true,
          grouped = true,
          no_ignore = true,
          hidden = {
            file_browser = false,
            folder_browser = false,
          },
          use_fd = true,
          git_status = true,
          prompt_path = false,
          display_stat = { date = nil, size = nil, mode = nil },
          mappings = {
            i = {
              ["<C-.>"] = fb_actions.toggle_hidden,
              ["<C-h>"] = fb_actions.backspace,
              ["<C-l>"] = actions.select_default,
              -- ["<C-g>"] = search_live_grep_in_selected_files,
              -- ["<C-f>"] = search_files_in_selected_files,
              ["<C-y>"] = copy_selector,
            },
            n = {
              -- ["g"] = search_live_grep_in_selected_files,
              ["."] = fb_actions.toggle_hidden,
              ["h"] = fb_actions.backspace,
              ["l"] = actions.select_default,
              -- ["f"] = search_files_in_selected_files,
              ["Y"] = copy_selector,
            },
          },
        },
      },
    })
  end,
  config = function(...)
    local telescope = require "telescope"
    require "astronvim.plugins.configs.telescope"(...)
    telescope.load_extension "file_browser"
  end,
}
