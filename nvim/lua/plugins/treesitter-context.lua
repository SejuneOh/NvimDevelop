-- 스크롤 시 현재 함수/클래스 헤더를 상단에 고정 표시
return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "BufReadPost",
  opts = {
    max_lines = 3,
    multiline_threshold = 1,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
  },
  keys = {
    { "<leader>uc", "<cmd>TSContextToggle<CR>", desc = "Context: 토글" },
  },
}
