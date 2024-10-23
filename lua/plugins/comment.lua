---@type LazySpec
return {
  "numToStr/Comment.nvim",
  opts = function()
    local ft = require "Comment.ft"
    ft.thrift = { "//%s", "/*%s*/" }
    ft.goctl = { "//%s", "/*%s*/" }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        local maps = require("astrocore").empty_map_table()
        maps.n["<C-/>"] = opts.mappings.n["<Leader>/"]
        maps.x["<C-/>"] = opts.mappings.x["<Leader>/"]
        -- end
        maps.n["<Leader>/"] = false
        maps.x["<Leader>/"] = false

        opts.mappings = require("astrocore").extend_tbl(opts.mappings, maps)
      end,
    },
  },
}
