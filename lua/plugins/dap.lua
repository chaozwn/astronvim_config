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
            function()
              local window = {
                width = require("utils").size(vim.o.columns, 0.8),
                height = require("utils").size(vim.o.lines, 0.8),
                position = "center",
                enter = true,
              }
              vim.ui.select({
                "console",
                "repl",
                "stacks",
                "breakpoints",
                "watches",
                "scopes",
              }, { prompt = "Select Dap Element", default = "console" }, function(select)
                if not select then return end
                if select == "repl" then
                  require("dapui").float_element("repl", window)
                elseif select == "stacks" then
                  require("dapui").float_element("stacks", window)
                elseif select == "breakpoints" then
                  require("dapui").float_element("breakpoints", window)
                elseif select == "watches" then
                  require("dapui").float_element("watches", window)
                elseif select == "console" then
                  require("dapui").float_element("console", window)
                elseif select == "scopes" then
                  require("dapui").float_element("scopes", window)
                end
              end)
            end,
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
    opts = {
      layouts = {
        {
          -- You can change the order of elements in the sidebar
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            {
              id = "scopes",
              size = 0.25, -- Can be float or integer > 1
            },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = require("utils").size(vim.o.columns, 0.2),
          position = "right", -- Can be "left" or "right"
        },
        {
          elements = {
            { id = "console", size = 0.4 },
            { id = "scopes", size = 0.6 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
      },
      render = {
        max_type_length = 100, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
        indent = 1,
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
