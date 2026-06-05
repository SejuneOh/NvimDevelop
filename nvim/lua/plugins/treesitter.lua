return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- classic API (main branch was rewritten with breaking changes)
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    -- ── Path B: 마크다운 안의 bash 인젝션 비활성화 ─────────────────────
    -- nvim 0.12 + nvim-treesitter master 호환 이슈 우회.
    -- ```bash 블록의 인젝션이 query_predicates handler 에서 nil 노드를
    -- 처리하지 못해 spam 에러 발생. bash/sh/zsh/shell 만 인젝션에서 제외
    -- (lua, python, rust 등 다른 언어 코드블록은 정상 인젝션 유지).
    -- bash 블록은 일반 코드블록 색만 받음 — 셸 문법 색은 잃지만 에러 차단.
    local md_injections = [[
((fenced_code_block
  (info_string (language) @injection.language)
  (code_fence_content) @injection.content)
 (#not-any-of? @injection.language "bash" "sh" "shell" "zsh"))
]]
    pcall(vim.treesitter.query.set, "markdown", "injections", md_injections)

    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = true,
      ensure_installed = {
        "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
        "html", "css", "json", "yaml", "markdown", "markdown_inline",
        "bash", "python", "go", "rust", "c_sharp", "sql",
      },
    })
  end,
}
