return {
  "stevearc/overseer.nvim",
  event = "User AstroFile",
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

    local window_scaling_factor = 0.3
    local height = require("utils").size(vim.o.lines, window_scaling_factor)
    local width = require("utils").size(vim.o.columns, window_scaling_factor)
    return vim.tbl_deep_extend("force", opts, {
      dap = false,
      templates = { "builtin" },
      task_list = {
        width = width,
        height = height,
        default_detail = 1,
        direction = "bottom",
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
      bundles = {
        -- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
        -- these options (passed to list_tasks())
        save_task_opts = {
          bundleable = true,
        },
        -- Autostart tasks when they are loaded from a bundle
        autostart_on_load = false,
      },
    })
  end,
  specs = {
    {
      "mfussenegger/nvim-dap",
      optional = true,
      opts = function() require("overseer").enable_dap() end,
    },
    { "AstroNvim/astroui", opts = { icons = { Overseer = "" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
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
