--WARNING: now rust-analyzer is can't use in neovim, because this issue
-- https://github.com/rust-lang/rust-analyzer/issues/17289
-- https://github.com/williamboman/mason.nvim/issues/1741
local set_mappings = require("astrocore").set_mappings
-- rust-analyzer/bacon-ls
-- vim.g.astronvim_rust_diagnostics = "bacon-ls"
local diagnostics = vim.g.astronvim_rust_diagnostics or "rust-analyzer"

local function preview_stack_trace()
  local current_line = vim.api.nvim_get_current_line()
  local patterns_list = {
    "--> ([^:]+):(%d+):(%d+)",
    "at ([^:]+):(%d+):(%d+)",
  }

  local function try_patterns(patterns, line)
    for _, pattern in ipairs(patterns) do
      local filepath, line_nr, column_nr = string.match(line, pattern)
      if filepath and line_nr then return filepath, tonumber(line_nr), tonumber(column_nr or 0) end
    end
    return nil, nil, nil
  end

  local filepath, line_nr, column_nr = try_patterns(patterns_list, current_line)
  if filepath then
    vim.cmd ":wincmd k"
    vim.cmd("e " .. filepath)
    vim.api.nvim_win_set_cursor(0, { line_nr, column_nr })
  end
end

---@type LazySpec
return {
  {
    "cmrschwarz/rust-prettifier-for-lldb",
    lazy = true,
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = function(_, opts)
      if diagnostics ~= "rust-analyzer" then require("astrocore").list_insert_unique(opts.servers, { "bacon_ls" }) end
      return vim.tbl_deep_extend("force", opts, {
        handlers = {
          rust_analyzer = false,
        },
        ---@diagnostic disable: missing-fields
        config = {
          bacon_ls = {
            init_options = {
              updateOnSave = true,
              updateOnSaveWaitMillis = 1000,
              updateOnChange = false,
            },
          },
          rust_analyzer = {
            on_attach = function()
              vim.api.nvim_create_autocmd({ "TermOpen", "TermClose", "BufEnter" }, {
                pattern = "term://*",
                desc = "Jump to error line",
                callback = function()
                  if vim.bo.buftype == "terminal" then
                    local buf_name = vim.api.nvim_buf_get_name(0)
                    local cmd = string.match(buf_name, ":%s*(cargo build)$")
                    if cmd then
                      set_mappings({
                        n = {
                          ["gd"] = {
                            preview_stack_trace,
                            desc = "Jump to error line",
                          },
                        },
                      }, { buffer = true })
                    end
                  end
                end,
              })
            end,
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  buildScripts = {
                    enable = true,
                  },
                },
                -- Add clippy lints for Rust if using rust-analyzer
                checkOnSave = diagnostics == "rust-analyzer",
                -- Enable diagnostics if using rust-analyzer
                diagnostics = {
                  enable = diagnostics == "rust-analyzer",
                },
                procMacro = {
                  enable = true,
                  ignored = {
                    ["async-trait"] = { "async_trait" },
                    ["napi-derive"] = { "napi" },
                    ["async-recursion"] = { "async_recursion" },
                  },
                },
                files = {
                  excludeDirs = {
                    ".direnv",
                    ".git",
                    ".github",
                    ".gitlab",
                    "bin",
                    "node_modules",
                    "target",
                    "venv",
                    ".venv",
                  },
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
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "rust", "toml", "ron" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
      if diagnostics ~= "rust-analyzer" then
        require("astrocore").list_insert_unique(opts.ensure_installed, { "bacon" })
      end
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    opts = function()
      local adapter
      local success, package = pcall(function() return require("mason-registry").get_package "codelldb" end)
      local cfg = require "rustaceanvim.config"
      if success then
        local package_path = package:get_install_path()
        local codelldb_path = package_path .. "/codelldb"
        local liblldb_path = package_path .. "/extension/lldb/lib/liblldb"
        local this_os = vim.loop.os_uname().sysname

        -- The path in windows is different
        if this_os:find "Windows" then
          codelldb_path = package_path .. "\\extension\\adapter\\codelldb.exe"
          liblldb_path = package_path .. "\\extension\\lldb\\bin\\liblldb.dll"
        else
          -- The liblldb extension is .so for linux and .dylib for macOS
          liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      else
        adapter = cfg.get_codelldb_adapter()
      end

      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts "rust_analyzer") or {}
      local server = {
        ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
        settings = function(project_root, default_settings)
          local astrolsp_settings = astrolsp_opts.settings or {}

          local merge_table = vim.tbl_deep_extend("force", default_settings or {}, astrolsp_settings)
          local ra = require "rustaceanvim.config.server"
          -- load_rust_analyzer_settings merges any found settings with the passed in default settings table and then returns that table
          return ra.load_rust_analyzer_settings(project_root, {
            settings_file_pattern = "rust-analyzer.json",
            default_settings = merge_table,
          })
        end,
      }

      local final_server = vim.tbl_deep_extend("force", astrolsp_opts, server)
      return {
        server = final_server,
        dap = { adapter = adapter, configuration = false },
        tools = { enable_clippy = false },
      }
    end,
    config = function(_, opts)
      if vim.fn.executable "rust-analyzer" == 0 then
        vim.notify(
          "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
          vim.log.levels.ERROR
        )
      end
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = false },
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        on_attach = function(...) require("astrolsp").on_attach(...) end,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      local rustaceanvim_avail, rustaceanvim = pcall(require, "rustaceanvim.neotest")
      if rustaceanvim_avail then table.insert(opts.adapters, rustaceanvim) end
    end,
  },
}
