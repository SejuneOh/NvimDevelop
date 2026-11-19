return {
  "nvim-neotest/neotest",
  ft = { "cs", "fsharp", "vb" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "Issafalcon/neotest-dotnet",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-dotnet")({
          dap = {
            adapter_name = "coreclr", -- nvim-dap의 어댑터와 일치
          },
          custom_attributes = {
            xunit = { "MyCustomFactAttribute" },
          },
          discovery_root = "solution", -- 솔루션 단위로 테스트 탐색
        }),
      },
      icons = {
        passed = "",
        running = "",
        failed = "",
        unknown = "",
      },
      output = {
        enabled = true,
        open_on_run = true,
      },
      summary = {
        enabled = true,
        animated = true,
      },
    })

    -- 키맵 (<leader>t = test 그룹)
    local nt = require("neotest")
    local map = vim.keymap.set
    map("n", "<leader>tt", function()
      nt.run.run()
    end, { desc = "Test: 가장 가까운 테스트" })
    map("n", "<leader>tf", function()
      nt.run.run(vim.fn.expand("%"))
    end, { desc = "Test: 파일 전체" })
    map("n", "<leader>ta", function()
      nt.run.run(vim.uv.cwd())
    end, { desc = "Test: 전체 (CWD)" })
    map("n", "<leader>tl", function()
      nt.run.run_last()
    end, { desc = "Test: 마지막 재실행" })
    map("n", "<leader>td", function()
      nt.run.run({ strategy = "dap" })
    end, { desc = "Test: 디버그 실행" })
    map("n", "<leader>ts", function()
      nt.summary.toggle()
    end, { desc = "Test: 요약 패널" })
    map("n", "<leader>to", function()
      nt.output.open({ enter = true, auto_close = true })
    end, { desc = "Test: 출력 패널" })
    map("n", "<leader>tO", function()
      nt.output_panel.toggle()
    end, { desc = "Test: 출력 패널 토글" })
    map("n", "<leader>tx", function()
      nt.run.stop()
    end, { desc = "Test: 중지" })
  end,
}
