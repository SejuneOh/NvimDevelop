-- 터미널 토글 (float / horizontal / vertical)
-- `<C-\>` 는 smart-splits 의 터미널 모드 이동 시퀀스와 겹칠 수 있어 비활성화
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    { "<leader>Tt", "<cmd>ToggleTerm direction=float<CR>",                desc = "Terminal: 플로팅" },
    { "<leader>Th", "<cmd>ToggleTerm direction=horizontal size=15<CR>",   desc = "Terminal: 가로 분할" },
    { "<leader>Tv", "<cmd>ToggleTerm direction=vertical size=80<CR>",     desc = "Terminal: 세로 분할" },
  },
  opts = {
    open_mapping = false,
    -- shade_terminals 를 끄면 nvim 본문 배경 톤과 동일해져
    -- 셸 프롬프트의 어두운 색(git branch 등)이 묻히지 않음
    shade_terminals = false,
    start_in_insert = true,
    persist_size = true,
    direction = "float",
    float_opts = {
      border = "rounded",
      winblend = 0,
    },
    highlights = {
      Normal      = { link = "Normal" },
      NormalFloat = { link = "NormalFloat" },
      FloatBorder = { link = "FloatBorder" },
    },
  },
}
