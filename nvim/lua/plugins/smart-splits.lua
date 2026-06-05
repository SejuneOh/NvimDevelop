return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    local smart_splits = require("smart-splits")
    smart_splits.setup({
      at_edge = "stop",
    })

    -- Moving between splits (Alt + hjkl)
    -- Ctrl + hjkl 은 zellij / tmux 멀티플렉서와 충돌하므로 Alt 로 통일
    vim.keymap.set("n", "<A-h>", smart_splits.move_cursor_left,  { desc = "Window: 왼쪽" })
    vim.keymap.set("n", "<A-j>", smart_splits.move_cursor_down,  { desc = "Window: 아래" })
    vim.keymap.set("n", "<A-k>", smart_splits.move_cursor_up,    { desc = "Window: 위" })
    vim.keymap.set("n", "<A-l>", smart_splits.move_cursor_right, { desc = "Window: 오른쪽" })

    -- Resizing splits (Alt + 화살표)
    -- Alt + hjkl 이 이동으로 이전됨에 따라 리사이즈는 Alt + 방향키로 분리
    vim.keymap.set("n", "<A-Left>",  smart_splits.resize_left,  { desc = "Resize: 왼쪽" })
    vim.keymap.set("n", "<A-Down>",  smart_splits.resize_down,  { desc = "Resize: 아래" })
    vim.keymap.set("n", "<A-Up>",    smart_splits.resize_up,    { desc = "Resize: 위" })
    vim.keymap.set("n", "<A-Right>", smart_splits.resize_right, { desc = "Resize: 오른쪽" })

    -- Terminal mode: 터미널/lazygit 등에서도 같은 단축키로 분할 이동
    vim.keymap.set("t", "<A-h>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_left()<CR>")
    vim.keymap.set("t", "<A-j>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_down()<CR>")
    vim.keymap.set("t", "<A-k>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_up()<CR>")
    vim.keymap.set("t", "<A-l>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_right()<CR>")
  end,
}
