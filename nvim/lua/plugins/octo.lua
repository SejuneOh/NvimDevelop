return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    picker = "telescope",
    enable_builtin = true, -- 인자 없이 :Octo 를 실행하면 명령 목록을 띄움
    default_to_projects_v2 = true,
  },
  keys = {
    { "<leader>GG", "<cmd>Octo<cr>", desc = "Octo 명령 목록" },
    { "<leader>Gi", "<cmd>Octo issue list<cr>", desc = "이슈 목록" },
    { "<leader>Gc", "<cmd>Octo issue create<cr>", desc = "이슈 만들기" },
    { "<leader>Gm", "<cmd>Octo search is:open assignee:@me<cr>", desc = "나에게 할당된 열린 항목" },
    { "<leader>Gp", "<cmd>Octo pr list<cr>", desc = "PR 목록" },
    { "<leader>Gr", "<cmd>Octo review start<cr>", desc = "PR 리뷰 시작" },
  },
}
