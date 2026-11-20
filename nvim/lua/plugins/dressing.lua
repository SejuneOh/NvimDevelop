return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    require("dressing").setup({
      input = {
        enabled = true,
        default_prompt = "입력: ",
        prompt_align = "left",
        insert_only = true,
        start_in_insert = true,
        border = "rounded",
        relative = "cursor",
      },
      select = {
        enabled = true,
        backend = { "fzf_lua", "builtin" },
        trim_prompt = true,
      },
    })
  end,
}
