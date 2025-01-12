---@type LazySpec
return {
  -- comments
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {
      lang = {
        thrift = { "//%s", "/*%s*/" },
        goctl = { "//%s", "/*%s*/" },
      },
    },
    dependencies = {
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

          opts.mappings = vim.tbl_deep_extend("force", opts.mappings, maps)
        end,
      },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    enabled = false,
  },
  {
    "numToStr/Comment.nvim",
    enabled = false,
  },
}
