return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "Dotnet", "DotnetRunProfile" },
  keys = {
    { "<leader>nr", "<cmd>DotnetRunProfile<CR>",  desc = ".NET: 실행 (프로필 선택)" },
    { "<leader>nt", "<cmd>Dotnet testrunner<CR>", desc = ".NET: 테스트 러너" },
    { "<leader>nb", "<cmd>Dotnet build<CR>",      desc = ".NET: 빌드" },
    { "<leader>nR", "<cmd>Dotnet restore<CR>",    desc = ".NET: restore" },
    { "<leader>nc", "<cmd>Dotnet clean<CR>",      desc = ".NET: clean" },
    { "<leader>ns", "<cmd>Dotnet secrets<CR>",    desc = ".NET: user secrets" },
    { "<leader>nn", "<cmd>Dotnet new<CR>",        desc = ".NET: 새 프로젝트" },
  },
  config = function()
    require("easy-dotnet").setup({
      -- C# LSP는 roslyn.nvim이 단독 담당. 이 값을 켜면 Roslyn 서버가 중복 실행된다.
      lsp = { enabled = false },
      projx_lsp = { enabled = false },
      managed_terminal = {
        auto_hide = false,
        auto_hide_delay = 5000,
      },
      test_runner = {
        viewmode = "split",
        enable_buffer_test_execution = true,
        noBuild = true,
        noRestore = true,
        icons = {
          passed = "",
          failed = "",
          not_run = "",
          test = "",
          dir = "",
          package = "",
        },
      },
      new = {
        project = { prefix = "sln" },
      },
      terminal = function(path, action, args)
        args = args or "" -- nil 보호: string.format이 "nil" 문자열을 셸에 삽입하는 것 방지
        local commands = {
          run     = function() return string.format("dotnet run --project %s %s", path, args) end,
          test    = function() return string.format("dotnet test %s %s", path, args) end,
          restore = function() return string.format("dotnet restore %s %s", path, args) end,
          build   = function() return string.format("dotnet build %s %s", path, args) end,
        }
        local command = commands[action]() .. "\r"
        vim.cmd("botright split | term " .. command)
      end,
    })

    ----------------------------------------------------------------------
    -- :DotnetRunProfile — launchSettings.json의 프로필을 골라 실행
    ----------------------------------------------------------------------
    local function run_with_profile()
      local settings_files = vim.fn.glob("**/Properties/launchSettings.json", false, true)

      if #settings_files == 0 then
        vim.notify("launchSettings.json 없음 — 기본 실행으로 진행", vim.log.levels.INFO)
        vim.cmd("Dotnet run")
        return
      end

      local function pick_profile(settings_file)
        local ok, json = pcall(function()
          return vim.fn.json_decode(table.concat(vim.fn.readfile(settings_file), "\n"))
        end)

        if not ok or not json or not json.profiles then
          vim.notify("launchSettings.json 파싱 실패", vim.log.levels.ERROR)
          return
        end

        local profiles = {}
        for name, _ in pairs(json.profiles) do
          table.insert(profiles, name)
        end
        table.sort(profiles)

        if #profiles == 0 then
          vim.notify("프로필이 비어있음", vim.log.levels.WARN)
          return
        end

        -- proj_dir: .../<Project>/Properties/launchSettings.json → .../<Project>
        local proj_dir = vim.fn.fnamemodify(settings_file, ":h:h")
        local proj_name = vim.fn.fnamemodify(proj_dir, ":t")

        vim.ui.select(profiles, {
          prompt = "Launch profile (" .. proj_name .. "):",
        }, function(choice)
          if not choice then
            vim.notify("취소됨", vim.log.levels.INFO)
            return
          end
          local cmd = string.format(
            "dotnet run --project %s --launch-profile %s",
            vim.fn.shellescape(proj_dir),
            vim.fn.shellescape(choice)
          )
          vim.cmd("botright split | term " .. cmd)
        end)
      end

      if #settings_files == 1 then
        pick_profile(settings_files[1])
      else
        vim.ui.select(settings_files, {
          prompt = "프로젝트 선택:",
          format_item = function(item)
            return vim.fn.fnamemodify(item, ":h:h:t") -- 프로젝트 폴더명만
          end,
        }, function(choice)
          if not choice then return end
          pick_profile(choice)
        end)
      end
    end

    vim.api.nvim_create_user_command("DotnetRunProfile", run_with_profile, {
      desc = ".NET: launchSettings 프로필 선택 후 실행",
    })
  end,
}
