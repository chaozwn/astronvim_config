local M = {}

function M.overseer_load() return package.loaded.overseer end

function M.is_visual_mode()
  local mode = vim.fn.mode()
  return mode == "v" or mode == "V" or mode == "\22"
end

return M
