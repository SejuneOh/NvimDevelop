-- 작업 디렉터리가 삭제되면 vim.uv.cwd() 가 nil 이 되고,
-- 상대 경로를 절대 경로로 바꾸는 vim.fs.abspath 가 assert 로 죽는다.
-- vim.filetype.match 를 쓰는 곳(render-markdown 의 코드블록 아이콘 등)이 모두 같이 죽으므로
-- 살아 있는 디렉터리로 옮겨 준다.

local M = {}

---@return string
local function fallback_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    local dir = vim.fs.dirname(name)
    if dir and vim.uv.fs_stat(dir) then
      return dir
    end
  end
  return vim.uv.os_homedir() or "/"
end

function M.ensure()
  if vim.uv.cwd() then
    return
  end

  local dir = fallback_dir()
  local scope = vim.fn.haslocaldir() -- 1: 창(lcd), 2: 탭(tcd), 0: 전역
  local ok, err = pcall(function()
    if scope == 1 then
      vim.cmd.lcd({ args = { dir } })
    elseif scope == 2 then
      vim.cmd.tcd({ args = { dir } })
    else
      vim.api.nvim_set_current_dir(dir)
    end
  end)

  if ok then
    vim.notify("작업 디렉터리가 사라져 " .. dir .. " 로 옮겼습니다.", vim.log.levels.WARN)
  else
    vim.notify("작업 디렉터리를 복구하지 못했습니다: " .. tostring(err), vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "FocusGained", "CursorHold" }, {
  group = vim.api.nvim_create_augroup("cwd_guard", { clear = true }),
  callback = M.ensure,
})

vim.api.nvim_create_user_command("CwdGuard", M.ensure, { desc = "사라진 작업 디렉터리를 복구한다" })

return M
