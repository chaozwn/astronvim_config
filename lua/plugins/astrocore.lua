---@type LazySpec
return {
  "AstroNvim/astrocore",
  version = false,
  branch = "v2",
  ---@type AstroCoreOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("mapping").core_mappings(opts.mappings)
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
        relativenumber = false,
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

    return require("astrocore").extend_tbl(opts, {
      -- Configure core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 1024 * 1.5, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        autopairs = true, -- enable autopairs at start
        cmp = true, -- enable completion at start
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
      autocmds = {
        auto_turnoff_paste = {
          {
            event = "InsertLeave",
            pattern = "*",
            command = "set nopaste",
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
