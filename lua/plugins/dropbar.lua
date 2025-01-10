return {
  "Bekaboo/dropbar.nvim",
  event = "User AstroFile",
  opts = {},
  specs = {
    {
      "rebelot/heirline.nvim",
      optional = true,
      opts = function(_, opts) opts.winbar = nil end,
    },
  },
}
