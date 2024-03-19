return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = require("astrocore").list_insert_unique(opts.registries, {
        "github:mason-org/mason-registry",
      })
    end,
  },
}
