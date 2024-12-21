local utils = require "utils"

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
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
    ["vifmrc"] = "vim",
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
}
vim.treesitter.language.register("bash", "kitty")
-- Remove some keymaps, default set up in nvim 0.11
vim.tbl_map(function(v) vim.api.nvim_del_keymap("n", "gr" .. v) end, { "r", "a", "n", "i" })
