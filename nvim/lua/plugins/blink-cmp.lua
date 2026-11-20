return {
  "saghen/blink.cmp",
  version = "1.*", -- 태그 버전이어야 Rust 퍼지 매처 바이너리를 내려받는다. v2 는 아직 개발 중
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = { "rafamadriz/friendly-snippets" }, -- 언어별 스니펫
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
  },
  opts = {
    keymap = {
      preset = "none",
      ["<C-k>"] = { "select_prev", "fallback" }, -- 이전 항목
      ["<C-j>"] = { "select_next", "fallback" }, -- 다음 항목
      ["<C-b>"] = { "scroll_documentation_up", "fallback" }, -- 문서 스크롤 위
      ["<C-f>"] = { "scroll_documentation_down", "fallback" }, -- 문서 스크롤 아래
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" }, -- 수동으로 팝업 열기
      ["<C-e>"] = { "hide", "fallback" }, -- 팝업 닫기
      ["<CR>"] = { "accept", "fallback" }, -- 고른 항목이 있을 때만 확정
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
    completion = {
      -- 첫 항목을 미리 고르지 않아야 <CR> 이 줄바꿈으로 동작한다
      list = { selection = { preselect = false, auto_insert = false } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      accept = { auto_brackets = { enabled = true } }, -- 함수 완성 뒤 괄호 자동 추가
    },
    snippets = { preset = "luasnip" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { "dadbod", "snippets", "buffer" },
        mysql = { "dadbod", "snippets", "buffer" },
        plsql = { "dadbod", "snippets", "buffer" },
      },
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      },
    },
    signature = { enabled = false }, -- 함수 인자 도움말은 noice 가 보여 준다
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
