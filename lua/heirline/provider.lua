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

return M
