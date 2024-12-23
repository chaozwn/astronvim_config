return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      debug = { enabled = true },
      indent = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
    },
  },
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "NMAC427/guess-indent.nvim", enabled = false },
}
