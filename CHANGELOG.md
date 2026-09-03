# Changelog

## [0.3.0](https://github.com/SejuneOh/NvimDevelop/compare/v0.2.0...v0.3.0) (2026-09-03)


### Features

* **claude:** add per-section list mode and article tagging to obsidian skill ([09cbe41](https://github.com/SejuneOh/NvimDevelop/commit/09cbe4126cf1de6558bcdcfb5b0deeed285ffb0e))
* **claude:** add vault sync actions to obsidian skill ([0b2a0d9](https://github.com/SejuneOh/NvimDevelop/commit/0b2a0d90533d4ca365b09c2fff36336da0f85510)), closes [#24](https://github.com/SejuneOh/NvimDevelop/issues/24)
* **claude:** obsidian 스킬 기사 후보 태그를 article-candidate로 변경 ([7dcff78](https://github.com/SejuneOh/NvimDevelop/commit/7dcff781df05c60bc872229a12124729573f3f86))
* **claude:** obsidian 스킬 기사 후보 태그를 article-candidate로 변경 ([0b743e1](https://github.com/SejuneOh/NvimDevelop/commit/0b743e1e66ea41249e8857d90d57c10de600ddbd))
* **nvim:** always show gitignored entries in nvim-tree ([f47b8ac](https://github.com/SejuneOh/NvimDevelop/commit/f47b8ac6898a28b55f35803d62aa1a34ef7c4e47))
* **nvim:** Harpoon 슬롯에 별칭을 붙여 퀵 메뉴에 표시 ([41685d4](https://github.com/SejuneOh/NvimDevelop/commit/41685d4cfed15bbdb58e49ec49781a701a48c6ad))
* **nvim:** Harpoon 슬롯에 별칭을 붙여 퀵 메뉴에 표시 ([bd3977f](https://github.com/SejuneOh/NvimDevelop/commit/bd3977f705e7506f7da0b8800f4c428f3739349a)), closes [#39](https://github.com/SejuneOh/NvimDevelop/issues/39)
* **nvim:** HTML 파일 브라우저 미리보기 단축키 추가 ([4218bea](https://github.com/SejuneOh/NvimDevelop/commit/4218beab46b5443d6c44e9802c0e7194800a8774))
* **nvim:** HTML 파일 브라우저 미리보기 단축키 추가 ([6ea3381](https://github.com/SejuneOh/NvimDevelop/commit/6ea338122e2bcdfb8108bfa44fcc1c3c307d2f3c)), closes [#26](https://github.com/SejuneOh/NvimDevelop/issues/26)


### Bug Fixes

* **nvim:** C# 들여쓰기를 4칸으로 고정해 Visual Studio 포맷과 일치시킴 ([9872972](https://github.com/SejuneOh/NvimDevelop/commit/987297221525b4f5139a2908c8c7cc269d9bca75))
* **nvim:** C# 들여쓰기를 4칸으로 고정해 Visual Studio 포맷과 일치시킴 ([763a08c](https://github.com/SejuneOh/NvimDevelop/commit/763a08cc6491420fc94e2482b93cf0723f503401))
* **nvim:** C# 저장 포맷을 csharpier에서 Roslyn LSP로 전환 ([874073f](https://github.com/SejuneOh/NvimDevelop/commit/874073f9c4d4fb0756e90fb744a4915d8b85d3e2))
* **nvim:** C# 저장 포맷을 csharpier에서 Roslyn LSP로 전환 ([bf24f55](https://github.com/SejuneOh/NvimDevelop/commit/bf24f5581b700b7bb3babd4b7937a4c28e0ac770))
* **nvim:** easy-dotnet의 중복 Roslyn 서버를 비활성화 ([6cf9624](https://github.com/SejuneOh/NvimDevelop/commit/6cf9624d400fe1e44dd0a3b30b4732c5896724c0))
* **nvim:** easy-dotnet의 중복 Roslyn 서버를 비활성화해 C# 진단 오류를 해소 ([e61454a](https://github.com/SejuneOh/NvimDevelop/commit/e61454a299d3e8d7116da6bf936659b3ed2a9ce5))
* **nvim:** 미리보기 단축키가 파일 버퍼가 아니면 중단하도록 보강 ([6aee6ac](https://github.com/SejuneOh/NvimDevelop/commit/6aee6acf06a74a12af0d4b649a1b2b1053b98140))

## [0.2.0](https://github.com/SejuneOh/NvimDevelop/compare/v0.1.0...v0.2.0) (2026-06-05)


### Features

* **nvim:** add quality-of-life plugins and penumbra_dark theme ([ce25783](https://github.com/SejuneOh/NvimDevelop/commit/ce25783d60016754dca2023dce614121e72e6abc))
* **nvim:** add quality-of-life plugins and penumbra_dark theme ([17e7245](https://github.com/SejuneOh/NvimDevelop/commit/17e7245478f3c842ed86a74a89b14eb24f4fb6ca))
* **nvim:** avoid zellij keymap conflicts ([f07e999](https://github.com/SejuneOh/NvimDevelop/commit/f07e999eeb92da0fcf25a2549f0cefbbfc1f1ebf))
* **wsl:** print installed components at end of install ([10b8d08](https://github.com/SejuneOh/NvimDevelop/commit/10b8d0802674ec1369419a13cb2c0bcd2861c33e))
* **wsl:** print installed components at end of install ([0e6f01c](https://github.com/SejuneOh/NvimDevelop/commit/0e6f01c7d2d2d48415e1c9a63ffd456c2a846c48))


### Bug Fixes

* **nvim:** avoid zellij keymap conflicts (Alt+hjkl, Esc-Esc terminal) ([2eefc1d](https://github.com/SejuneOh/NvimDevelop/commit/2eefc1d35beb6b92ea26b06a8c68cc17db4786a7))
* **nvim:** make terminal Esc-Esc mapping global so :source applies it ([c630ae2](https://github.com/SejuneOh/NvimDevelop/commit/c630ae2a684766282f5999bd77f45280c356d044))
