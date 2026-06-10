return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- disable netrw (Neovim 기본 파일 탐색기)
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("nvim-tree").setup({
			filters = {
				dotfiles = false,
				git_ignored = false,
			},
			view = {
				width = 60,
				preserve_window_proportions = true,
			},
		})

		-- 키 바인딩
		vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "파일 탐색기 토글" })
		vim.keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFile<CR>",
			{ desc = "현재 파일 위치로 탐색기 열기" }
		)
		vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "폴더 모두 접기" })
		vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "탐색기 새로고침" })
	end,
}
