vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.opt.conceallevel = 2
vim.opt.list = false
vim.opt.listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" }
vim.opt.showbreak = "↪ "
vim.opt.splitkeep = "screen"
vim.opt.swapfile = false
vim.opt.wrap = true
vim.opt.scrolloff = 5
vim.opt.winwidth = 10
vim.opt.winminwidth = 10
vim.opt.equalalways = false
vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]

vim.g.autoformat = false
vim.g.trouble_lualine = true
vim.o.laststatus = 3

if vim.fn.has "nvim-0.10" == 1 then
  vim.opt.smoothscroll = true
  vim.opt.foldexpr = "v:lua.require'utils.ui'.foldexpr()"
  vim.opt.foldmethod = "expr"
  vim.opt.foldtext = ""
else
  vim.opt.foldmethod = "indent"
  vim.opt.foldtext = "v:lua.require'utils.ui'.foldtext()"
end
