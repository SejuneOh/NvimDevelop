-- C# 들여쓰기: Visual Studio 기본값(공백 4칸)에 맞춘다.
--
-- 전역 설정은 shiftwidth/tabstop = 2 인데, .editorconfig가 없는 저장소에서는
-- Roslyn LS가 LSP 요청의 tabSize(= 이 버퍼의 shiftwidth)를 포맷 기준으로 쓴다.
-- 그래서 4칸으로 작성된 C# 코드가 저장할 때마다 2칸으로 재들여쓰기됐다.
-- (.editorconfig가 indent_size = 4 를 지정한 저장소는 그쪽이 우선이라 영향 없음)
--
-- C#/Visual Studio 관례가 4칸이므로 여기서 4로 고정한다.
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true
