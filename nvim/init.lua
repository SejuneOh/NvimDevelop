-- Leader key (lazy.nvim 로드 전에 설정해야 함)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Basic options
require("config.options")

-- Basic keymaps
require("config.keymaps")

-- 삭제된 작업 디렉터리 복구 (vim.fs.abspath assert 방지)
require("config.cwd_guard")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")
