---@type LazySpec
return {
  "ThePrimeagen/refactoring.nvim",
  event = "VeryLazy",
  specs = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      ---@diagnostic disable: missing-fields
      ---@diagnostic disable: missing-parameter
      opts = function(_, opts)
        local prefix = "<Leader>r"
        local maps = opts.mappings or {}
        local get_icon = require("astroui").get_icon

        maps.n[prefix] = { name = get_icon("Refactoring", 1, true) .. "Refactor" }
        maps.n[prefix .. "b"] = {
          function() require("refactoring").refactor "Extract Block" end,
          desc = "Extract Block",
        }
        maps.n[prefix .. "i"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inline Variable",
        }
        maps.n[prefix .. "p"] = {
          function() require("refactoring").debug.printf { below = false } end,
          desc = "Debug: Print Function",
        }
        maps.n[prefix .. "c"] = {
          function() require("refactoring").debug.cleanup {} end,
          desc = "Debug: Clean Up",
        }
        maps.n[prefix .. "d"] = {
          function() require("refactoring").debug.print_var { below = false } end,
          desc = "Debug: Print Variable",
        }
        maps.n[prefix .. "bf"] = {
          function() require("refactoring").refactor "Extract Block To File" end,
          desc = "Extract Block To File",
        }

        maps.x[prefix] = { name = get_icon("Refactoring", 1, true) .. "Refactor" }
        maps.x[prefix .. "e"] = {
          function() require("refactoring").refactor "Extract Function" end,
          desc = "Extract Function",
        }
        maps.x[prefix .. "f"] = {
          function() require("refactoring").refactor "Extract Function To File" end,
          desc = "Extract Function To File",
        }
        maps.x[prefix .. "v"] = {
          function() require("refactoring").refactor "Extract Variable" end,
          desc = "Extract Variable",
        }
        maps.x[prefix .. "i"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inline Variable",
        }

        maps.v[prefix] = { name = get_icon("Refactoring", 1, true) .. "Refactor" }
        maps.v[prefix .. "e"] = {
          function() require("refactoring").refactor "Extract Function" end,
          desc = "Extract Function",
        }
        maps.v[prefix .. "f"] = {
          function() require("refactoring").refactor "Extract Function To File" end,
          desc = "Extract Function To File",
        }
        maps.v[prefix .. "v"] = {
          function() require("refactoring").refactor "Extract Variable" end,
          desc = "Extract Variable",
        }
        maps.v[prefix .. "i"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inline Variable",
        }
        maps.v[prefix .. "b"] = {
          function() require("refactoring").refactor "Extract Block" end,
          desc = "Extract Block",
        }
        maps.v[prefix .. "bf"] = {
          function() require("refactoring").refactor "Extract Block To File" end,
          desc = "Extract Block To File",
        }
        maps.v[prefix .. "r"] = {
          function() require("refactoring").select_refactor() end,
          desc = "Select Refactor",
        }
        maps.v[prefix .. "p"] = {
          function() require("refactoring").debug.printf { below = false } end,
          desc = "Debug: Print Function",
        }
        maps.v[prefix .. "c"] = {
          function() require("refactoring").debug.cleanup {} end,
          desc = "Debug: Clean Up",
        }
        maps.v[prefix .. "d"] = {
          function() require("refactoring").debug.print_var { below = false } end,
          desc = "Debug: Print Variable",
        }
      end,
    },
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Refactoring = "󰣪",
        },
      },
    },
  },
  opts = {
    prompt_func_return_type = {
      go = true,
    },
    prompt_func_param_type = {
      go = true,
    },
  },
}
