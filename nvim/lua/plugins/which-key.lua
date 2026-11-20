return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({ win = { border = "rounded" } })

    -- 단축키 그룹 이름 등록
    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug (dap)" },
      { "<leader>D", group = "database (dadbod)" },
      { "<leader>i", group = "inlay hint" },
      { "<leader>k", desc = "현재 줄 진단 표시" },
      { "<leader>e", group = "explorer" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>G", group = "github (octo)" },
      { "<leader>a", group = "AI (Claude Code)" },
      { "<leader>h", group = "harpoon" },
      { "<leader>m", group = "misc (format)" },
      { "<leader>n", group = ".NET (dotnet)" },
      { "<leader>o", group = "outline" },
      { "<leader>p", group = "preview (browser)" },
      { "<leader>r", group = "refactor/rename" },
      { "<leader>s", group = "split/search" },
      { "<leader>sn", group = "noice messages" },
      { "<leader>t", group = "test" },
      { "<leader>T", group = "terminal" },
      { "<leader>u", group = "ui toggles" },
      { "<leader>w", group = "window/session" },
      { "<leader>x", group = "trouble" },
    })

    -- 숫자 키(하푼 1~4, 버퍼 5~9)는 외워 쓰는 키라 팝업 맨 앞을 차지하지 않게 숨긴다. \fk 검색에는 그대로 나온다.
    local digits = {}
    for i = 1, 9 do
      table.insert(digits, { "<leader>" .. i, hidden = true })
    end
    wk.add(digits)
  end,
}
