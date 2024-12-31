local set_mappings = require("astrocore").set_mappings
local is_available = require("astrocore").is_available

return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    ---@diagnostic disable-next-line: assign-type-mismatch
    opts = function(_, opts)
      local astrocore = require "astrocore"

      return astrocore.extend_tbl(opts, {
        ---@diagnostic disable: missing-fields
        config = {
          angularls = {
            on_new_config = function(config, root_dir)
              local node_modules_path = root_dir .. "/node_modules"
              local angularls_node_modules_path = require("mason-registry")
                .get_package("angular-language-server")
                :get_install_path() .. "/node_modules"
              config.cmd = {
                "ngserver",
                "--stdio",
                "--tsProbeLocations",
                -- 优先使用项目内的 typescript 版本，其次使用 angular-language-server 的 typescript 版本
                table.concat({
                  node_modules_path,
                  angularls_node_modules_path
                }, ","),
                "--ngProbeLocations",
                -- 优先使用项目内的 angular 版本，其次使用 angular-language-server 的 angular 版本
                table.concat({
                  node_modules_path,
                  angularls_node_modules_path
                }, ","),
              }
            end,
            root_dir = function(...)
              local util = require "lspconfig.util"
              return vim.fs.dirname(vim.fs.find(".git", { path = ..., upward = true })[1])
                or util.root_pattern(unpack {
                  "nx.json",
                  "angular.json",
                })(...)
            end,
            on_attach = function(client, _)
              if is_available "angular-quickswitch.nvim" then
                set_mappings({
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
                  globalPlugins = {
                    {
                      name = "@angular/language-server",
                      location = require("utils").get_pkg_path(
                        "angular-language-server",
                        "/node_modules/@angular/language-server"
                      ),
                      enableForWorkspaceTypeScriptVersions = false,
                    },
                  },
                },
              },
            },
          },
        },
      })
    end,
  },
  { "chaozwn/angular-quickswitch.nvim", event = "VeryLazy", opts = {
    use_default_keymaps = false,
  } },
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
