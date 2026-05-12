local map = vim.keymap.set

--==========================
-- NAVEGACIÓN
--==========================
map("n", "<C-h>", "<C-w>h", { desc = "Ir a ventana izquierda" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir a ventana derecha" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir a ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir a ventana arriba" })

-- Mover líneas en modo visual
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover línea abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover línea arriba" })

-- Centrar al buscar
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

--==========================
-- EDICIÓN
--==========================
-- Pegar sin perder el registro
map("x", "<leader>p", '"_dP', { desc = "Pegar sin perder registro" })

-- Guardar
map({ "n", "i" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Guardar archivo" })

-- Salir
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Cerrar ventana" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Cerrar todo" })

--==========================
-- SPLITS
--==========================
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>-", "<cmd>split<cr>",  { desc = "Split horizontal" })

--==========================
-- BUFFERS
--==========================
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Buffer siguiente" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Cerrar buffer" })

--==========================
-- UTILIDADES
--==========================
-- Limpiar búsqueda
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Abrir terminal
map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Abrir terminal" })
