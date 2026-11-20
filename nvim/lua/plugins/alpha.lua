return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- ASCII 아트 로고
    dashboard.section.header.val = {
      "                                                     ",
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
      "                                                     ",
    }

    -- 바로가기 버튼
    dashboard.section.buttons.val = {
      dashboard.button("f", "  파일 찾기", "<cmd>FzfLua files<CR>"),
      dashboard.button("r", "  최근 파일", "<cmd>FzfLua oldfiles<CR>"),
      dashboard.button("s", "  프로젝트 검색", "<cmd>FzfLua live_grep<CR>"),
      dashboard.button("n", "  새 파일", "<cmd>ene<CR>"),
      dashboard.button("c", "  설정 파일", "<cmd>edit ~/.config/nvim/init.lua<CR>"),
      dashboard.button("q", "  종료", "<cmd>qa<CR>"),
    }

    -- 푸터 문구
    dashboard.section.footer.val = "코딩은 현실을 재구성하는 가장 강력한 도구다"

    alpha.setup(dashboard.opts)

    -- lazy.nvim 로딩 완료 시 푸터에 플러그인 수 표시
    -- (LazyVimStarted는 LazyVim 디스트로 전용, 일반 lazy.nvim은 VeryLazy 사용)
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        local stats = require("lazy").stats()
        dashboard.section.footer.val = "  "
          .. stats.count
          .. " 개 플러그인 로드 · "
          .. (math.floor(stats.startuptime * 100) / 100)
          .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
