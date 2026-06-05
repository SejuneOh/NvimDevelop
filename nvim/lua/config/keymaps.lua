local keymap = vim.keymap

-- 검색 하이라이트 해제
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "검색 하이라이트 해제" })

-- 파일 저장
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "파일 저장" })
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "파일 저장" })

-- 비주얼 모드에서 들여쓰기 유지
keymap.set("v", "<", "<gv", { desc = "들여쓰기 유지 (왼쪽)" })
keymap.set("v", ">", ">gv", { desc = "들여쓰기 유지 (오른쪽)" })

-- 비주얼 모드 붙여넣기 시 레지스터 유지
keymap.set("x", "p", [["_dP]], { desc = "붙여넣기 (레지스터 유지)" })

-- 전체 선택
keymap.set("n", "<C-a>", "ggVG", { desc = "전체 선택" })

-- 창 분할
keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "세로 분할" })
keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "가로 분할" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "분할 크기 균등화" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "현재 분할 닫기" })

-- 버퍼 닫기: 창 레이아웃을 유지한 채 현재 버퍼만 제거
-- 기본 `:bdelete` 는 해당 버퍼를 보여주던 창까지 같이 닫아 분할 레이아웃을 깨뜨림
local function smart_bdelete(force)
  local bufnr = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and b ~= bufnr
  end, vim.api.nvim_list_bufs())

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      local alt = vim.fn.bufnr("#")
      if alt ~= bufnr and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
        vim.api.nvim_win_set_buf(win, alt)
      elseif #listed > 0 then
        vim.api.nvim_win_set_buf(win, listed[1])
      else
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end
  end

  if vim.api.nvim_buf_is_valid(bufnr) then
    if vim.bo[bufnr].modified and not force then
      vim.notify("저장되지 않은 변경이 있습니다. <leader>bD 로 강제 닫기.", vim.log.levels.WARN)
      return
    end
    local ok, err = pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
    if not ok then
      vim.notify("버퍼 닫기 실패: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

keymap.set("n", "<leader>bd", function() smart_bdelete(false) end, { desc = "버퍼 닫기 (창 유지)" })
keymap.set("n", "<leader>bD", function() smart_bdelete(true) end, { desc = "버퍼 강제 닫기" })
keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "다른 버퍼 모두 닫기" })
keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", { desc = "왼쪽 버퍼 모두 닫기" })
keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", { desc = "오른쪽 버퍼 모두 닫기" })
