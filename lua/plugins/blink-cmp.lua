return {
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      {
        "SergioRibera/cmp-dotenv",
      },
    },
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        sources = {
          compat = require("astrocore").list_insert_unique(opts.sources.compat or {}, { "dotenv" }),
          providers = {
            dotenv = {
              kind = "DotEnv",
              score_offset = -100,
              async = true,
            },
          },
        },
      })
    end,
  },
}
