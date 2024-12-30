local M = {}

local extend_tbl = require("astrocore").extend_tbl
local status_utils = require "astroui.status.utils"
local hl = require "astroui.status.hl"
local my_condition = require "heirline.condition"

function M.overseer(opts)
  opts = extend_tbl({
    condition = my_condition.overseer_load,
    running = { icon = { kind = "OverseerRunning", padding = { left = 1, right = 1 } } },
    success = {
      icon = { kind = "OverseerSuccess", padding = { left = 1, right = 1 } },
    },
    failure = { icon = { kind = "OverseerFailure", padding = { left = 1, right = 1 } } },
    canceled = { icon = { kind = "OverseerCanceled", padding = { left = 1, right = 1 } } },
    on_click = {
      name = "overseer_toggle",
      callback = function() vim.schedule(vim.cmd.OverseerToggle) end,
    },
    hl = hl.get_attributes "overseer",
    init = function(self)
      local tasks = require("overseer.task_list").list_tasks { unique = true }
      local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
      self.tasks = tasks_by_status
    end,
  }, opts)
  return M.builder(
    status_utils.setup_providers(opts, { "running", "success", "failure", "canceled" }, function(p_opts, p)
      local out = status_utils.build_provider(p_opts, p)
      if out then
        out.provider = "overseer"
        out.opts.type = p
        if out.hl == nil then out.hl = { fg = "overseer_" .. p } end
      end
      return out
    end)
  )
end

--- A general function to build a section of astronvim status providers with highlights, conditions, and section surrounding
---@param opts? table a list of components to build into a section
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").components.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })
function M.builder(opts)
  -- I had to write my own provider here because the source code is hardcoded.
  local my_provider = require "heirline.provider"
  local astro_provider = require "astroui.status.provider"
  local provider = require("astrocore").extend_tbl(astro_provider, my_provider)
  opts = extend_tbl({ padding = { left = 0, right = 0 } }, opts)
  local children, offset = {}, 0
  if opts.padding.left > 0 then -- add left padding
    table.insert(children, { provider = status_utils.pad_string(" ", { left = opts.padding.left - 1 }) })
    offset = offset + 1
  end
  for key, entry in pairs(opts) do
    if
      type(key) == "number"
      and type(entry) == "table"
      and provider[entry.provider]
      and (entry.opts == nil or type(entry.opts) == "table")
    then
      entry.provider = provider[entry.provider](entry.opts)
    end
    if type(key) == "number" then key = key + offset end
    children[key] = entry
  end
  if opts.padding.right > 0 then -- add right padding
    table.insert(children, { provider = status_utils.pad_string(" ", { right = opts.padding.right - 1 }) })
  end
  return opts.surround
      and status_utils.surround(
        opts.surround.separator,
        opts.surround.color,
        children,
        opts.surround.condition,
        opts.surround.update
      )
    or children
end

--- A function to build a set of children components for an entire navigation section
---@param opts? table options for configuring ruler, percentage, scrollbar, and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.nav()
function M.ruler(opts)
  opts = extend_tbl({
    ruler = {},
    select = { condition = my_condition.is_visual_mode },
    hl = hl.get_attributes "mode",
    update = {
      "CursorMoved",
      "CursorMovedI",
      "BufEnter",
      "ModeChanged",
      callback = function() vim.schedule(vim.cmd.redrawstatus) end,
    },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "ruler", "select" }))
end

return M
