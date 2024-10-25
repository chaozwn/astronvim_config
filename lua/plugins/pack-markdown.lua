local utils = require "astrocore"

local markdown_table_change = function()
  vim.ui.input({ prompt = "Separate Char: " }, function(input)
    if not input or #input == 0 then return end
    local execute_command = ([[:'<,'>MakeTable! ]] .. input)
    vim.cmd(execute_command)
  end)
end

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        options = {
          g = {
            mkdp_auto_close = 0,
            mkdp_combine_preview = 1,
          },
        },
      })
    end,
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        marksman = {
          on_attach = function()
            if utils.is_available "markdown-preview.nvim" then
              utils.set_mappings({
                n = {
                  ["<Leader>lz"] = { "<cmd>MarkdownPreview<CR>", desc = "Markdown Start Preview" },
                  ["<Leader>lZ"] = { "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown Stop Preview" },
                  ["<Leader>lp"] = { "<cmd>PastifyAfter<CR>", desc = "Markdown Paste Image After" },
                  ["<Leader>lP"] = { "<cmd>Pastify<CR>", desc = "Markdown Paste Image" },
                },
                x = {
                  ["<Leader>lt"] = { [[:'<,'>MakeTable! \t<CR>]], desc = "Markdown csv to table(Default:\\t)" },
                  ["<Leader>lT"] = { markdown_table_change, desc = "Markdown csv to table with separate char" },
                },
              }, { buffer = true })
            end
          end,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed =
          utils.list_insert_unique(opts.ensure_installed, { "markdown", "markdown_inline", "html", "latex" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "marksman", "prettierd" })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "prettierd", "markdownlint" })

      opts.handlers.markdownlint = function()
        local null_ls = require "null-ls"
        local markdownlint_diagnostics_buildins = null_ls.builtins.diagnostics.markdownlint
        table.insert(markdownlint_diagnostics_buildins._opts.args, "--config")
        local system_config = vim.fn.stdpath "config" .. "/.markdownlint.jsonc"
        local project_config = vim.fn.getcwd() .. "/.markdownlint.jsonc"
        if vim.fn.filereadable(project_config) == 1 then
          table.insert(markdownlint_diagnostics_buildins._opts.args, project_config)
        else
          table.insert(markdownlint_diagnostics_buildins._opts.args, system_config)
        end
        null_ls.register(null_ls.builtins.diagnostics.markdownlint.with {
          generator_opts = markdownlint_diagnostics_buildins._opts,
        })
      end
    end,
  },
  -- install with yarn or npm
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    ft = { "markdown", "markdown.mdx" },
    init = function()
      local plugin = require("lazy.core.config").spec.plugins["markdown-preview.nvim"]
      vim.g.mkdp_filetypes = require("lazy.core.plugin").values(plugin, "ft", true)
    end,
  },
  {
    "TobinPalmer/pastify.nvim",
    cmd = { "Pastify", "PastifyAfter" },
    opts = {
      absolute_path = false,
      apikey = "",
      local_path = "/assets/imgs/",
      save = "local",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx" },
    event = "VeryLazy",
    opts = {
      bullet = {
        right_pad = 1,
      },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  },
  {
    "mattn/vim-maketable",
    cmd = "MakeTable",
    event = "BufEnter",
    ft = "markdown",
  },
}
