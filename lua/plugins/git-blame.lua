local prefix_git_blame = "<Leader>g"

---@type LazySpec
return {
  "f-person/git-blame.nvim",
  event = "User AstroGitFile",
  specs = {
    {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        mappings = {
          n = {
            [prefix_git_blame .. "B"] = { desc = "Git Blame Functions" },
            [prefix_git_blame .. "Bc"] = {
              function() vim.cmd [[GitBlameOpenCommitURL]] end,
              desc = "Git Blame Open Commit URL",
            },
            [prefix_git_blame .. "Bs"] = {
              function() vim.cmd [[GitBlameCopySHA]] end,
              desc = "Git Blame Copy SHA",
            },
            [prefix_git_blame .. "Bo"] = {
              function() vim.cmd [[GitBlameOpenFileURL]] end,
              desc = "Git Blame Open File URL",
            },
            [prefix_git_blame .. "By"] = {
              function() vim.cmd [[GitBlameCopyFileURL]] end,
              desc = "Git Blame Copy File URL",
            },
          },
        },
      },
    },
  },
  cmd = {
    "GitBlameToggle",
    "GitBlameEnable",
    "GitBlameOpenCommitURL",
    "GitBlameCopyCommitURL",
    "GitBlameOpenFileURL",
    "GitBlameCopyFileURL",
    "GitBlameCopySHA",
  },
  opts = {
    enabled = true,
    date_format = "%r",
    message_template = "  <author> 󰔠 <date> 󰈚 <summary>  <sha>",
    message_when_not_committed = "  Not Committed Yet",
  },
}
