return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "isort", "black" },
        cs = { "csharpier" },
      },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "cs" then
          return nil
        end
        return {
          lsp_format = "fallback", -- conform 최신 API (구 lsp_fallback)
          async = false,
          timeout_ms = 1000,
        }
      end,
    })

    -- 수동 포맷 단축키
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback", -- conform 최신 API (구 lsp_fallback)
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "파일/선택 영역 포맷" })
  end,
}
