---@type LazySpec
return {
  "echasnovski/mini.diff",
  event = "User AstroGitFile",
  opts = function()
    local sign = require("astroui").get_icon "GitSign"
    return {
      view = {
        style = "sign",
        signs = { add = sign, change = sign, delete = sign },
      },
      mappings = {
        apply = "<Leader>gh",
        goto_first = "[G",
        goto_last = "]G",
        goto_next = "]g",
        goto_prev = "[g",
        reset = "<Leader>gr",
        textobject = "gh",
      },
    }
  end,
  specs = {
    { "lewis6991/gitsigns.nvim", enabled = false },
    -- lualine integration
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        local x = opts.sections.lualine_x
        for _, comp in ipairs(x) do
          if comp[1] == "diff" then
            comp.source = function()
              local summary = vim.b.minidiff_summary
              return summary
                and {
                  added = summary.add,
                  modified = summary.change,
                  removed = summary.delete,
                }
            end
            break
          end
        end
      end,
    },
  },
}
