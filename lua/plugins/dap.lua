-- TODO: auto set up filename as debug name
local prefix_debug = "<Leader>d"

local is_dap_window_open = function()
  local windows = require "dapui.windows"
  local is_window_open = false
  for i = 1, #windows.layouts, 1 do
    if windows.layouts[i]:is_open() then is_window_open = true end
  end
  return is_window_open
end

local close_all_window = function()
  local windows = require "dapui.windows"
  for i = 1, #windows.layouts, 1 do
    windows.layouts[i]:close()
  end
end

local choose_dap_element = function(callback)
  vim.ui.select({
    "repl|console",
    "console|scopes",
    "console",
    "repl",
    "stacks",
    "breakpoints",
    "watches",
    "scopes",
    "all elements",
  }, { prompt = "Select Dap Layout: ", default = "repl&console" }, function(select)
    if not select then return end
    if is_dap_window_open() then close_all_window() end
    if select == "console|scopes" then
      require("dapui").open { layout = 1, reset = true }
    elseif select == "console" then
      require("dapui").open { layout = 2, reset = true }
    elseif select == "repl" then
      require("dapui").open { layout = 3, reset = true }
    elseif select == "stacks" then
      require("dapui").open { layout = 4, reset = true }
    elseif select == "breakpoints" then
      require("dapui").open { layout = 5, reset = true }
    elseif select == "watches" then
      require("dapui").open { layout = 6, reset = true }
    elseif select == "scopes" then
      require("dapui").open { layout = 7, reset = true }
    elseif select == "repl|console" then
      require("dapui").open { layout = 9, reset = true }
    else
      require("dapui").open { layout = 8, reset = true }
      require("dapui").open { layout = 9, reset = true }
    end
    if callback then callback() end
  end)
end

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
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      --NOTE: remove when commit merge: https://github.com/rcarriga/cmp-dap/pull/13
      {
        "rcarriga/cmp-dap",
        commit = "db7ad7856309138ec31627271ac17a30e9d342ed",
      },
    },
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        enabled = function()
          return (vim.bo.buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()) and vim.b.completion ~= false
        end,
        sources = {
          compat = require("astrocore").list_insert_unique(opts.sources.compat or {}, { "dap" }),
          providers = {
            dap = {
              kind = "Dap",
              score_offset = 100,
              async = true,
              enabled = function() return require("cmp_dap").is_dap_buffer() end,
            },
          },
        },
      })
    end,
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
          maps.n[prefix_debug .. "c"] = {
            function()
              local is_window_open = is_dap_window_open()
              if not is_window_open then
                choose_dap_element(function() require("dap").continue() end)
              else
                require("dap").continue()
              end
            end,
            desc = "Start Debug",
          }
          maps.n[prefix_debug .. "u"] = {
            function()
              local is_window_open = is_dap_window_open()
              if is_window_open then
                close_all_window()
              else
                choose_dap_element()
              end
            end,
            desc = "Toggle Tray Debugger UI and reset layout",
          }
          maps.n[prefix_debug .. "r"] = {
            function() require("dap").run_last() end,
            desc = "Run Last",
          }
          maps.n[prefix_debug .. "R"] = {
            function() require("dap").restart_frame() end,
            desc = "Restart (C-F5)",
          }
          maps.n[prefix_debug .. "h"] = {
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
              }, { prompt = "Select Dap Element: ", default = "console" }, function(select)
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
          maps.n[prefix_debug .. "d"] = {
            function() choose_dap_element() end,
            desc = "Swith dap ui element",
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
          elements = {
            { id = "console", size = 0.4 },
            { id = "scopes", size = 0.6 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "console", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "repl", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "stacks", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "breakpoints", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "watches", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "scopes", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
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
            { id = "repl", size = 0.4 },
            { id = "console", size = 0.6 },
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
      local dapui = require "dapui"
      local dap = require "dap"

      local events = {
        "event_continued",
        "event_exited",
        "event_initialized",
        "event_invalidated",
        "event_stopped",
        "event_terminated",
        "event_thread",
        "attach",
        "continue",
        "disconnect",
        "initialize",
        "launch",
        "next",
        "pause",
        "restart",
        "restartFrame",
        "stepBack",
        "stepIn",
        "stepInTargets",
        "stepOut",
        "terminate",
        "terminateThreads",
      }
      for _, event in ipairs(events) do
        dap.listeners.after[event].dapui_config = function() require("dapui.controls").refresh_control_panel() end
        dap.listeners.before[event].dapui_config = function() require("dapui.controls").refresh_control_panel() end
      end
      dapui.setup(opts)
    end,
  },
}
