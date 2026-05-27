vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

local set = vim.api.nvim_set_hl

vim.g.colors_name = "auditory"
vim.o.termguicolors = true

local c = {
  bg = "#000000",
  bg_alt = "#080d14",
  bg_float = "#0a0a0a",
  fg = "#00ff41",
  fg_dim = "#00802a",
  white = "#e2eaf8",
  pink = "#ff2d78",
  red = "#ff1744",
  yellow = "#ffd700",
  blue = "#4da6ff",
  cyan = "#00d4ff",
  purple = "#c792ea",
  comment = "#5c7080",
}

-- Grupos base de vim (otros plugins los usan como fallback)
set(0, "Title",    { fg = c.cyan,  bold = true })
set(0, "Special",  { fg = c.pink })
set(0, "Number",   { fg = c.pink })
set(0, "NonText",  { fg = c.fg_dim })
set(0, "Conceal",  { fg = c.fg_dim })
set(0, "MatchParen", { fg = c.yellow, bold = true, underline = true })
set(0, "Folded",   { fg = c.comment, bg = c.bg_alt })
set(0, "FoldColumn", { fg = c.fg_dim, bg = c.bg })
set(0, "VertSplit", { fg = c.pink })
set(0, "TabLine",    { fg = c.fg_dim, bg = c.bg_alt })
set(0, "TabLineFill",{ bg = c.bg })
set(0, "TabLineSel", { fg = c.fg, bg = c.bg, bold = true })
set(0, "ErrorMsg",  { fg = c.red, bold = true })
set(0, "WarningMsg",{ fg = c.yellow })
set(0, "MoreMsg",   { fg = c.fg })
set(0, "Question",  { fg = c.cyan })
set(0, "SpellBad",  { undercurl = true, sp = c.red })
set(0, "SpellWarn", { undercurl = true, sp = c.yellow })

set(0, "Normal", { fg = c.white, bg = c.bg })
set(0, "NormalNC", { fg = c.white, bg = c.bg })
set(0, "NormalFloat", { fg = c.white, bg = c.bg_float })
set(0, "FloatBorder", { fg = c.pink, bg = c.bg_float })
set(0, "SignColumn", { fg = c.fg_dim, bg = c.bg })
set(0, "LineNr", { fg = c.fg_dim, bg = c.bg })
set(0, "CursorLine", { bg = c.bg_alt })
set(0, "CursorLineNr", { fg = c.pink, bg = c.bg_alt, bold = true })
set(0, "ColorColumn", { bg = c.bg_alt })
set(0, "Visual", { bg = "#26384a" })
set(0, "Search", { fg = c.bg, bg = c.yellow })
set(0, "IncSearch", { fg = c.bg, bg = c.pink })
set(0, "Pmenu", { fg = c.white, bg = c.bg_float })
set(0, "PmenuSel", { fg = c.bg, bg = c.fg })
set(0, "StatusLine", { fg = c.fg, bg = c.bg_alt })
set(0, "StatusLineNC", { fg = c.fg_dim, bg = c.bg_alt })
set(0, "WinSeparator", { fg = c.pink })
set(0, "Directory", { fg = c.cyan })
set(0, "Comment", { fg = c.comment, italic = true })
set(0, "Constant", { fg = c.yellow })
set(0, "String", { fg = c.fg })
set(0, "Character", { fg = c.fg })
set(0, "Number", { fg = c.pink })
set(0, "Boolean", { fg = c.pink })
set(0, "Identifier", { fg = c.white })
set(0, "Function", { fg = c.blue, bold = true })
set(0, "Statement", { fg = c.pink, bold = true })
set(0, "Keyword", { fg = c.pink, bold = true })
set(0, "Operator", { fg = c.cyan })
set(0, "PreProc", { fg = c.purple })
set(0, "Type", { fg = c.cyan })
set(0, "Special", { fg = c.yellow })
set(0, "Underlined", { fg = c.cyan, underline = true })
set(0, "Error", { fg = c.red, bold = true })
set(0, "Todo", { fg = c.bg, bg = c.yellow, bold = true })
set(0, "DiagnosticError", { fg = c.red })
set(0, "DiagnosticWarn", { fg = c.yellow })
set(0, "DiagnosticInfo", { fg = c.blue })
set(0, "DiagnosticHint", { fg = c.cyan })
set(0, "GitSignsAdd", { fg = c.fg })
set(0, "GitSignsChange", { fg = c.yellow })
set(0, "GitSignsDelete", { fg = c.red })

-- TreeSitter (hi clear rompe los links; hay que restaurarlos)
set(0, "@keyword",            { link = "Keyword" })
set(0, "@keyword.function",   { link = "Keyword" })
set(0, "@keyword.return",     { link = "Keyword" })
set(0, "@keyword.operator",   { link = "Operator" })
set(0, "@function",           { link = "Function" })
set(0, "@function.call",      { link = "Function" })
set(0, "@function.method",    { link = "Function" })
set(0, "@function.method.call",{ link = "Function" })
set(0, "@constructor",        { link = "Function" })
set(0, "@variable",           { link = "Identifier" })
set(0, "@variable.builtin",   { fg = c.cyan })
set(0, "@type",               { link = "Type" })
set(0, "@type.builtin",       { fg = c.cyan, bold = true })
set(0, "@string",             { link = "String" })
set(0, "@string.escape",      { fg = c.yellow })
set(0, "@number",             { link = "Number" })
set(0, "@boolean",            { link = "Boolean" })
set(0, "@constant",           { link = "Constant" })
set(0, "@constant.builtin",   { fg = c.yellow, bold = true })
set(0, "@operator",           { link = "Operator" })
set(0, "@punctuation",        { fg = c.white })
set(0, "@punctuation.bracket",{ fg = c.pink })
set(0, "@comment",            { link = "Comment" })
set(0, "@tag",                { fg = c.cyan })
set(0, "@tag.attribute",      { fg = c.blue })
set(0, "@module",             { fg = c.blue })
set(0, "@property",           { fg = c.white })
set(0, "@parameter",          { fg = c.white, italic = true })

-- LSP semántico
set(0, "@lsp.type.keyword",   { link = "Keyword" })
set(0, "@lsp.type.function",  { link = "Function" })
set(0, "@lsp.type.method",    { link = "Function" })
set(0, "@lsp.type.variable",  { link = "Identifier" })
set(0, "@lsp.type.type",      { link = "Type" })
set(0, "@lsp.type.class",     { link = "Type" })
set(0, "@lsp.type.interface", { fg = c.cyan })
set(0, "@lsp.type.string",    { link = "String" })
set(0, "@lsp.type.number",    { link = "Number" })
set(0, "@lsp.type.comment",   { link = "Comment" })
set(0, "@lsp.type.parameter", { fg = c.white, italic = true })
set(0, "@lsp.type.property",  { fg = c.white })
set(0, "@lsp.type.namespace",  { fg = c.blue })

-- Snacks Dashboard
set(0, "SnacksDashboardNormal",  { fg = c.white,  bg = c.bg })
set(0, "SnacksDashboardHeader",  { fg = c.fg,     bold = true })
set(0, "SnacksDashboardTitle",   { fg = c.cyan,   bold = true })
set(0, "SnacksDashboardIcon",    { fg = c.pink })
set(0, "SnacksDashboardKey",     { fg = c.pink,   bold = true })
set(0, "SnacksDashboardDesc",    { fg = c.white })
set(0, "SnacksDashboardFile",    { fg = c.blue })
set(0, "SnacksDashboardDir",     { fg = c.fg_dim })
set(0, "SnacksDashboardFooter",  { fg = c.fg_dim, italic = true })
set(0, "SnacksDashboardSpecial", { fg = c.yellow })
