return {
  "NvChad/base46",
  lazy = true,
  init = function() vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46_cache/" end,
  build = function()
    vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46_cache/"
    require("base46").load_all_highlights()
  end,
  -- load base46 cache when necessary
  specs = {
    {
      "nvim-treesitter/nvim-treesitter",
      optional = true,
      opts = function()
        pcall(function()
          dofile(vim.g.base46_cache .. "syntax")
          dofile(vim.g.base46_cache .. "treesitter")
        end)
      end,
    },
    {
      "folke/which-key.nvim",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "whichkey") end)
      end,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "blankline") end)
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "telescope") end)
      end,
    },
    {
      "neovim/nvim-lspconfig",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "lsp") end)
      end,
    },
    {
      "nvim-tree/nvim-tree.lua",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "nvimtree") end)
      end,
    },
    {
      "williamboman/mason.nvim",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "mason") end)
      end,
    },
    {
      "lewis6991/gitsigns.nvim",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "git") end)
      end,
    },
    {
      "nvim-tree/nvim-web-devicons",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "devicons") end)
      end,
    },
    {
      "echasnovski/mini.icons",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "devicons") end)
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      opts = function()
        pcall(function() dofile(vim.g.base46_cache .. "cmp") end)
      end,
    },
  },
}
