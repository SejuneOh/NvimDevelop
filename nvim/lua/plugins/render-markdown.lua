-- 마크다운 파일을 인라인 렌더링 (헤딩 / 체크박스 / 코드블록 등)
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown", "Avante", "codecompanion" },
  opts = {
    heading = { sign = false },
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    checkbox = {
      unchecked = { icon = "󰄱 " },
      checked   = { icon = "󰱒 " },
    },
  },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "Markdown: 렌더 토글" },
  },
}
