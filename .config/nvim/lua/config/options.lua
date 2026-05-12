local opt = vim.opt

--==========================
-- EDITOR
--==========================
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.signcolumn     = "yes"

--==========================
-- INDENTACIÓN
--==========================
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true

--==========================
-- BÚSQUEDA
--==========================
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = false
opt.incsearch      = true

--==========================
-- APARIENCIA
--==========================
opt.termguicolors  = true
opt.showmode       = false
opt.laststatus     = 3
opt.cmdheight      = 1
opt.pumblend       = 10
opt.winblend       = 10

--==========================
-- ARCHIVOS
--==========================
opt.undofile       = true
opt.swapfile       = false
opt.backup         = false
opt.updatetime     = 250
opt.timeoutlen     = 300

--==========================
-- SPLITS
--==========================
opt.splitbelow     = true
opt.splitright     = true

--==========================
-- PORTAPAPELES
--==========================
opt.clipboard      = "unnamedplus"
