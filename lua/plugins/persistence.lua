local prefix = "<leader>S"

---@type LazySpec
return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { prefix,  desc = " Session" },
      { prefix .. "s", function() require("persistence").load() end, desc = "Restore Session" },
      { prefix .. "S", function() require("persistence").select() end,desc = "Select Session" },
      { prefix .. "l", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { prefix .. "d", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
  { "stevearc/resession.nvim", enabled = false },
}
