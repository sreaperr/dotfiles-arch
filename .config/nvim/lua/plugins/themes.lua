local theme = vim.fn.system("cat ~/.config/.current-theme 2>/dev/null"):gsub("\n", "")

local THEME_MAP = {
  desktop  = "tokyonight",
  auditory = "thorn-forest",
}

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
  -- THORN FOREST (auditory)
  --==========================
  {
    "jpwol/thorn.nvim",
    priority = 1000,
    opts = {
      theme = "forest",
    },
  },

  --==========================
  -- TEMA ACTIVO
  --==========================
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = THEME_MAP[theme] or "tokyonight",
    },
  },
}
