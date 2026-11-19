return {
  "stevearc/aerial.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = {
      default_direction = "right",
      placement = "edge",
      min_width = 30,
      max_width = { 50, 0.3 },
    },
    attach_mode = "global",
    filter_kind = false, -- 모든 심볼 종류 표시
    highlight_on_hover = true,
    autojump = false,
    show_guides = true,
    guides = {
      mid_item = "├─",
      last_item = "└─",
      nested_top = "│ ",
      whitespace = "  ",
    },
    on_attach = function(bufnr)
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "이전 심볼" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "다음 심볼" })
    end,
  },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Outline 토글" },
    { "<leader>O", "<cmd>AerialNavToggle<CR>", desc = "Outline 네비 토글" },
  },
}
