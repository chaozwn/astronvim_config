---@type LazySpec
return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings
        if maps then
          maps.n["zz"] = {
            function() require("neoscroll").zz { half_win_duration = 250 } end,
            desc = "Center screen",
          }
          maps.x["zz"] = maps.n["zz"]
          maps.n["zt"] = {
            function() require("neoscroll").zt { half_win_duration = 250 } end,
            desc = "Top screen",
          }
          maps.x["zt"] = maps.n["zt"]
          maps.n["zb"] = {
            function() require("neoscroll").zb { half_win_duration = 250 } end,
            desc = "Bottom screen",
          }
          maps.x["zb"] = maps.n["zb"]
        end
        opts.mappings = maps
      end,
    },
  },
  opts = {
    mappings = {
      "<C-b>",
      "<C-f>",
      "<C-y>",
      "<C-e>",
    },
  },
}
