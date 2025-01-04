-- save as repro.lua
-- run with nvim -u repro.lua
-- DO NOT change the paths
local root = vim.fn.fnamemodify("./.repro", ":p")

-- set stdpaths to use .repro
for _, name in ipairs { "config", "data", "state", "runtime", "cache" } do
  vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- install plugins
local plugins = {
  { "AstroNvim/AstroNvim", import = "astronvim.plugins" },
  { "AstroNvim/astrocommunity" },
  {
    "mikavilpas/yazi.nvim",
    enabled = vim.fn.executable "yazi" == 1,
    specs = {
      { "nvim-neo-tree/neo-tree.nvim", enabled = false },
    },
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<Leader>o",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>O",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        "<Leader>e",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig
    opts = {
      open_multiple_tabs = false,
      floating_window_scaling_factor = 0.8,
      -- the transparency of the yazi floating window (0-100). See :h winblend
      yazi_floating_window_winblend = 0,
      -- the type of border to use for the floating window. Can be many values,
      -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
      -- more information, see :h nvim_open_win
      yazi_floating_window_border = "rounded",
      open_for_directories = true,
      keymaps = {
        show_help = "<f2>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-e>",
        grep_in_directory = "<c-s>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<c-\\>",
      },
      integrations = {
        grep_in_directory = "fzf-lua",
        grep_in_selected_files = "fzf-lua",
      },
      future_features = {
        -- Whether to use `ya emit reveal` to reveal files in the file manager.
        -- Requires yazi 0.4.0 or later (from 2024-12-08).
        ya_emit_reveal = true,

        -- Use `ya emit open` as a more robust implementation for opening files
        -- in yazi. This can prevent conflicts with custom keymappings for the enter
        -- key. Requires yazi 0.4.0 or later (from 2024-12-08).
        ya_emit_open = true,
      },
    },
  },
  -- add any other plugins/customizations here
}
require("lazy").setup(plugins, {
  root = root .. "/plugins",
})

-- add anything else here (autocommands, vim.filetype, etc.)
