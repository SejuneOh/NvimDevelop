-- treesitter / indent 기반 폴딩 + 폴드 미리보기 UI
-- options.lua 의 foldexpr 설정과 함께 동작 (foldlevel=99, foldenable=false 유지)
return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = "BufReadPost",
  init = function()
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  opts = {
    provider_selector = function()
      return { "treesitter", "indent" }
    end,
    open_fold_hl_timeout = 150,
    preview = {
      win_config = {
        border = "rounded",
        winblend = 0,
      },
    },
  },
  keys = {
    { "zR", function() require("ufo").openAllFolds()  end, desc = "Fold: 모두 펼치기" },
    { "zM", function() require("ufo").closeAllFolds() end, desc = "Fold: 모두 접기" },
    { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Fold: 한 단계 펼치기" },
    { "zm", function() require("ufo").closeFoldsWith() end, desc = "Fold: 한 단계 접기" },
    { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Fold: 미리보기" },
  },
}
