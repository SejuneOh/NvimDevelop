-- penumbra_dark — NvChad base46 테마 팔레트 포팅 (자립형 colorscheme)
-- Palette: https://github.com/NvChad/base46/blob/master/lua/base46/themes/penumbra_dark.lua
-- Origin:  https://github.com/nealmckee/penumbra
--
-- 사용:
--   :colorscheme penumbra_dark
--
-- 투명 배경 원하면 colorscheme 명령 전에:
--   vim.g.penumbra_transparent = true

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.opt.termguicolors = true
vim.g.colors_name = "penumbra_dark"

local c = {
  -- base_30 (NvChad 확장 팔레트)
  white         = "#FFFDFB",
  darker_black  = "#2b2e33",
  black         = "#303338",
  black2        = "#3a3d42",
  one_bg        = "#3d4045",
  one_bg2       = "#484b50",
  one_bg3       = "#515459",
  grey          = "#5c5f64",
  grey_fg       = "#676a6f",
  grey_fg2      = "#72757a",
  light_grey    = "#7d8085",
  red           = "#CA7081",
  baby_pink     = "#E18163",
  pink          = "#D07EBA",
  green         = "#4EB67F",
  vibrant_green = "#50B584",
  nord_blue     = "#6e8dd5",
  blue          = "#8C96EC",
  yellow        = "#c1ad4b",
  sun           = "#9CA748",
  purple        = "#ac78bd",
  orange        = "#CE9042",
  teal          = "#00a6c8",
  cyan          = "#00B3C2",
  line          = "#3E4044",
  statusline_bg = "#34373c",
  pmenu_bg      = "#4EB67F",
  folder_bg     = "#8C96EC",
  -- base_16 (표준 base16 슬롯)
  base00 = "#303338", base01 = "#3a3d42", base02 = "#3d4045", base03 = "#484b50",
  base04 = "#515459", base05 = "#CECECE", base06 = "#F2E6D4", base07 = "#FFF7ED",
  base08 = "#999999", base09 = "#BE85D1", base0A = "#CA7081", base0B = "#4ec093",
  base0C = "#D68B47", base0D = "#7A9BEC", base0E = "#BE85D1", base0F = "#A1A641",
}

local transparent = vim.g.penumbra_transparent == true
local bg = transparent and "NONE" or c.base00
local function hl(g, o) vim.api.nvim_set_hl(0, g, o) end

-- ── Editor UI ─────────────────────────────────────────────────────────────
hl("Normal",         { fg = c.base05, bg = bg })
hl("NormalNC",       { fg = c.base05, bg = bg })
hl("NormalFloat",    { fg = c.base05, bg = transparent and "NONE" or c.base01 })
hl("FloatBorder",    { fg = c.grey, bg = transparent and "NONE" or c.base01 })
hl("EndOfBuffer",    { fg = c.base00, bg = bg })
hl("LineNr",         { fg = c.grey })
hl("CursorLineNr",   { fg = c.white, bold = true })
hl("CursorLine",     { bg = c.one_bg })
hl("CursorColumn",   { bg = c.one_bg })
hl("ColorColumn",    { bg = c.one_bg })
hl("SignColumn",     { bg = bg })
hl("Folded",         { fg = c.grey_fg, bg = c.line })
hl("FoldColumn",     { fg = c.grey, bg = bg })
hl("VertSplit",      { fg = c.line })
hl("WinSeparator",   { fg = c.line })
hl("Visual",         { bg = c.base03 })
hl("Search",         { fg = c.base00, bg = c.base0A })
hl("IncSearch",      { fg = c.base00, bg = c.base09 })
hl("CurSearch",      { fg = c.base00, bg = c.base09 })
hl("MatchParen",     { fg = c.base0A, bold = true, underline = true })
hl("Whitespace",     { fg = c.base03 })
hl("NonText",        { fg = c.base03 })
hl("Conceal",        { fg = c.base04 })
hl("Directory",      { fg = c.folder_bg })
hl("Cursor",         { fg = c.base00, bg = c.base05 })

-- ── Status / Tab / Pmenu ──────────────────────────────────────────────────
hl("StatusLine",     { fg = c.base05, bg = c.statusline_bg })
hl("StatusLineNC",   { fg = c.grey, bg = c.statusline_bg })
hl("TabLine",        { fg = c.grey, bg = c.base01 })
hl("TabLineSel",     { fg = c.base05, bg = c.base02 })
hl("TabLineFill",    { fg = c.grey, bg = c.base01 })
hl("Pmenu",          { fg = c.base05, bg = c.base01 })
hl("PmenuSel",       { fg = c.base00, bg = c.pmenu_bg, bold = true })
hl("PmenuSbar",      { bg = c.base02 })
hl("PmenuThumb",     { bg = c.base04 })

-- ── Messages ──────────────────────────────────────────────────────────────
hl("ErrorMsg",   { fg = c.red })
hl("WarningMsg", { fg = c.yellow })
hl("MoreMsg",    { fg = c.green })
hl("Question",   { fg = c.green })
hl("ModeMsg",    { fg = c.base05 })
hl("Title",      { fg = c.base0D, bold = true })

-- ── Legacy Syntax ─────────────────────────────────────────────────────────
hl("Comment",      { fg = c.grey_fg, italic = true })
hl("Constant",     { fg = c.red })             -- polish_hl override
hl("String",       { fg = c.base0B })
hl("Character",    { fg = c.base0B })
hl("Number",       { fg = c.base09 })
hl("Boolean",      { fg = c.base09 })
hl("Float",        { fg = c.base09 })
hl("Identifier",   { fg = c.base08 })
hl("Function",     { fg = c.base0D })
hl("Statement",    { fg = c.base0E })
hl("Conditional",  { fg = c.base0E })
hl("Repeat",       { fg = c.base0E })
hl("Label",        { fg = c.base0A })
hl("Operator",     { fg = c.cyan })            -- polish_hl override
hl("Keyword",      { fg = c.base0E })
hl("Exception",    { fg = c.base0E })
hl("PreProc",      { fg = c.base0A })
hl("Include",      { fg = c.base0D })
hl("Define",       { fg = c.base0E })
hl("Macro",        { fg = c.base0E })
hl("PreCondit",    { fg = c.base0A })
hl("Type",         { fg = c.base0A })
hl("StorageClass", { fg = c.base0A })
hl("Structure",    { fg = c.base0E })
hl("Typedef",      { fg = c.base0A })
hl("Special",      { fg = c.base0C })
hl("SpecialChar",  { fg = c.base0F })
hl("Tag",          { fg = c.base0A })
hl("Delimiter",    { fg = c.base05 })
hl("Error",        { fg = c.red })
hl("Todo",         { fg = c.base00, bg = c.base0A, bold = true })

-- ── Diff ──────────────────────────────────────────────────────────────────
hl("DiffAdd",     { fg = c.green,  bg = c.one_bg })
hl("DiffChange",  { fg = c.yellow, bg = c.one_bg })
hl("DiffDelete",  { fg = c.red,    bg = c.one_bg })
hl("DiffText",    { fg = c.blue,   bg = c.one_bg2 })
hl("DiffAdded",   { fg = c.green })
hl("DiffRemoved", { fg = c.red })

-- ── Diagnostics ───────────────────────────────────────────────────────────
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn",  { fg = c.yellow })
hl("DiagnosticInfo",  { fg = c.blue })
hl("DiagnosticHint",  { fg = c.cyan })
hl("DiagnosticOk",    { fg = c.green })
hl("DiagnosticUnderlineError", { sp = c.red,    undercurl = true })
hl("DiagnosticUnderlineWarn",  { sp = c.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo",  { sp = c.blue,   undercurl = true })
hl("DiagnosticUnderlineHint",  { sp = c.cyan,   undercurl = true })
hl("DiagnosticVirtualTextError", { fg = c.red,    bg = c.one_bg })
hl("DiagnosticVirtualTextWarn",  { fg = c.yellow, bg = c.one_bg })
hl("DiagnosticVirtualTextInfo",  { fg = c.blue,   bg = c.one_bg })
hl("DiagnosticVirtualTextHint",  { fg = c.cyan,   bg = c.one_bg })

-- ── LSP ───────────────────────────────────────────────────────────────────
hl("LspReferenceText",  { bg = c.one_bg2 })
hl("LspReferenceRead",  { bg = c.one_bg2 })
hl("LspReferenceWrite", { bg = c.one_bg2 })
hl("LspSignatureActiveParameter", { fg = c.base0A, bold = true })

-- ── Treesitter (polish_hl 반영) ───────────────────────────────────────────
hl("@variable",            { fg = c.base08 })
hl("@variable.builtin",    { fg = c.red })
hl("@variable.parameter",  { fg = c.orange })  -- polish_hl
hl("@variable.member",     { fg = c.base08 })
hl("@variable.member.key", { fg = c.red })     -- polish_hl
hl("@constant",            { fg = c.red })
hl("@constant.builtin",    { fg = c.base09 })
hl("@constant.macro",      { fg = c.base09 })
hl("@string",              { fg = c.base0B })
hl("@string.escape",       { fg = c.base0F })
hl("@string.special",      { fg = c.base0C })
hl("@number",              { fg = c.base09 })
hl("@boolean",             { fg = c.base09 })
hl("@function",            { fg = c.base0D })
hl("@function.builtin",    { fg = c.base0D })
hl("@function.call",       { fg = c.base0D })
hl("@function.method",     { fg = c.base0D })
hl("@function.macro",      { fg = c.base0E })
hl("@constructor",         { fg = c.orange })  -- polish_hl
hl("@keyword",             { fg = c.base0E })
hl("@keyword.function",    { fg = c.base0E })
hl("@keyword.return",      { fg = c.base0E })
hl("@operator",            { fg = c.cyan })    -- polish_hl
hl("@punctuation.delimiter", { fg = c.base05 })
hl("@punctuation.bracket", { fg = c.base08 })  -- polish_hl
hl("@punctuation.special", { fg = c.base0C })
hl("@comment",             { fg = c.grey_fg, italic = true })
hl("@type",                { fg = c.base0A })
hl("@type.builtin",        { fg = c.base0A })
hl("@attribute",           { fg = c.base0A })
hl("@annotation",          { fg = c.base0F })
hl("@namespace",           { fg = c.base0A })
hl("@module",              { fg = c.base0A })
hl("@property",            { fg = c.base08 })
hl("@field",               { fg = c.base08 })
hl("@tag",                 { fg = c.base0A })
hl("@tag.delimiter",       { fg = c.base08 })  -- polish_hl
hl("@tag.attribute",       { link = "@annotation" })  -- polish_hl
hl("@markup.heading",      { fg = c.base0D, bold = true })
hl("@markup.link",         { fg = c.base0C, underline = true })
hl("@markup.italic",       { italic = true })
hl("@markup.strong",       { bold = true })
hl("@markup.list",         { fg = c.base09 })
hl("@markup.quote",        { fg = c.grey_fg, italic = true })
hl("@markup.raw",          { fg = c.base0B })

-- ── Git / nvim-tree / Telescope ───────────────────────────────────────────
hl("GitSignsAdd",      { fg = c.green })
hl("GitSignsChange",   { fg = c.yellow })
hl("GitSignsDelete",   { fg = c.red })

hl("NvimTreeNormal",         { fg = c.base05, bg = transparent and "NONE" or c.darker_black })
hl("NvimTreeNormalNC",       { fg = c.base05, bg = transparent and "NONE" or c.darker_black })
hl("NvimTreeFolderIcon",     { fg = c.folder_bg })
hl("NvimTreeFolderName",     { fg = c.folder_bg })
hl("NvimTreeOpenedFolderName", { fg = c.folder_bg, bold = true })
hl("NvimTreeRootFolder",     { fg = c.red, bold = true })
hl("NvimTreeGitDirty",       { fg = c.yellow })
hl("NvimTreeGitNew",         { fg = c.green })
hl("NvimTreeGitDeleted",     { fg = c.red })
hl("NvimTreeIndentMarker",   { fg = c.grey })

hl("TelescopeNormal",       { fg = c.base05, bg = c.darker_black })
hl("TelescopeBorder",       { fg = c.darker_black, bg = c.darker_black })
hl("TelescopePromptNormal", { fg = c.base05, bg = c.black2 })
hl("TelescopePromptBorder", { fg = c.black2, bg = c.black2 })
hl("TelescopePromptTitle",  { fg = c.black, bg = c.red, bold = true })
hl("TelescopePreviewTitle", { fg = c.black, bg = c.green, bold = true })
hl("TelescopeResultsTitle", { fg = c.black, bg = c.blue, bold = true })
hl("TelescopeSelection",    { bg = c.black2 })
hl("TelescopeMatching",     { fg = c.base0A, bold = true })
hl("TelescopePromptPrefix", { fg = c.red, bg = c.black2 })

-- ── Spell ─────────────────────────────────────────────────────────────────
hl("SpellBad",   { undercurl = true, sp = c.red })
hl("SpellCap",   { undercurl = true, sp = c.yellow })
hl("SpellLocal", { undercurl = true, sp = c.blue })
hl("SpellRare",  { undercurl = true, sp = c.purple })
