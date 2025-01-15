local sql_ft = { "sql", "mysql", "plsql", "dbt" }

local utils = require "utils"
local astrocore = require "astrocore"
local set_mappings = astrocore.set_mappings

local function sql_formatter_linter(name)
  local f_by_ft = {}
  for _, ft in ipairs(sql_ft) do
    f_by_ft[ft] = { name }
  end
  return f_by_ft
end

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

local function remove_special_chars(input_str)
  local pattern = "[%+%*%?%.%^%$%(%)%[%]%%%-&%#]"
  local resultStr = input_str:gsub(pattern, "")
  return resultStr
end

---@type LazySpec
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = {
      { "tpope/vim-dadbod", cmd = "DB", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = sql_ft, lazy = true },
    },
    specs = {
      "saghen/blink.cmp",
      optional = true,
      opts = function(_, opts)
        return require("astrocore").extend_tbl(opts, {
          sources = {
            default = require("astrocore").list_insert_unique(opts.sources.default, { "dadbod" }),
            providers = {
              dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
            },
          },
        })
      end,
    },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
    },
    init = function()
      local data_path = vim.fn.stdpath "data"

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_winwidth = require("utils").size(vim.o.columns, 0.3)
      vim.g.db_ui_win_position = "right"
      vim.g.db_ui_disable_info_notifications = 1

      vim.g.Db_ui_buffer_name_generator = function(opts)
        local table_name = opts.table

        if table_name and table_name ~= "" then
          return string.format("%s_%s.sql", remove_special_chars(table_name), os.time())
        else
          return string.format("console_%s.sql", os.time())
        end
      end

      -- NOTE: The default behavior of auto-execution of queries on save is disabled
      -- this is useful when you have a big query that you don't want to run every time
      -- you save the file running those queries can crash neovim to run use the
      -- default keymap: <leader>S
      vim.g.db_ui_execute_on_save = false
    end,
  },
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
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        formatters = {
          sqlfmt = {
            prepend_args = formatting(),
          },
        },
        formatters_by_ft = sql_formatter_linter "sqlfmt",
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        linters = {
          sqlfluff = {
            args = diagnostic(),
          },
        },
        linters_by_ft = sql_formatter_linter "sqlfluff",
      })
    end,
  },
}
