return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    ---@diagnostic disable-next-line: assign-type-mismatch
    opts = function(_, opts)
      local astrocore = require "astrocore"
      local vtsls_ft = astrocore.list_insert_unique(vim.tbl_get(opts, "config", "vtsls", "filetypes") or {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      }, { "vue" })

      return astrocore.extend_tbl(opts, {
        ---@diagnostic disable: missing-fields
        config = {
          volar = {
            init_options = {
              vue = {
                hybridMode = true,
              },
            },
            settings = {
              vue = {
                updateImportsOnFileMove = { enabled = true },
                server = {
                  maxOldSpaceSize = 8092,
                },
              },
            },
          },
          vtsls = {
            filetypes = vtsls_ft,
            settings = {
              vtsls = {
                tsserver = {
                  globalPlugins = {},
                },
              },
            },
            before_init = function(_, config)
              local vue_plugin_config = {
                name = "@vue/typescript-plugin",
                location = require("utils").get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
                languages = { "vue" },
                configNamespace = "typescript",
                enableForWorkspaceTypeScriptVersions = true,
              }
              astrocore.list_insert_unique(config.settings.vtsls.tsserver.globalPlugins, { vue_plugin_config })
            end,
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "vue" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "vue-language-server", "js-debug-adapter" })
    end,
  },
}
