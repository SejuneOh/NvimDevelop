# Roadmap

Installation phases, in recommended order. Mirrors `SETUP.json`.

## Completed

- [x] **initial_installs** — WezTerm, Neovim 0.10+, git, ripgrep, node, Nerd Font
- [x] **config_file_structure** — `~/.config/nvim/` with `init.lua` + `lua/plugins/`
- [x] **plugin_manager** — `lazy.nvim` bootstrapped in `init.lua`
- [x] **ui_and_navigation** — catppuccin, nvim-tree, telescope, which-key, alpha, bufferline, lualine, dressing
- [x] **session_and_window_management** — auto-session, vim-maximizer
- [x] **syntax_and_editing_helpers** — treesitter, indent-blankline, autopairs, Comment, todo-comments, surround, substitute
- [x] **autocomplete_and_snippets** — nvim-cmp + cmp-{nvim-lsp,buffer,path,luasnip}, LuaSnip, friendly-snippets, lspkind
- [x] **lsp_setup** — mason, mason-lspconfig, mason-tool-installer, nvim-lspconfig
      - Installed LSP: lua_ls, ts_ls, pyright, html, cssls, jsonls
      - C#: roslyn.nvim (see "C# LSP (roslyn)" note below) — not omnisharp
- [x] **formatting** — conform.nvim
      - Formatters per filetype: stylua (lua), prettier (web), black+isort (python), csharpier (c#)
      - Format on save enabled (LSP fallback)
- [x] **diagnostics** — trouble.nvim
      - Unified panel for diagnostics, symbols, LSP refs/defs, TODO, quickfix
      - Keymap namespace: `<leader>x`
- [x] **linting** — nvim-lint
      - Linters per filetype: eslint_d (js/ts), pylint (python)
      - Runs on BufEnter / BufWritePost / InsertLeave
      - Manual trigger: `<leader>ml`
- [x] **git_integration** — gitsigns.nvim + lazygit.nvim
      - gitsigns: inline change markers, hunk stage/reset/preview, blame
      - lazygit: full terminal git UI via `<leader>gg`
      - External: lazygit binary installed at `~/.local/bin/lazygit`
- [x] **database_client** — vim-dadbod + vim-dadbod-ui + vim-dadbod-completion
      - Supports PostgreSQL (via `psql`) and MSSQL (via `sqlcmd`)
      - Sidebar for connection/table browsing + query execution + autocomplete
      - Setup details in `docs/DATABASE.md`

- [x] **basic_options** — `lua/config/options.lua`
      - Line numbers (absolute + relative), 2-space indent, clipboard sharing
      - Smart search (case-insensitive unless capital), cursorline, scrolloff=8
      - splitright / splitbelow, signcolumn always on, undofile for persistent undo
      - termguicolors, mouse enabled, updatetime=250, timeoutlen=500

- [x] **basic_keymaps** — `lua/config/keymaps.lua`
      - Leader key explicitly set to `\` in `init.lua` (before lazy.nvim)
      - `<Esc>` clear search highlight, `<C-s>` save, `<C-a>` select all
      - Visual indent stay (`<` / `>`), visual paste keep register
      - Window splits: `<leader>sv/sh/se/sx`

## Pending

_(no pending items)_

### Note: C# LSP (roslyn)

C# is served by **`roslyn.nvim`** (`seblyng/roslyn.nvim`, spec at
`nvim/lua/plugins/roslyn.lua`), not omnisharp. The Mason `roslyn` package
provides `Microsoft.CodeAnalysis.LanguageServer`.

> ⚠️ **Roslyn requires the .NET 10 runtime.** Roslyn LS v5.8+ targets
> `Microsoft.NETCore.App` 10.0. With only .NET 8 installed, the server crashes on
> startup (`exit code 150`, *"You must install or update .NET to run this
> application"*) and C# completion / hover / go-to-definition silently do not
> work — `nvim-cmp` and the plugin still load, so the breakage is easy to miss.

On a fresh machine, install the .NET 10 runtime (the SDK works too):

```bash
# macOS (arm64) — official runtime pkg lands in /usr/local/share/dotnet,
# which is where Roslyn's hostfxr looks. An existing .NET 8 SDK can stay.
#   download dotnet-runtime-<ver>-osx-arm64.pkg from https://dotnet.microsoft.com/download/dotnet/10.0
#   sudo installer -pkg dotnet-runtime-<ver>-osx-arm64.pkg -target /

# Ubuntu / WSL2
sudo apt install dotnet-runtime-10.0   # or dotnet-sdk-10.0

# Verify the runtime is visible, then restart Neovim and open a .cs file:
dotnet --list-runtimes | grep 10.0

# Mason installs the LS automatically; to (re)install manually:
:MasonInstall roslyn csharpier
```

Roslyn attaches best when a `.csproj` / `.sln` is present in the project root.

> ℹ️ `easy-dotnet.nvim` registers an `easy_dotnet` LSP whose `dotnet-easydotnet`
> companion binary is not installed by default. This logs a harmless
> `not executable` error in `:LspLog` / `~/.local/state/nvim/lsp.log` and is
> unrelated to C# completion.

## Deviations from Reference Tutorial

| Tutorial plugin | Replacement | Reason |
|-----------------|-------------|--------|
| `vim-tmux-navigator` | `smart-splits.nvim` | User runs WezTerm (not tmux). smart-splits unifies WezTerm panes with Neovim splits under one keymap. |

## Design Decisions

- **One plugin per file** — `lua/plugins/*.lua` each returns a `lazy.nvim` spec. Adding a plugin = creating a new file.
- **Global leader namespaces** — registered in `which-key.lua`:
  - `b` — buffer
  - `e` — explorer
  - `f` — find
  - `g` — git
  - `s` — split
  - `w` — window / session
- **Transparent background** — both WezTerm (`window_background_opacity = 0.92`) and catppuccin (`transparent_background = true`) so a single change affects the whole stack.
- **Primary language: C#** — when choosing LSP/formatter/linter for future work, include C# by default.
