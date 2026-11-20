-- 외부 프로그램 fzf 가 필요하다 (apt: fzf, brew: fzf). fd, rg 가 있으면 파일·텍스트 검색에 쓴다.
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  opts = {
    winopts = {
      height = 0.85,
      width = 0.85,
      preview = { layout = "flex", flip_columns = 120 },
    },
    keymap = {
      fzf = {
        -- <C-j>/<C-k> 위아래 이동은 fzf 기본값이다
        ["ctrl-q"] = "select-all+accept", -- 결과 전체를 quickfix 로 보낸다
      },
    },
    files = { path_shorten = false, formatter = "path.filename_first" },
  },
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "파일 찾기" },
    {
      "<leader>fF",
      function()
        require("fzf-lua").files({ hidden = true, no_ignore = true })
      end,
      desc = "파일 찾기 (숨김 + gitignore 포함)",
    },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "최근 파일" },
    { "<leader>fs", "<cmd>FzfLua live_grep<cr>", desc = "프로젝트 텍스트 검색" },
    { "<leader>fc", "<cmd>FzfLua grep_cword<cr>", desc = "커서 아래 단어 검색" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "열린 버퍼 목록" },
    { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "도움말 검색" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "단축키 검색" },
    { "<leader>fR", "<cmd>FzfLua resume<cr>", desc = "직전 검색 다시 열기" },
  },
}
