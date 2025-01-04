---@type LazySpec
return {
  "chaozwn/im-select.nvim",
  event = "User AstroFile",
  opts = {
    default_command = "macism",
    default_main_select = "im.rime.inputmethod.Squirrel.Hans",
    set_previous_events = { "InsertEnter", "FocusLost" },
  },
}
