local sql_ft = { "sql", "mysql", "plsql" }

local utils = require "utils"
local astrocore = require "astrocore"
local set_mappings = astrocore.set_mappings

local function create_sqlfluff_config_file()
  local source_file = vim.fn.stdpath "config" .. "/.sqlfluff"
  local target_file = vim.fn.getcwd() .. "/.sqlfluff"
  utils.copy_file(source_file, target_file)
end

local function formatting() return { "--dialect", "polyglot" } end

local function diagnostic()
  local system_config = vim.fn.stdpath "config" .. "/.sqlfluff"
  local project_config = vim.fn.getcwd() .. "/.sqlfluff"

  local sqlfluff = { "lint", "--format=json" }
  table.insert(sqlfluff, "--config")

  if vim.fn.filereadable(project_config) == 1 then
    table.insert(sqlfluff, project_config)
  else
    table.insert(sqlfluff, system_config)
  end

  return sqlfluff
end

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        auto_create_sqlfluff_config_file = {
          {
            event = "FileType",
            desc = "create completion",
            pattern = sql_ft,
            callback = function()
              set_mappings({
                n = {
                  ["<Leader>lc"] = {
                    create_sqlfluff_config_file,
                    desc = "Create sqlfluff config file",
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
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "sql" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "sqlfluff", "sqlfmt" })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        sqlfmt = {
          prepend_args = formatting(),
        },
      },
      formatters_by_ft = {
        sql = { "sqlfmt" },
        dbt = { "sqlfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        sqlfluff = {
          args = diagnostic(),
        },
      },
      linters_by_ft = {
        sql = { "sqlfluff" },
        dbt = { "sqlfluff" },
      },
    },
  },
}
