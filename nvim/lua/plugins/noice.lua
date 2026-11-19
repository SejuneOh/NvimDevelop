return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        timeout = 1500, -- 1.5초 후 자동 사라짐
        max_width = 80,
        max_height = 20,
        background_colour = "#000000",
        render = "compact", -- 한 줄 축약 표시
        stages = "static", -- 애니메이션 없이 즉시 등장/사라짐
        top_down = true, -- 위→아래 순서로 쌓이며 우상단에 표시
        fps = 60,
      },
    },
  },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = { enabled = true },
      signature = { enabled = true },
      message = { enabled = true },
      progress = { enabled = true },
    },
    presets = {
      bottom_search = true, -- / 검색 하단 사용
      command_palette = true, -- : 명령창 가운데 표시
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = true,
    },
    routes = {
      -- 짧은 파일 저장 메시지 등은 미니 알림으로
      {
        filter = { event = "msg_show", kind = "", find = "written" },
        view = "mini",
      },
      -- 검색 결과 카운트 숨기기
      {
        filter = { event = "msg_show", kind = "search_count" },
        opts = { skip = true },
      },
    },
  },
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "알림 모두 닫기",
    },
    {
      "<leader>snl",
      function()
        require("noice").cmd("last")
      end,
      desc = "Noice: 마지막 메시지",
    },
    {
      "<leader>snh",
      function()
        require("noice").cmd("history")
      end,
      desc = "Noice: 히스토리",
    },
    {
      "<leader>sna",
      function()
        require("noice").cmd("all")
      end,
      desc = "Noice: 전체 메시지",
    },
    {
      "<leader>snd",
      function()
        require("noice").cmd("dismiss")
      end,
      desc = "Noice: 모두 닫기",
    },
  },
}
