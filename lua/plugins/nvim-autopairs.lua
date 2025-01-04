---@type LazySpec
return {
  "windwp/nvim-autopairs",
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts, {
      enable_check_bracket_line = true,
      map_c_h = true,
      map_c_w = true,
      map_bs = true,
      check_ts = true,
      enable_abbr = true,
      map_cr = false,
    })
  end,
}
