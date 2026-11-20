-- 개인 저장소는 SSH 별칭 github-ngo 로 push 한다. octo 도 같은 계정을 쓰도록
-- 현재 디렉터리의 origin 을 보고 gh 에 넘길 토큰을 고른다.
local PERSONAL_ACCOUNT = "SejuneOh"
local DEFAULT_ACCOUNT = "sejune-oh"
local PERSONAL_SSH_HOST = "github-ngo"

local token_cache = {}

local function account_for_cwd()
  local url = vim.fn.systemlist({ "git", "-C", vim.fn.getcwd(), "remote", "get-url", "origin" })[1] or ""
  local host, owner = url:match("^[^@]*@([^:]+):([^/]+)/")
  if not host then
    host, owner = url:match("^https?://([^/]+)/([^/]+)/")
  end
  if host == PERSONAL_SSH_HOST or owner == PERSONAL_ACCOUNT then
    return PERSONAL_ACCOUNT
  end
  return DEFAULT_ACCOUNT
end

local function token_for(account)
  if token_cache[account] == nil then
    local token = vim.fn.systemlist({ "gh", "auth", "token", "-u", account })[1]
    token_cache[account] = (vim.v.shell_error == 0 and token) or false
  end
  return token_cache[account] or nil
end

return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    picker = "fzf-lua",
    enable_builtin = true, -- 인자 없이 :Octo 를 실행하면 명령 목록을 띄움
    default_to_projects_v2 = true,
    ssh_aliases = { [PERSONAL_SSH_HOST] = "github.com" },
    gh_env = function()
      local token = token_for(account_for_cwd())
      return token and { GH_TOKEN = token } or {}
    end,
  },
  keys = {
    { "<leader>GG", "<cmd>Octo<cr>", desc = "Octo 명령 목록" },
    { "<leader>Gi", "<cmd>Octo issue list<cr>", desc = "이슈 목록" },
    { "<leader>Gc", "<cmd>Octo issue create<cr>", desc = "이슈 만들기" },
    { "<leader>Gm", "<cmd>Octo search is:open assignee:@me<cr>", desc = "나에게 할당된 열린 항목" },
    { "<leader>Gp", "<cmd>Octo pr list<cr>", desc = "PR 목록" },
    { "<leader>Gr", "<cmd>Octo review start<cr>", desc = "PR 리뷰 시작" },
  },
}
