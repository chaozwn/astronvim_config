local is_available = require("astrocore").is_available

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
  },
  opts = function(_, opts)
    local actions = require "telescope.actions"

    return require("astrocore").extend_tbl(opts, {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = " ",
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
    })
  end,
  config = function(...) require "astronvim.plugins.configs.telescope"(...) end,
}
