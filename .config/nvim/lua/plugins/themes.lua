return {
  --==========================
  -- TOKYO NIGHT
  --==========================
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style           = "night",
      transparent     = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { bold = true },
        sidebars = "dark",
        floats   = "dark",
      },
      on_highlights = function(hl, c)
        hl.SnacksDashboardHeader  = { fg = c.blue,    bold = true }
        hl.SnacksDashboardTitle   = { fg = c.cyan,    bold = true }
        hl.SnacksDashboardIcon    = { fg = c.magenta }
        hl.SnacksDashboardKey     = { fg = c.magenta, bold = true }
        hl.SnacksDashboardDesc    = { fg = c.fg }
        hl.SnacksDashboardFile    = { fg = c.blue }
        hl.SnacksDashboardDir     = { fg = c.comment }
        hl.SnacksDashboardFooter  = { fg = c.comment, italic = true }
        hl.SnacksDashboardSpecial = { fg = c.yellow }
      end,
    },
  },

  --==========================
  -- NO CLOWN FIESTA (auditory, escala de grises)
  --==========================
  {
    "aktersnurra/no-clown-fiesta.nvim",
    priority = 1000,
  },

  --==========================
  -- TEMA ACTIVO
  --==========================
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "no-clown-fiesta",
    },
  },
}
