return {
  "ellisonleao/gruvbox.nvim",
  lazy = true, -- :colorscheme gruvbox 로 전환할 때 로드
  config = function()
    require("gruvbox").setup({
      contrast = "hard",
      transparent_mode = true,
    })
  end,
}
