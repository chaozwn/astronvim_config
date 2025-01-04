return {
  "stevearc/conform.nvim",
  event = "User AstroFile",
  cmd = "ConformInfo",
  specs = {
    { "AstroNvim/astrolsp", optional = true, opts = { formatting = { disabled = true } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        maps.n["<Leader>lI"] = { function() vim.cmd.ConformInfo() end, desc = "Show Conform Info" }
        maps.n["<Leader>lf"] = { function() vim.cmd.Format() end, desc = "Format buffer" }
        maps.n["<Leader>uf"] = {
          function()
            if vim.b.autoformat == nil then
              if vim.g.autoformat == nil then vim.g.autoformat = true end
              vim.b.autoformat = vim.g.autoformat
            end
            vim.b.autoformat = not vim.b.autoformat
            require("astrocore").notify(string.format("Buffer autoformatting %s", vim.b.autoformat and "on" or "off"))
          end,
          desc = "Toggle autoformatting (buffer)",
        }
        maps.n["<Leader>uF"] = {
          function()
            if vim.g.autoformat == nil then vim.g.autoformat = true end
            vim.g.autoformat = not vim.g.autoformat
            vim.b.autoformat = nil
            vim.notify(
              string.format("Global autoformatting %s", vim.g.autoformat and "on" or "off"),
              vim.log.levels.INFO
            )
          end,
          desc = "Toggle autoformatting (global)",
        }
        return vim.tbl_deep_extend("force", opts, {
          options = { opt = { formatexpr = "v:lua.require'conform'.formatexpr()" } },
          commands = {
            Format = {
              function(args)
                local range = nil
                if args.count ~= -1 then
                  local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                  range = {
                    start = { args.line1, 0 },
                    ["end"] = { args.line2, end_line:len() },
                  }
                end
                require("conform").format { async = true, range = range }
              end,
              desc = "Format buffer",
              range = true,
            },
          },
        })
      end,
    },
  },
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.g.autoformat == nil then vim.g.autoformat = true end
      local autoformat = vim.b[bufnr].autoformat
      if autoformat == nil then autoformat = vim.g.autoformat end
      if autoformat then return { timeout_ms = 20000 } end
    end,
  },
}
