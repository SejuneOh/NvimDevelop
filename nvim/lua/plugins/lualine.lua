return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto", -- 현재 colorscheme 의 highlight 그룹에서 자동 추론
        globalstatus = true, -- 분할 창에도 하나의 상태바만 표시
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          -- github_dark 의 기본 branch fg 가 어두운 회색 → 가시성 ↑ 위해 GitHub 그린 + bold 로 덮어씀
          { "branch", icon = "", color = { fg = "#7ee787", gui = "bold" } },
          "diff",
          "diagnostics",
        },
        lualine_c = { { "filename", path = 1 } }, -- 상대경로 표시
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
