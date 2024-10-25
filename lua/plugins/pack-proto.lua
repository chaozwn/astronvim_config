local set_mappings = require("astrocore").set_mappings
local utils = require "utils"

local function create_buf_config_file()
  local source_file = vim.fn.stdpath "config" .. "/buf.yaml"
  local target_file = vim.fn.getcwd() .. "/buf.yaml"
  utils.copy_file(source_file, target_file)
end

local function create_buf_gen_config_file()
  local source_file = vim.fn.stdpath "config" .. "/buf.gen.yaml"
  local target_file = vim.fn.getcwd() .. "/buf.gen.yaml"
  utils.copy_file(source_file, target_file)
end

local function formatting_auto_import_config()
  local system_config = vim.fn.stdpath "config" .. "/buf.yaml"
  local project_config = vim.fn.getcwd() .. "/buf.yaml"

  local null_ls = require "null-ls"
  local buf_buildins = null_ls.builtins.formatting.buf
  table.insert(buf_buildins._opts.args, "--config")
  if vim.fn.filereadable(project_config) == 1 then
    table.insert(buf_buildins._opts.args, project_config)
  else
    table.insert(buf_buildins._opts.args, system_config)
  end
  null_ls.register(null_ls.builtins.formatting.buf.with(buf_buildins))
end

local function diagnostic_auto_import_config()
  local system_config = vim.fn.stdpath "config" .. "/buf.yaml"
  local project_config = vim.fn.getcwd() .. "/buf.yaml"

  local null_ls = require "null-ls"
  local buf_buildins = null_ls.builtins.diagnostics.buf
  table.insert(buf_buildins._opts.args, "--config")
  if vim.fn.filereadable(project_config) == 1 then
    table.insert(buf_buildins._opts.args, project_config)
  else
    table.insert(buf_buildins._opts.args, system_config)
  end
  null_ls.register(null_ls.builtins.diagnostics.buf.with(buf_buildins))
end

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        bufls = {
          filetypes = { "proto" },
          single_file_support = true,
          on_attach = function()
            set_mappings({
              n = {
                ["<Leader>lc"] = {
                  function()
                    local buf_path = vim.fn.getcwd() .. "/buf.yaml"
                    local buf_gen_path = vim.fn.getcwd() .. "/buf.gen.yaml"
                    if not utils.file_exists(buf_path) then
                      local confirm =
                        vim.fn.confirm("File `buf.yaml` Not Exist, Create it?", "&Yes\n&No", 1, "Question")
                      if confirm == 1 then create_buf_config_file() end
                    end

                    if not utils.file_exists(buf_gen_path) then
                      local confirm =
                        vim.fn.confirm("File `buf.gen.yaml` Not Exist, Create it?", "&Yes\n&No", 1, "Question")
                      if confirm == 1 then create_buf_gen_config_file() end
                    end
                  end,
                  desc = "Create Buf Config File",
                },
              },
            }, { buffer = true })
          end,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      -- Ensure that opts.ensure_installed exists and is a table or string "all".
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "proto" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "buf-language-server", "buf" })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "buf" })
      if not opts.handlers then opts.handlers = {} end

      opts.handlers.buf = function()
        diagnostic_auto_import_config()
        formatting_auto_import_config()
      end
    end,
  },
}
