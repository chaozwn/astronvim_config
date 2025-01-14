local utils = require "utils"
local decode_json = utils.decode_json
local check_json_key_exists = utils.check_json_key_exists

local format_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }

local lsp_rooter, prettierrc_rooter

local has_prettier = function(bufnr)
  if type(bufnr) ~= "number" then bufnr = vim.api.nvim_get_current_buf() end
  local rooter = require "astrocore.rooter"
  if not lsp_rooter then
    lsp_rooter = rooter.resolve("lsp", {
      ignore = {
        servers = function(client)
          return not vim.tbl_contains({ "vtsls", "typescript-tools", "volar", "eslint", "tsserver" }, client.name)
        end,
      },
    })
  end
  if not prettierrc_rooter then
    prettierrc_rooter = rooter.resolve {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.json5",
      ".prettierrc.js",
      ".prettierrc.cjs",
      "prettier.config.js",
      ".prettierrc.mjs",
      "prettier.config.mjs",
      "prettier.config.cjs",
      ".prettierrc.toml",
    }
  end
  local prettier_dependency = false
  for _, root in ipairs(require("astrocore").list_insert_unique(lsp_rooter(bufnr), { vim.fn.getcwd() })) do
    local package_json = decode_json(root .. "/package.json")
    if
      package_json
      and (
        check_json_key_exists(package_json, "dependencies", "prettier")
        or check_json_key_exists(package_json, "devDependencies", "prettier")
      )
    then
      prettier_dependency = true
      break
    end
  end
  return prettier_dependency or next(prettierrc_rooter(bufnr))
end

local conform_formatter = function(bufnr) return has_prettier(bufnr) and { "prettierd" } or {} end

return {
  ---@type LazySpec
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        config = {
          eslint = {
            on_attach = function()
              require("astrocore").set_mappings({
                n = {
                  ["<Leader>lF"] = {
                    function() vim.cmd.EslintFixAll() end,
                    desc = "Format buffer",
                  },
                },
              }, { buffer = true })
            end,
          },
          vtsls = {
            on_attach = function(client, _)
              local existing_capabilities = vim.deepcopy(client.server_capabilities)

              if existing_capabilities == nil then return end

              existing_capabilities.documentFormattingProvider = nil

              local existing_filters = existing_capabilities.workspace.fileOperations.didRename.filters or {}
              local new_glob = "**/*.{ts,cts,mts,tsx,js,cjs,mjs,jsx,vue}"

              for _, filter in ipairs(existing_filters) do
                if filter.pattern and filter.pattern.matches == "file" then
                  filter.pattern.glob = new_glob
                  break
                end
              end

              existing_capabilities.workspace.fileOperations.didRename.filters = existing_filters

              client.server_capabilities = existing_capabilities

              require("astrocore").set_mappings({
                n = {
                  ["<Leader>lA"] = {
                    function() vim.lsp.buf.code_action { context = { only = { "source", "refactor", "quickfix" } } } end,
                    desc = "Lsp All Action",
                  },
                },
              }, { buffer = true })
            end,
            filetypes = {
              "javascript",
              "javascriptreact",
              "javascript.jsx",
              "typescript",
              "typescriptreact",
              "typescript.tsx",
            },
            settings = {
              complete_function_calls = true,
              vtsls = {
                enableMoveToFileCodeAction = false,
                autoUseWorkspaceTsdk = true,
                experimental = {
                  maxInlayHintLength = 30,
                  completion = {
                    enableServerSideFuzzyMatch = true,
                  },
                },
                tsserver = {
                  globalPlugins = {
                    {
                      name = "@styled/typescript-styled-plugin",
                      location = require("utils").get_global_npm_path(),
                      enableForWorkspaceTypeScriptVersions = true,
                    },
                  },
                },
              },
              typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = true,
                },
                inlayHints = {
                  parameterNames = { enabled = "literals" },
                  parameterTypes = { enabled = true },
                  variableTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  enumMemberValues = { enabled = true },
                },
              },
              javascript = {
                updateImportsOnFileMove = { enabled = "always" },
                inlayHints = {
                  parameterNames = { enabled = "literals" },
                  parameterTypes = { enabled = true },
                  variableTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  enumMemberValues = { enabled = true },
                },
              },
            },
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
        opts.ensure_installed = require("astrocore").list_insert_unique(
          opts.ensure_installed,
          { "javascript", "typescript", "tsx", "jsdoc", "styled" }
        )
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(
        opts.ensure_installed,
        { "vtsls", "eslint-lsp", "prettierd", "js-debug-adapter" }
      )
    end,
  },
  {
    "vuki656/package-info.nvim",
    dependencies = { { "MunifTanjim/nui.nvim", lazy = true } },
    event = "BufRead package.json",
    opts = {},
  },
  {
    "dmmulroy/tsc.nvim",
    cmd = { "TSC" },
    opts = {},
  },
  {
    "dmmulroy/ts-error-translator.nvim",
    opts = {},
    ft = { "typescript", "vue" },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local success, js_debug_adapter_path = pcall(
        function()
          return require("mason-registry").get_package("js-debug-adapter"):get_install_path()
            .. "/js-debug/src/dapDebugServer.js"
        end
      )
      if not success then return end

      local dap = require "dap"
      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              js_debug_adapter_path,
              "${port}",
            },
          },
        }
      end
      if not dap.adapters["node"] then
        dap.adapters["node"] = function(cb, config)
          if config.type == "node" then config.type = "pwa-node" end
          local nativeAdapter = dap.adapters["pwa-node"]
          if type(nativeAdapter) == "function" then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      if not dap.adapters["pwa-chrome"] then
        dap.adapters["pwa-chrome"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              js_debug_adapter_path,
              "${port}",
            },
          },
        }
      end

      local js_filetypes = { "typescriptreact", "typescript", "javascript", "javascriptreact", "vue" }

      local vscode = require "dap.ext.vscode"
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes
      vscode.type_to_filetypes["pwa-chrome"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-chrome",
              request = "launch",
              name = 'Launch Chrome with "localhost"',
              url = function()
                local co = coroutine.running()
                return coroutine.create(function()
                  vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:5173" }, function(url)
                    if url == nil or url == "" then
                      return
                    else
                      coroutine.resume(co, url)
                    end
                  end)
                end)
              end,
              webRoot = "${workspaceFolder}",
              protocol = "inspector",
              sourceMaps = true,
              skipFiles = { "<node_internals>/**", "node_modules/**", "${workspaceFolder}/node_modules/**" },
              resolveSourceMapLocations = {
                "${workspaceFolder}/apps/**/**",
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
            {
              type = "pwa-chrome",
              request = "attach",
              name = "Attach Program (pwa-chrome, select port)",
              webRoot = "${workspaceFolder}",
              protocol = "inspector",
              sourceMaps = true,
              port = function() return vim.fn.input("Select port: ", 9222) end,
              skipFiles = { "<node_internals>/**", "node_modules/**", "${workspaceFolder}/node_modules/**" },
            },
          }
        end
      end
    end,
  },
  {
    "echasnovski/mini.icons",
    optional = true,
    opts = {
      file = {
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".eslintrc.cjs"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-jest"(require("astrocore").plugin_opts "neotest-jest"))
      table.insert(opts.adapters, require "neotest-vitest"(require("astrocore").plugin_opts "neotest-vitest"))
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.formatters_by_ft then opts.formatters_by_ft = {} end
      for _, filetype in ipairs(format_filetypes) do
        opts.formatters_by_ft[filetype] = conform_formatter
      end
    end,
  },
}
