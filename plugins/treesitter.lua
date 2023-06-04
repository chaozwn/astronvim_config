-- :TSInstall lua
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "mrjones2014/nvim-ts-rainbow" },
  opts = function(_, opts)
    return require("astronvim.utils").extend_tbl(opts, {
      auto_install = true,
      ensure_installed = {
        "regex",
        "bash",
        "markdown",
        "markdown_inline",
        "json",
        "html",
        "css",
        "vim",
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "java",
        "toml",
        "markdown",
        "markdown_inline",
        "vue",
        "prisma",
      },
      rainbow = {
        enable = true,
      },
    })
  end,
}
