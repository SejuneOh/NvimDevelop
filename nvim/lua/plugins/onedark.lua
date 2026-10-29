return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "warm",
      -- 본문 배경을 Alacritty 배경(warm 의 bg_d)과 같은 색으로 맞춘다
      colors = { bg0 = "#242628" },
    })
    require("onedark").load()
  end,
}
