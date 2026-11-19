return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- UI 자동 토글
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- 사인 아이콘
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      ----------------------------------------------------------------------
      -- C# (coreclr) 어댑터
      ----------------------------------------------------------------------
      local netcoredbg_path = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
      dap.adapters.coreclr = {
        type = "executable",
        command = netcoredbg_path,
        args = { "--interpreter=vscode" },
      }

      ----------------------------------------------------------------------
      -- 헬퍼: .csproj 기반 DLL 자동 탐지
      ----------------------------------------------------------------------
      local function find_dll()
        -- 1) .csproj 파일 찾기
        local csproj = vim.fn.glob("**/*.csproj", false, true)[1]
        if not csproj then
          return vim.fn.input("DLL 경로: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end

        local proj_dir = vim.fn.fnamemodify(csproj, ":h")
        local proj_name = vim.fn.fnamemodify(csproj, ":t:r")

        -- 2) bin/Debug 아래 첫 번째 dll 찾기
        local dll_pattern = proj_dir .. "/bin/Debug/**/" .. proj_name .. ".dll"
        local candidates = vim.fn.glob(dll_pattern, false, true)

        if #candidates == 0 then
          vim.notify("DLL을 찾을 수 없습니다. dotnet build 실행하세요.", vim.log.levels.WARN)
          return vim.fn.input("DLL 경로: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end

        if #candidates == 1 then
          return candidates[1]
        end

        -- 여러 개면 coroutine으로 vim.ui.select 비동기 결과 받기
        -- (dap는 program 함수를 coroutine 컨텍스트에서 호출함)
        local co = coroutine.running()
        if not co then
          return candidates[1] -- coroutine 밖이면 안전 폴백
        end
        vim.ui.select(candidates, { prompt = "DLL 선택:" }, function(choice)
          coroutine.resume(co, choice or candidates[1])
        end)
        return coroutine.yield()
      end

      ----------------------------------------------------------------------
      -- C# 디버그 구성 (여러 시나리오)
      ----------------------------------------------------------------------
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch (.csproj 자동 탐지)",
          request = "launch",
          program = find_dll,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          env = { ASPNETCORE_ENVIRONMENT = "Development" },
        },
        {
          type = "coreclr",
          name = "Launch (DLL 경로 직접 입력)",
          request = "launch",
          program = function()
            return vim.fn.input("DLL 경로: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          type = "coreclr",
          name = "Attach to process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      ----------------------------------------------------------------------
      -- .vscode/launch.json 자동 로드 (있을 때)
      ----------------------------------------------------------------------
      local vscode = require("dap.ext.vscode")
      local launch_json = vim.fn.getcwd() .. "/.vscode/launch.json"
      if vim.fn.filereadable(launch_json) == 1 then
        vscode.load_launchjs(launch_json, {
          coreclr = { "cs", "fsharp", "vb" },
        })
      end

      -- 명령어: 언제든 launch.json 다시 로드
      vim.api.nvim_create_user_command("DapLoadLaunchJSON", function()
        require("dap.ext.vscode").load_launchjs(nil, {
          coreclr = { "cs", "fsharp", "vb" },
        })
        vim.notify("launch.json 다시 로드됨", vim.log.levels.INFO)
      end, {})

      ----------------------------------------------------------------------
      -- 키맵
      ----------------------------------------------------------------------
      local map = vim.keymap.set
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: 브레이크포인트" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("조건: "))
      end, { desc = "DAP: 조건 브레이크포인트" })
      map("n", "<leader>dc", dap.continue, { desc = "DAP: 시작/계속" })
      map("n", "<leader>do", dap.step_over, { desc = "DAP: Step Over" })
      map("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
      map("n", "<leader>dO", dap.step_out, { desc = "DAP: Step Out" })
      map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP: REPL" })
      map("n", "<leader>dl", dap.run_last, { desc = "DAP: 마지막 재실행" })
      map("n", "<leader>dt", dap.terminate, { desc = "DAP: 종료" })
      map("n", "<leader>du", dapui.toggle, { desc = "DAP: UI 토글" })
      map({ "n", "v" }, "<leader>de", function()
        require("dapui").eval()
      end, { desc = "DAP: 변수 평가" })
      map("n", "<leader>dL", "<cmd>DapLoadLaunchJSON<CR>", { desc = "DAP: launch.json 재로드" })
    end,
  },
}
