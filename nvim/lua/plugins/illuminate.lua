-- LSP / treesitter 기반으로 커서 아래 변수와 동일한 변수를 자동 강조
return {
  "RRethy/vim-illuminate",
  event = "BufReadPost",
  config = function()
    require("illuminate").configure({
      delay = 200,
      -- nvim 0.12 + nvim-treesitter master 호환 이슈 (locals.lua:parent nil) 회피.
      -- LSP 있는 파일은 LSP 가, 없으면 regex 가 처리 — 체감 차이 거의 없음.
      providers = { "lsp", "regex" },
      filetypes_denylist = {
        "NvimTree",
        "TelescopePrompt",
        "alpha",
        "dashboard",
        "lazy",
        "mason",
        "noice",
        "notify",
        "qf",
        "DressingInput",
        "DressingSelect",
        "trouble",
        "neo-tree",
      },
      under_cursor = true,
    })
  end,
}
