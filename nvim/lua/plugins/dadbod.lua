return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      -- 연결 정보 저장 디렉토리
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/db_ui/tmp"
      vim.g.db_ui_execute_on_save = 0 -- 저장 시 자동 실행 끄기
    end,
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "DB UI 토글" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "DB 쿼리 버퍼 찾기" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "DB 연결 추가" },
    },
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    dependencies = { "tpope/vim-dadbod" },
    -- 자동완성 소스 등록은 blink-cmp.lua 의 sources.per_filetype 에 있다
  },
}
