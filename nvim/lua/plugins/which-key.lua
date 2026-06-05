return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({})

    -- 단축키 그룹 이름 등록
    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "database/debug" },
      { "<leader>k", desc = "현재 줄 진단 표시" },
      { "<leader>e", group = "explorer" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "harpoon" },
      { "<leader>m", group = "misc (format)" },
      { "<leader>n", group = ".NET (dotnet)" },
      { "<leader>o", group = "outline" },
      { "<leader>r", group = "refactor/rename" },
      { "<leader>s", group = "split/search" },
      { "<leader>sn", group = "noice messages" },
      { "<leader>t", group = "test" },
      { "<leader>T", group = "terminal" },
      { "<leader>u", group = "ui toggles" },
      { "<leader>w", group = "window/session" },
      { "<leader>x", group = "trouble" },
    })
  end,
}
