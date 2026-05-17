local set = vim.api.nvim_set_hl

vim.g.colors_name = "kali"
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
