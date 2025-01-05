---@type LazySpec
return {
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    specs = {
      {
        "AstroNvim/astrolsp",
        ---@type AstroLSPOpts
        opts = function(_, opts)
          return vim.tbl_deep_extend("force", opts, {
            ---@diagnostic disable: missing-fields
            config = {
              yamlls = {
                on_attach = function(client, _)
                  -- Neovim < 0.10 does not have dynamic registration for formatting
                  if vim.fn.has "nvim-0.10" == 0 then client.server_capabilities.documentFormattingProvider = true end
                end,
                on_new_config = function(config)
                  config.settings.yaml.schemas = vim.tbl_deep_extend(
                    "force",
                    config.settings.yaml.schemas or {},
                    require("schemastore").yaml.schemas()
                  )
                end,
                settings = { yaml = { schemaStore = { enable = false, url = "" } } },
              },
            },
          })
        end,
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "yaml-language-server", "prettierd" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "xml", "yaml" })
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        yaml = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
}
