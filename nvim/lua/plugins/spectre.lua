-- 프로젝트 전체 찾아바꾸기 UI
return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    { "<leader>fR", function() require("spectre").open() end,                            desc = "Spectre: 프로젝트 찾아바꾸기" },
    { "<leader>fw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Spectre: 커서 단어로 찾기" },
    { "<leader>fW", function() require("spectre").open_visual() end, mode = "v",         desc = "Spectre: 선택 영역으로 찾기" },
  },
}
