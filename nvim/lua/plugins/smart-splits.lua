return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    local smart_splits = require("smart-splits")
    smart_splits.setup({
      at_edge = "stop",
    })

    -- Moving between splits (Ctrl + hjkl)
    vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left)
    vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down)
    vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up)
    vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right)

    -- Resizing splits (Alt + hjkl)
    vim.keymap.set("n", "<A-h>", smart_splits.resize_left)
    vim.keymap.set("n", "<A-j>", smart_splits.resize_down)
    vim.keymap.set("n", "<A-k>", smart_splits.resize_up)
    vim.keymap.set("n", "<A-l>", smart_splits.resize_right)

    -- Terminal mode: 터미널/lazygit 등에서도 같은 단축키로 분할 이동
    vim.keymap.set("t", "<C-h>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_left()<CR>")
    vim.keymap.set("t", "<C-j>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_down()<CR>")
    vim.keymap.set("t", "<C-k>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_up()<CR>")
    vim.keymap.set("t", "<C-l>", [[<C-\><C-n>]] .. ":lua require('smart-splits').move_cursor_right()<CR>")
  end,
}
