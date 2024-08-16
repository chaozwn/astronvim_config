-- TODO: auto set up filename as debug name
local utils = require "astrocore"
local prefix_debug = "<Leader>d"
---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          [prefix_debug .. "q"] = {
            function()
              require("dap").close()
              local controls = require "dapui.controls"
              controls.refresh_control_panel()
            end,
            desc = "Close Session",
          },
          [prefix_debug .. "j"] = {
            function() require("dap").down() end,
            desc = "Down Strace",
          },
          [prefix_debug .. "k"] = {
            function() require("dap").up() end,
            desc = "Up Strace",
          },
          [prefix_debug .. "p"] = {
            function() require("dap.ui.widgets").preview() end,
            desc = "Debugger Preview",
          },
          [prefix_debug .. "P"] = { function() require("dap").pause() end, desc = "Pause (F6)" },
          [prefix_debug .. "u"] = {
            function() require("dapui").toggle { layout = 2, reset = true } end,
            desc = "Toggle Tray Debugger UI and reset layout",
          },
          [prefix_debug .. "U"] = {
            function() require("dapui").toggle { reset = true } end,
            desc = "Toggle All Debugger UI and reset layout",
          },
          [prefix_debug .. "r"] = {
            function() require("dap").run_last() end,
            desc = "Run Last",
          },
          [prefix_debug .. "R"] = {
            function() require("dap").restart_frame() end,
            desc = "Restart (C-F5)",
          },
          [prefix_debug .. "d"] = {
            ---@diagnostic disable-next-line: missing-parameter
            function() require("dapui").float_element() end,
            desc = "Open Dap UI Float Element",
          },
          ["<F9>"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Debugger: Toggle Breakpoint",
          },
          [prefix_debug .. "b"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Toggle Breakpoint (F9)",
          },
          [prefix_debug .. "B"] = {
            function() require("persistent-breakpoints.api").clear_all_breakpoints() end,
            desc = "Clear All Breakpoints",
          },
          [prefix_debug .. "C"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          },
          ["<F21>"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          },
          [prefix_debug .. "S"] = {
            function() require("dap").run_to_cursor() end,
            desc = "Run To Cursor",
          },
          [prefix_debug .. "s"] = {
            function()
              local w = require "dap.ui.widgets"
              w.centered_float(w.sessions, {})
            end,
            desc = "Switch Debug Session",
          },
          [prefix_debug .. "G"] = {
            require("utils").create_launch_json,
            desc = "Create Dap Launch Json",
          },
        },
      },
    },
  },
  { "jay-babu/mason-nvim-dap.nvim", optional = true },
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufEnter",
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        load_breakpoints_event = { "BufEnter" },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "LiadOz/nvim-dap-repl-highlights",
      dependencies = { "mfussenegger/nvim-dap" },
      opts = {},
    },
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "dap_repl" })
      end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    event = "User AstroFile",
    opts = {
      commented = true,
      enabled = true,
      enabled_commands = true,
      only_first_definition = true,
      virt_text_pos = "eol",
      highlight_changed_variables = false,
      all_frames = false,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function(_, opts)
      local dap, dapui = require "dap", require "dapui"
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open { layout = 2, reset = true }
      end
      dapui.setup(opts)
    end,
  },
}
