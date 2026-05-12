local theme = vim.fn.system("cat ~/.config/.current-theme 2>/dev/null"):gsub("\n", "")

return {
  --==========================
  -- GRUVBOX
  --==========================
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      contrast = "hard",
      bold = true,
      italic = {
        strings   = true,
        operators = false,
        comments  = true,
      },
      overrides = {
        SignColumn = { bg = "#1d2021" },
        NormalFloat = { bg = "#1d2021" },
      },
    },
  },

  --==========================
  -- TOKYO NIGHT
  --==========================
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style      = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments   = { italic = true },
        keywords   = { bold = true },
        sidebars   = "dark",
        floats     = "dark",
      },
    },
  },

  --==========================
  -- TEMA ACTIVO
  --==========================
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme == "tokyonight" and "tokyonight" or "gruvbox",
    },
  },
}
