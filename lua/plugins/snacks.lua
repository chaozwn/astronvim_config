return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      debug = { enabled = true },
      indent = {
        enabled = true,
        filter = function(buf)
          local forbidden_filetypes = { "markdown", "markdown.mdx" } -- Add your forbidden filetypes here
          local filetype = vim.bo[buf].filetype
          for _, ft in ipairs(forbidden_filetypes) do
            if filetype == ft then return false end
          end
          return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
        end,
      },
      notifier = { enabled = true },
      scroll = { enabled = true },
      scope = { enabled = true },
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" }, -- priority of signs on the left (high to low)
        right = { "fold", "git" }, -- priority of signs on the right (high to low)
        folds = {
          open = false, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        git = {
          -- patterns to match Git signs
          patterns = { "GitSign", "MiniDiffSign" },
        },
        refresh = 50, -- refresh at most every 50ms
      },
      profiler = { enabled = true },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts) opts.statuscolumn = false end,
  },
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "NMAC427/guess-indent.nvim", enabled = false },
}
