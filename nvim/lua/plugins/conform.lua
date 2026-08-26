return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "isort", "black" },

        -- C#(cs)은 의도적으로 비워둠 — csharpier를 쓰지 않는다.
        --
        -- csharpier는 prettier류의 opinionated 포맷터라서 .editorconfig의
        -- csharp_* / dotnet_* 스타일 규칙을 읽지 않는다. 반면 Visual Studio와
        -- `dotnet format`은 Roslyn의 .editorconfig 기반 포맷을 쓴다.
        -- 두 결과가 달라서, 한 줄만 고쳐 저장해도 파일 전체가 재작성된다.
        --
        -- heurm.server 실측 (동일 파일, 550줄):
        --   csharpier   → 331줄 변경
        --   Roslyn LSP  →   0줄 변경  (48~74ms)
        --
        -- 따라서 cs는 formatters_by_ft에 등록하지 않고, 아래 lsp_format = "fallback"
        -- 경로로 Roslyn LS(roslyn.nvim)의 포맷을 그대로 사용한다.
      },
      format_on_save = {
        lsp_format = "fallback", -- conform 최신 API (구 lsp_fallback)
        async = false,
        -- Roslyn LS는 솔루션 로딩 중 응답이 늦을 수 있어 1000ms → 2000ms
        timeout_ms = 2000,
      },
    })

    -- 수동 포맷 단축키
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback", -- conform 최신 API (구 lsp_fallback)
        async = false,
        timeout_ms = 2000,
      })
    end, { desc = "파일/선택 영역 포맷" })
  end,
}
