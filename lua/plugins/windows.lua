---@type LazySpec
local prefix = "<Leader>w"

return {
  "AstroNvim/astrocore",
  opts = {
    options = {
      opt = {
        winwidth = 10,
        winminwidth = 10,
        equalalways = false,
      },
    },
    mappings = {
      n = {
        [prefix] = { desc = "󱂬 Window" },
        [prefix .. "c"] = { "<C-w>c", desc = "Close current screen" },
        [prefix .. "o"] = { "<C-w>o", desc = "Close other screen" },
        [prefix .. "e"] = { "<C-w>=", desc = "Equals All Window" },
      },
    },
  },
}
