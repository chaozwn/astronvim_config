return {
  ----------------------- 替换和交换插件 --------------------------------
  {
    "gbprod/substitute.nvim",
    opts = {
      on_substitute = nil,
      yank_substituted_text = false,
      highlight_substituted_text = {
        enabled = true,
        timer = 500,
      },
      range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        motion1 = false,
        motion2 = false,
        suffix = "",
      },
      exchange = {
        motion = false,
        use_esc_to_cancel = true,
      },
    },
    event = "User AstroFile",
  },
}
