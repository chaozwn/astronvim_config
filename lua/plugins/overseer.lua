return {
  "stevearc/overseer.nvim",
  ---@param opts overseer.Config
  opts = function(_, opts)
    local astrocore = require "astrocore"
    if astrocore.is_available "toggleterm.nvim" then
      opts.strategy = {
        "terminal",
        use_shell = true,
        close_on_exit = true,
        quit_on_exit = "success",
      }
    end

    return require("astrocore").extend_tbl(opts, {
      dap = true,
      templates = { "builtin" },
      task_list = {
        direction = "right",
        bindings = {
          ["<C-l>"] = false,
          ["<C-h>"] = false,
          ["<C-k>"] = false,
          ["<C-j>"] = false,
          q = "<Cmd>close<CR>",
          K = "IncreaseDetail",
          J = "DecreaseDetail",
          ["<C-p>"] = "ScrollOutputUp",
          ["<C-n>"] = "ScrollOutputDown",
        },
      },
      -- Aliases for bundles of components. Redefine the builtins, or create your own.
      component_aliases = {
        -- Most tasks are initialized with the default components
        default = {
          { "display_duration", detail_level = 2 },
          "on_output_summarize",
          "on_exit_set_status",
          { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
        },
        -- Tasks from tasks.json use these components
        default_vscode = {
          "default",
          "on_result_diagnostics",
        },
      },
    })
  end,
  config = function(_, opts)
    local overseer = require "overseer"
    overseer.setup(opts)
  end,
  dependencies = {
    { "AstroNvim/astroui", opts = { icons = { Overseer = "" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local prefix = "<leader>m"
        maps.n[prefix] = { desc = require("astroui").get_icon("Overseer", 1, true) .. "Overseer" }

        maps.n[prefix .. "t"] = { "<Cmd>OverseerToggle<CR>", desc = "Toggle Overseer" }
        maps.n[prefix .. "c"] = { "<Cmd>OverseerRunCmd<CR>", desc = "Run Command" }
        maps.n[prefix .. "r"] = { "<Cmd>OverseerRun<CR>", desc = "Run Task" }
        maps.n[prefix .. "q"] = { "<Cmd>OverseerQuickAction<CR>", desc = "Quick Action" }
        maps.n[prefix .. "a"] = { "<Cmd>OverseerTaskAction<CR>", desc = "Task Action" }
        maps.n[prefix .. "i"] = { "<Cmd>OverseerInfo<CR>", desc = "Overseer Info" }
      end,
    },
  },
}
