-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    version = false,
    branch = "v3",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "tokyonight-storm",
    },
  },
}
