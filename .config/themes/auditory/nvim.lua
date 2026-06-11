-- Matrix (hacker green/black) colorscheme

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "auditory"

local fg      = "#00FF41"
local fg_dim  = "#008F11"
local bg      = "#000000"
local bg_alt  = "#001A00"
local bg_sel  = "#003300"
local cyan    = "#00FFFF"
local red     = "#FF0000"
local yellow  = "#FFFF00"
local gray    = "#005500"

local hl = vim.api.nvim_set_hl

hl(0, "Normal",       { fg = fg, bg = bg })
hl(0, "NormalFloat",  { fg = fg, bg = bg_alt })
hl(0, "Comment",      { fg = fg_dim, italic = true })
hl(0, "Constant",     { fg = cyan })
hl(0, "String",       { fg = "#55FF55" })
hl(0, "Identifier",   { fg = fg })
hl(0, "Function",     { fg = cyan, bold = true })
hl(0, "Statement",    { fg = fg, bold = true })
hl(0, "Keyword",      { fg = fg, bold = true })
hl(0, "PreProc",      { fg = cyan })
hl(0, "Type",         { fg = "#55ffaa" })
hl(0, "Special",      { fg = yellow })
hl(0, "Underlined",   { fg = cyan, underline = true })
hl(0, "Error",        { fg = bg, bg = red, bold = true })
hl(0, "Todo",         { fg = bg, bg = yellow, bold = true })

hl(0, "CursorLine",   { bg = bg_alt })
hl(0, "CursorLineNr", { fg = fg, bold = true })
hl(0, "LineNr",       { fg = gray })
hl(0, "Visual",       { bg = bg_sel })
hl(0, "Search",       { fg = bg, bg = fg })
hl(0, "IncSearch",    { fg = bg, bg = cyan })

hl(0, "Pmenu",        { fg = fg, bg = bg_alt })
hl(0, "PmenuSel",     { fg = bg, bg = fg })
hl(0, "PmenuSbar",    { bg = bg_alt })
hl(0, "PmenuThumb",   { bg = fg_dim })

hl(0, "StatusLine",   { fg = fg, bg = bg_alt })
hl(0, "StatusLineNC", { fg = gray, bg = bg_alt })
hl(0, "VertSplit",    { fg = gray, bg = bg })
hl(0, "WinSeparator", { fg = gray, bg = bg })

hl(0, "DiffAdd",      { fg = "#55ff55", bg = bg_alt })
hl(0, "DiffChange",   { fg = yellow, bg = bg_alt })
hl(0, "DiffDelete",   { fg = red, bg = bg_alt })
hl(0, "DiffText",     { fg = cyan, bg = bg_alt })

hl(0, "DiagnosticError", { fg = red })
hl(0, "DiagnosticWarn",  { fg = yellow })
hl(0, "DiagnosticInfo",  { fg = cyan })
hl(0, "DiagnosticHint",  { fg = fg_dim })
