local utils = require "astrocore"
local set_mappings = utils.set_mappings

local function create_graphql_config_file()
  local source_file = vim.fn.stdpath "config" .. "/.graphqlrc.yml"
  local target_file = vim.fn.getcwd() .. "/.graphqlrc.yml"
  require("utils").copy_file(source_file, target_file)
end

return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        auto_create_graphql_config_file = {
          {
            event = "FileType",
            desc = "create completion",
            pattern = { "graphql" },
            callback = function()
              set_mappings({
                n = {
                  ["<Leader>lc"] = {
                    create_graphql_config_file,
                    desc = "Create graphql config file",
                  },
                },
              }, { buffer = true })
            end,
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "graphql" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "graphql-language-service-cli" })
    end,
  },
}
