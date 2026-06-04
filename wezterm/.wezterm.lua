local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Plugins
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

-- Font
config.font = wezterm.font_with_fallback({
  "D2CodingLigature Nerd Font",
  "D2Coding",
  "Consolas",
  "Segoe UI Emoji",
  "Segoe UI Symbol",
})
config.font_size = 10.0

-- Color Theme
config.color_scheme = "Github Dark (Gogh)"

-- Background Opacity
config.window_background_opacity = 0.92

-- Default to WSL on Windows only; on macOS/Linux use the local login shell.
if wezterm.target_triple:find("windows") then
  config.default_domain = "WSL:Ubuntu"
end

-- Tab Bar
config.use_fancy_tab_bar = false

-- Window Padding
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Tabline
tabline.setup({
  options = {
    theme = "Github Dark (Gogh)",
  },
})

-- Smart Workspace Switcher
workspace_switcher.apply_to_config(config)

-- Keybindings
config.keys = {
  -- Workspace switcher (Alt+s)
  {
    key = "s",
    mods = "ALT",
    action = workspace_switcher.switch_workspace(),
  },
  -- Previous workspace (Alt+n)
  {
    key = "n",
    mods = "ALT",
    action = workspace_switcher.switch_to_prev_workspace(),
  },
  -- Copy (Ctrl+c): selection이 있으면 복사, 없으면 SIGINT 전달
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= "" then
        window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(wezterm.action.ClearSelection, pane)
      else
        window:perform_action(wezterm.action.SendString("\x03"), pane)
      end
    end),
  },
  -- Paste (Ctrl+v)
  {
    key = "v",
    mods = "CTRL",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
  -- Split pane horizontally — 좌/우 (Ctrl+Shift+d)
  {
    key = "d",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- Split pane vertically — 상/하 (Ctrl+Shift+D)
  {
    key = "D",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- Close current pane (Ctrl+Shift+w)
  {
    key = "w",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  -- Toggle pane zoom (Ctrl+Shift+z)
  {
    key = "z",
    mods = "CTRL|SHIFT",
    action = wezterm.action.TogglePaneZoomState,
  },
}

-- Smart Splits (Neovim integration)
smart_splits.apply_to_config(config)

return config
