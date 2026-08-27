return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    local FORMAT_OPTS = {
      lsp_format = "fallback", -- conform 최신 API (구 lsp_fallback)
      async = false,
      -- Roslyn LS는 솔루션 로딩 중 응답이 늦을 수 있어 여유를 둔다
      timeout_ms = 2000,
    }

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

        -- C#(cs)은 포맷터를 등록하지 않는다.
        -- 아래 lsp_format = "fallback" 경로로 Roslyn LS(= Visual Studio와 같은
        -- 포맷 엔진)의 결과를 그대로 쓴다.
        --
        -- csharpier는 쓰지 않는다. .editorconfig의 csharp_* / dotnet_* 규칙을
        -- 읽지 않아 Visual Studio 포맷과 어긋나고, 한 줄만 고쳐도 파일 전체가
        -- 재작성된다 (550줄 파일 실측: csharpier 165줄 변경 / Roslyn 0줄).
        --
        -- 들여쓰기 폭은 ftplugin/cs.lua 에서 4칸으로 고정한다. .editorconfig가
        -- 없는 저장소에서는 Roslyn이 LSP 요청의 tabSize(버퍼 shiftwidth)를
        -- 포맷 기준으로 쓰기 때문에, 전역값 2칸이 새어 들어가면 4칸으로 쓰인
        -- 코드가 전부 재들여쓰기된다.
      },

      format_on_save = FORMAT_OPTS,
    })

    -- 수동 포맷: 파일 전체 또는 선택 영역
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format(FORMAT_OPTS)
    end, { desc = "파일/선택 영역 포맷" })
  end,
}
