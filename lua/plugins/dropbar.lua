---@type LazySpec
return {
  "Bekaboo/dropbar.nvim",
  event = "UIEnter",
  opts = {},
  specs = {
    {
      "rebelot/heirline.nvim",
      optional = true,
      opts = function(_, opts) opts.winbar = nil end,
    },
  },
}
