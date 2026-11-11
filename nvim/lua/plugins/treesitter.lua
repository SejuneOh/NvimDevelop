-- main 브랜치는 파서 설치만 맡는다. 하이라이트·들여쓰기는 FileType 마다 직접 켠다.
-- 파서 빌드에 tree-sitter CLI(0.26.1+)와 C 컴파일러가 필요하다.
local ensure_installed = {
  "lua",
  "vim",
  "vimdoc",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "json",
  "yaml",
  "markdown",
  "markdown_inline",
  "bash",
  "python",
  "go",
  "rust",
  "c_sharp",
  "sql",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main 브랜치는 지연 로딩을 지원하지 않는다
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    -- WSL 에서 CLI 가 없으면 executable() 이 /mnt/c 폴더를 모두 뒤져 느리므로, 설치할 파서가 있을 때만 확인한다
    local has_cli
    local function can_build()
      if has_cli == nil then
        has_cli = vim.fn.executable("tree-sitter") == 1
        if not has_cli then
          vim.notify(
            "tree-sitter CLI 가 없어 파서를 설치하지 않습니다. installer/common/install-nvim-env.sh 를 참고해 설치하세요.",
            vim.log.levels.WARN
          )
        end
      end
      return has_cli
    end

    local installed = ts.get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure_installed)
    if #missing > 0 and can_build() then
      ts.install(missing)
    end

    local function attach(buf, lang)
      if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
        return
      end
      -- indents 쿼리가 없는 언어에서 indentexpr 는 모든 줄을 0칸으로 만든다
      if vim.treesitter.query.get(lang, "indents") then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    local available
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end
        if vim.treesitter.language.add(lang) then
          attach(args.buf, lang)
          return
        end

        -- 처음 여는 언어는 파서를 받아 설치한 뒤 켠다
        available = available or ts.get_available()
        if vim.tbl_contains(available, lang) and can_build() then
          ts.install(lang):await(function(err)
            if not err then
              vim.schedule(function()
                attach(args.buf, lang)
              end)
            end
          end)
        end
      end,
    })
  end,
}
