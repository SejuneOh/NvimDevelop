-- Claude Code CLI 를 IDE 처럼 Neovim 에 연결한다. 선택 영역·열린 파일을 Claude 에 넘기고, 수정안을 diff 로 연다.
-- 시작할 때 서버를 띄워 ~/.claude/ide/ 에 lock 파일을 남기므로, zellij 다른 창의 claude 에서도 /ide 로 붙을 수 있다.
return {
  "coder/claudecode.nvim",
  event = "VeryLazy",
  opts = {
    terminal = {
      provider = "native", -- snacks.nvim 없이 Neovim 내장 터미널을 쓴다
      split_side = "right",
      split_width_percentage = 0.40,
    },
    diff_opts = { layout = "vertical" },
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude 창 토글" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude 창으로 이동" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "이전 대화 골라 이어가기" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "마지막 대화 이어가기" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "모델 고르기" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "현재 파일을 Claude 에 추가" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "선택 영역을 Claude 에 보내기" },
    { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "탐색기 파일을 Claude 에 추가", ft = { "NvimTree" } },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "수정안 받기" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "수정안 거절" },
  },
}
