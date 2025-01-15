-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
vim.treesitter.language.register("bash", "kitty")
-- Remove some keymaps, default set up in nvim 0.11
vim.tbl_map(function(v)
  require("utils").remove_keymap("n", "gr" .. v)
end, { "r", "a", "n", "i" })
