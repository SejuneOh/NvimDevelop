return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- 진단(Diagnostic) 설정: 사인 컬럼 아이콘 + 플로팅 창
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
      virtual_text = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- 모든 LSP에 공통 적용되는 기본 설정 (capabilities)
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- LSP 서버 활성화
    -- 서버별 커스텀 설정은 ~/.config/nvim/lsp/<server>.lua 에서 자동 로드됨
    vim.lsp.enable({
      "ts_ls",
      "pyright",
      "html",
      "cssls",
      "jsonls",
      "yamlls",
      "lua_ls",
      "bashls",
      "dockerls",
      "marksman",
      "taplo",
      -- C#은 roslyn.nvim 플러그인이 직접 LSP를 관리하므로 여기서 제외
    })

    -- LSP 클라이언트가 버퍼에 attach될 때 키맵 등록
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        local keymap = vim.keymap.set
        local opts = { buffer = args.buf, silent = true }

        -- 서버가 해당 메서드를 지원할 때만 키맵 등록
        local function map_if(method, mode, lhs, rhs, desc)
          if client:supports_method(method) then
            keymap(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
          end
        end

        -- LSP 메서드 기반 키맵 (capability 체크)
        map_if("textDocument/references", "n", "gR", "<cmd>Telescope lsp_references<CR>", "LSP: 참조 보기")
        map_if("textDocument/definition", "n", "gd", "<cmd>Telescope lsp_definitions<CR>", "LSP: 정의로 이동")
        map_if("textDocument/declaration", "n", "gD", vim.lsp.buf.declaration, "LSP: 선언으로 이동")
        map_if(
          "textDocument/implementation",
          "n",
          "gi",
          "<cmd>Telescope lsp_implementations<CR>",
          "LSP: 구현으로 이동"
        )
        map_if(
          "textDocument/typeDefinition",
          "n",
          "gt",
          "<cmd>Telescope lsp_type_definitions<CR>",
          "LSP: 타입 정의로 이동"
        )
        map_if("textDocument/codeAction", { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: 코드 액션")
        map_if("textDocument/rename", "n", "<leader>rn", vim.lsp.buf.rename, "LSP: 이름 변경")
        map_if("textDocument/hover", "n", "K", vim.lsp.buf.hover, "LSP: 호버 문서")

        -- 진단(Diagnostic) 키맵: LSP 메서드와 무관, 항상 등록
        -- 단독 <leader>d/<leader>D는 DAP/dadbod prefix와 충돌하므로 다른 키로 이동
        opts.desc = "LSP: 버퍼 진단 목록"
        keymap("n", "<leader>xD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "LSP: 현재 줄 진단 표시"
        keymap("n", "<leader>k", vim.diagnostic.open_float, opts)

        opts.desc = "LSP: 이전 진단"
        keymap("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, opts)

        opts.desc = "LSP: 다음 진단"
        keymap("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, opts)

        -- LSP 컨트롤 명령 (capability 무관)
        opts.desc = "LSP: 재시작"
        keymap("n", "<leader>rs", ":LspRestart<CR>", opts)

        -- Inlay hints: 변수 타입/매개변수명 인라인 표시 (서버 지원 시)
        if client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          opts.desc = "LSP: Inlay hints 토글"
          keymap("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
          end, opts)
        end

        -- Document highlight: 커서 둔 심볼 자동 하이라이트 (서버 지원 시)
        if client:supports_method("textDocument/documentHighlight") then
          local hl_group = vim.api.nvim_create_augroup("user_lsp_doc_highlight_" .. args.buf, { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = hl_group,
            buffer = args.buf,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
            group = hl_group,
            buffer = args.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })
  end,
}
