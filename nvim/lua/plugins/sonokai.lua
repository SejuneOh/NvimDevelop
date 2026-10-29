return {
  "sainnhe/sonokai",
  lazy = false,
  priority = 1000,
  config = function()
    -- sonokai 는 setup() 이 없고, colorscheme 명령 전에 vim.g 로 옵션을 지정해야 한다
    vim.g.sonokai_style = "atlantis"
    vim.g.sonokai_enable_italic = 1
    vim.g.sonokai_transparent_background = 1
    vim.g.sonokai_better_performance = 1
    vim.cmd("colorscheme sonokai")
  end,
}
