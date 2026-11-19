return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("todo-comments").setup()

    -- 키 바인딩
    local keymap = vim.keymap.set
    keymap("n", "]t", function()
      require("todo-comments").jump_next()
    end, { desc = "다음 TODO" })
    keymap("n", "[t", function()
      require("todo-comments").jump_prev()
    end, { desc = "이전 TODO" })
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "TODO 목록 검색" })
  end,
}
