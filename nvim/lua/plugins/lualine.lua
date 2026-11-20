return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "onedark", -- onedark.nvim 이 제공하는 상태줄 색. 설정한 style(warm)을 따른다
        globalstatus = true, -- 분할 창에도 하나의 상태바만 표시
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icon = "" },
          "diff",
          "diagnostics",
        },
        lualine_c = { { "filename", path = 1 } }, -- 상대경로 표시
        lualine_x = {
          -- 인코딩·줄바꿈은 평소(utf-8, unix)와 다를 때만 보여 준다
          {
            "encoding",
            cond = function()
              local enc = vim.bo.fileencoding
              return enc ~= "" and enc ~= "utf-8"
            end,
          },
          {
            "fileformat",
            cond = function()
              return vim.bo.fileformat ~= "unix"
            end,
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
