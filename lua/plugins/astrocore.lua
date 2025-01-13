---@type LazySpec
return {
  "AstroNvim/astrocore",
  version = false,
  branch = "v2",
  ---@type AstroCoreOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("mapping").core_mappings(opts.mappings)
    local utils = require "utils"
    local options = {
      opt = {
        fillchars = {
          fold = " ",
          foldsep = " ",
          diff = "╱",
          eob = " ",
        },
        conceallevel = 2,
        list = false,
        listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
        showbreak = "↪ ",
        splitkeep = "screen",
        swapfile = false,
        wrap = true,
        scrolloff = 5,
        -- windows
        winwidth = 10,
        winminwidth = 10,
        equalalways = false,
      },
      g = {
        autoformat = false,
      },
    }

    if vim.fn.has "nvim-0.10" == 1 then
      options.opt.smoothscroll = true
      options.opt.foldexpr = "v:lua.require'ui'.foldexpr()"
      options.opt.foldmethod = "expr"
      options.opt.foldtext = ""
    else
      options.opt.foldmethod = "indent"
      options.opt.foldtext = "v:lua.require'ui'.foldtext()"
    end

    return vim.tbl_deep_extend("force", opts, {
      -- Configure core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 1024 * 1.5, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        autopairs = false, -- enable autopairs at start
        cmp = false, -- enable completion at start
        diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
        highlighturl = true, -- highlight URLs at start
        notifications = true, -- enable notifications at start
      },
      -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
      diagnostics = {
        -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
        virtual_text = {
          prefix = "",
        },
        update_in_insert = false,
        underline = true,
      },
      filetypes = {
        extension = {
          mdx = "markdown.mdx",
          qmd = "markdown",
          yml = utils.yaml_ft,
          yaml = utils.yaml_ft,
          json = "jsonc",
          MD = "markdown",
          tpl = "gotmpl",
        },
        filename = {
          [".eslintrc.json"] = "jsonc",
          ["vimrc"] = "vim",
        },
        pattern = {
          ["/tmp/neomutt.*"] = "markdown",
          ["tsconfig*.json"] = "jsonc",
          [".*/%.vscode/.*%.json"] = "jsonc",
          [".*/waybar/config"] = "jsonc",
          [".*/mako/config"] = "dosini",
          [".*/kitty/.+%.conf"] = "kitty",
          [".*/hypr/.+%.conf"] = "hyprlang",
          ["%.env%.[%w_.-]+"] = "sh",
        },
      },
      autocmds = {
        auto_close_molten_output = {
          {
            event = "FileType",
            pattern = { "molten_output" },
            callback = function(event)
              vim.bo[event.buf].buflisted = false
              vim.schedule(function()
                vim.keymap.set("n", "q", function() vim.cmd "MoltenHideOutput" end, {
                  buffer = event.buf,
                  silent = true,
                  desc = "Quit buffer",
                })
              end)
            end,
          },
        },
        auto_close_dadbod_output = {
          {
            event = "FileType",
            pattern = { "dbout" },
            callback = function(event)
              vim.bo[event.buf].buflisted = false
              vim.schedule(function()
                vim.keymap.set("n", "q", function() vim.cmd "q!" end, {
                  buffer = event.buf,
                  silent = true,
                  desc = "Quit buffer",
                })
              end)
            end,
          },
        },
      },
      -- vim options can be configured here
      options = options,
      -- Mappings can be configured through AstroCore as well.
      -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
      mappings = mappings,
    })
  end,
}
