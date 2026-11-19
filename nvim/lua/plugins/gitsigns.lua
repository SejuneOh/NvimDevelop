return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local gitsigns = require("gitsigns")

    gitsigns.setup({
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- 이동
        map("n", "]h", gitsigns.next_hunk, "다음 hunk")
        map("n", "[h", gitsigns.prev_hunk, "이전 hunk")

        -- hunk 조작
        map("n", "<leader>gs", gitsigns.stage_hunk, "hunk 스테이지")
        map("n", "<leader>gr", gitsigns.reset_hunk, "hunk 리셋")
        map("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "선택 영역 스테이지")
        map("v", "<leader>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "선택 영역 리셋")
        map("n", "<leader>gS", gitsigns.stage_buffer, "버퍼 전체 스테이지")
        map("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", "스테이지 취소")
        map("n", "<leader>gR", gitsigns.reset_buffer, "버퍼 전체 리셋")

        -- 보기
        map("n", "<leader>gp", gitsigns.preview_hunk, "hunk 미리보기")
        map("n", "<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, "현재 줄 blame")
        map("n", "<leader>gd", gitsigns.diffthis, "diff 보기")
      end,
    })
  end,
}
