---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  enabled = vim.fn.executable "yazi" == 1,
  specs = {
    { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  },
  event = "VeryLazy",
  keys = {
    {
      "<Leader>o",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>O",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
    {
      -- NOTE: this requires a version of yazi that includes
      -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
      "<Leader>e",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
  },
  opts = {
    open_multiple_tabs = false,
    floating_window_scaling_factor = {
      height = 1,
      width = 0.9,
    },
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
}
