local M = {}

local status_utils = require "astroui.status.utils"

M.overseer_types = { canceled = "CANCELED", running = "RUNNING", success = "SUCCESS", failure = "FAILURE" }

function M.overseer(opts)
  if not opts or not opts.type then return end
  return function(self)
    local tasks = self.tasks
    local status = M.overseer_types[opts.type]
    local task_count = tasks[status] and #tasks[status]
    return status_utils.stylize(task_count and task_count > 0 and tostring(task_count) or "", opts)
  end
end

function M.select(opts)
  local get_selected_lines = function()
    local starts = vim.fn.line "v"
    local ends = vim.fn.line "."
    local count = starts <= ends and ends - starts + 1 or starts - ends + 1
    return count
  end
  return function()
    local get_select_count_ok, select_count = pcall(get_selected_lines)
    local select = nil
    if get_select_count_ok and select_count and select_count > 0 then
      select = ("(%d selected)"):format(select_count or "")
      return status_utils.stylize(select, opts)
    end
  end
end

return M
