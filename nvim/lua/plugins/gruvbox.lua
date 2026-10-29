return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      contrast = "hard",
      transparent_mode = true,
    })
    vim.o.background = "dark"
    vim.cmd("colorscheme gruvbox")
  end,
}
