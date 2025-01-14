local function get_cmd(workspace_dir)
  local _ = require "mason-core.functional"
  local path = require "mason-core.path"
  local platform = require "mason-core.platform"

  local append_node_modules = _.map(function(dir) return path.concat { dir, "node_modules" } end)
  local install_dir = require("mason-registry").get_package("angular-language-server"):get_install_path()

  local cmd = {
    "ngserver",
    "--stdio",
    "--tsProbeLocations",
    table.concat(append_node_modules { workspace_dir, install_dir }, ","),
    "--ngProbeLocations",
    table.concat(
      append_node_modules {
        workspace_dir,
        path.concat { install_dir, "node_modules", "@angular", "language-server" },
      },
      ","
    ),
  }
  if platform.is.win then cmd[1] = vim.fn.exepath(cmd[1]) end

  return cmd
end

return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    ---@diagnostic disable-next-line: assign-type-mismatch
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        ---@diagnostic disable: missing-fields
        config = {
          angularls = {
            on_new_config = function(new_config, root_dir)
              -- WARNING:remove after pr merge: https://github.com/williamboman/mason-lspconfig.nvim/pull/503
              new_config.cmd = get_cmd(root_dir)
            end,
            root_dir = function(...)
              local util = require "lspconfig.util"
              return util.root_pattern(unpack {
                "nx.json",
                "angular.json",
              })(...)
            end,
            on_attach = function(client, _)
              if require("astrocore").is_available "angular-quickswitch.nvim" then
                require("astrocore").set_mappings({
                  n = {
                    ["gD"] = {
                      vim.cmd.NgQuickSwitchToggle,
                      desc = "angular quick switch toggle",
                    },
                  },
                }, { buffer = true })
              end
              client.server_capabilities.renameProvider = false
            end,
            settings = {
              angular = {
                provideAutocomplete = true,
                validate = true,
                suggest = {
                  includeAutomaticOptionalChainCompletions = true,
                  includeCompletionsWithSnippetText = true,
                },
              },
            },
          },
          vtsls = {
            settings = {
              vtsls = {
                tsserver = {
                  globalPlugins = {},
                },
              },
            },
            before_init = function(_, config)
              local angular_plugin_config = {
                name = "@angular/language-server",
                location = require("utils").get_pkg_path(
                  "angular-language-server",
                  "/node_modules/@angular/language-server"
                ),
                configNamespace = "typescript",
                enableForWorkspaceTypeScriptVersions = true,
              }
              require("astrocore").list_insert_unique(
                config.settings.vtsls.tsserver.globalPlugins,
                { angular_plugin_config }
              )
            end,
          },
        },
      })
    end,
  },
  {
    "chaozwn/angular-quickswitch.nvim",
    event = "VeryLazy",
    opts = {
      use_default_keymaps = false,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "angular" })
      end
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
        callback = function() vim.treesitter.start(nil, "angular") end,
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "angular-language-server" })
    end,
  },
}
