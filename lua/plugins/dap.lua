-- TODO: auto set up filename as debug name
local prefix_debug = "<Leader>d"
---@type LazySpec
return {
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        load_breakpoints_event = { "BufReadPost" },
      })
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    opts = {
      commented = true,
      enabled = true,
      enabled_commands = true,
      only_first_definition = true,
      clear_on_continue = true,
      highlight_changed_variables = true,
      all_frames = false,
      virt_lines = true,
      show_stop_reason = true,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    specs = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = function(_, opts)
          local maps = opts.mappings or {}
          maps.n[prefix_debug .. "q"] = {
            function() require("dap").terminate() end,
            desc = "Terminate Session (S-F5)",
          }
          maps.n[prefix_debug .. "Q"] = {
            function() require("dap").close() end,
            desc = "Close Session",
          }
          maps.n[prefix_debug .. "j"] = {
            function() require("dap").down() end,
            desc = "Down Strace",
          }
          maps.n[prefix_debug .. "k"] = {
            function() require("dap").up() end,
            desc = "Up Strace",
          }
          maps.n[prefix_debug .. "p"] = {
            function() require("dap.ui.widgets").preview() end,
            desc = "Debugger Preview",
          }
          maps.n[prefix_debug .. "P"] = { function() require("dap").pause() end, desc = "Pause (F6)" }
          maps.n[prefix_debug .. "u"] = {
            function() require("dapui").toggle { layout = 2, reset = true } end,
            desc = "Toggle Tray Debugger UI and reset layout",
          }
          maps.n[prefix_debug .. "U"] = {
            function() require("dapui").toggle { reset = true } end,
            desc = "Toggle All Debugger UI and reset layout",
          }
          maps.n[prefix_debug .. "r"] = {
            function() require("dap").run_last() end,
            desc = "Run Last",
          }
          maps.n[prefix_debug .. "R"] = {
            function() require("dap").restart_frame() end,
            desc = "Restart (C-F5)",
          }
          maps.n[prefix_debug .. "d"] = {
            ---@diagnostic disable-next-line: missing-parameter
            function() require("dapui").float_element() end,
            desc = "Open Dap UI Float Element",
          }
          maps.n["<F9>"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Debugger: Toggle Breakpoint",
          }
          maps.n[prefix_debug .. "b"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Toggle Breakpoint (F9)",
          }
          maps.n[prefix_debug .. "B"] = {
            function() require("persistent-breakpoints.api").clear_all_breakpoints() end,
            desc = "Clear All Breakpoints",
          }
          maps.n[prefix_debug .. "C"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          }
          maps.n["<F21>"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          }
          maps.n[prefix_debug .. "S"] = {
            function() require("dap").run_to_cursor() end,
            desc = "Run To Cursor",
          }
          maps.n[prefix_debug .. "s"] = {
            function()
              local w = require "dap.ui.widgets"
              w.centered_float(w.sessions, {})
            end,
            desc = "Switch Debug Session",
          }
          maps.n[prefix_debug .. "G"] = {
            require("utils").create_launch_json,
            desc = "Create dap launch json",
          }
          maps.n[prefix_debug .. "g"] = {
            function() vim.cmd [[DapShowLog]] end,
            desc = "Show dap log",
          }
          maps.n["gh"] = { function() require("dap.ui.widgets").hover() end, desc = "Debugger Hover" }
        end,
      },
    },
    config = function(_, opts)
      local dap, dapui = require "dap", require "dapui"
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open { layout = 2, reset = true }
      end
      dapui.setup(opts)
    end,
  },
}
