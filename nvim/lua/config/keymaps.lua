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

-- 터미널 모드 탈출 단축키 (글로벌 terminal-mode 매핑)
-- 기본 <C-\><C-n> 의 <C-n> 이 zellij Resize mode 와 충돌하므로
-- <Esc><Esc> 두 번으로 terminal-job → terminal-normal 전환.
-- (셸 안에서 vim 을 다시 실행해도 단발 <Esc> 는 그대로 셸로 전달되어 안전)
--
-- 글로벌(non-buffer-local) 매핑이므로 모든 터미널 버퍼에 즉시 적용 —
-- TermOpen autocmd 방식과 달리 nvim 재시작이나 새 터미널 오픈 불필요.
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: normal mode" })

-- HTML 브라우저 미리보기 (WSL)
--
-- 내장 gx / vim.ui.open() 은 핸들러를 xdg-open → wslview → explorer.exe 순으로 찾는다.
-- 이 환경엔 xdg-open 이 설치돼 있어 항상 먼저 잡히는데, mimeinfo.cache 가 없어
-- "No applications found for mimetype: text/html" 로 실패한다. exit code 는 0 이라
-- nvim 쪽에선 조용히 아무 일도 안 일어난다. (wslu 를 깔아도 탐색 순서상 해결 안 됨)
-- 게다가 Windows 브라우저는 리눅스 경로를 못 읽으므로 wslpath -w 로 UNC 경로로 바꿔 넘긴다.
local function windows_browser()
  return os.getenv("BROWSER") or "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
end

-- 실제 디스크에 존재하는 파일일 때만 경로를 돌려준다.
-- NvimTree 같은 특수 버퍼는 "%:p" 가 NvimTree_1 처럼 파일 아닌 이름으로 잡히므로
-- 빈 문자열 검사만으로는 걸러지지 않는다.
local function current_real_file()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("저장되지 않은 버퍼입니다.", vim.log.levels.WARN)
    return nil
  end
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" then
    vim.notify("파일 버퍼가 아닙니다. HTML 파일을 연 창에서 실행하세요.", vim.log.levels.WARN)
    return nil
  end
  return path
end

-- 현재 파일을 브라우저로 열기 (file:// — 정적 HTML 용)
keymap.set("n", "<leader>pb", function()
  local file = current_real_file()
  if not file then
    return
  end
  local winpath = vim.trim(vim.fn.system({ "wslpath", "-w", file }))
  if vim.v.shell_error ~= 0 then
    vim.notify("wslpath 변환 실패: " .. winpath, vim.log.levels.ERROR)
    return
  end
  vim.system({ windows_browser(), winpath }, { detach = true })
  vim.notify("브라우저로 열기: " .. vim.fn.expand("%:t"))
end, { desc = "브라우저로 열기 (file://)" })

-- 로컬 서버로 미리보기
-- ES module / fetch 를 쓰는 페이지는 file:// 에서 origin 이 null 이라 CORS 로 막힌다.
-- 서버는 detach 로 떠서 nvim 을 종료해도 남아 있으므로 <leader>pk 로 정리한다.
local preview_port = 8000

keymap.set("n", "<leader>ps", function()
  if not current_real_file() then
    return
  end
  local dir, name = vim.fn.expand("%:p:h"), vim.fn.expand("%:t")
  -- 이전 서버가 다른 디렉터리를 서빙 중이면 엉뚱한 파일이 보이므로 먼저 정리
  vim.fn.system({ "pkill", "-f", "http.server " .. preview_port })
  vim.system({ "python3", "-m", "http.server", tostring(preview_port), "--directory", dir }, { detach = true })
  -- 서버가 포트를 잡기 전에 브라우저가 붙으면 연결 거부되므로 조금 기다린다
  vim.defer_fn(function()
    local url = ("http://localhost:%d/%s"):format(preview_port, name)
    vim.system({ windows_browser(), url }, { detach = true })
    vim.notify("로컬 서버 미리보기: " .. url)
  end, 300)
end, { desc = "로컬 서버로 미리보기" })

-- 미리보기 서버 종료
keymap.set("n", "<leader>pk", function()
  vim.fn.system({ "pkill", "-f", "http.server " .. preview_port })
  vim.notify(("미리보기 서버 종료 (포트 %d)"):format(preview_port))
end, { desc = "미리보기 서버 종료" })
