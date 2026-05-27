local theme = vim.fn.system("cat ~/.config/.current-theme 2>/dev/null"):gsub("\n", "")

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function(args)
    local name = args.match
    local slug = name:find("thorn%-forest") and "thorn-forest"
      or name:find("thorn")      and "thorn-forest"
      or name:find("tokyonight") and "tokyonight"
    if slug then
      vim.fn.system("echo " .. slug .. " > ~/.config/.current-theme")
    end
  end,
})

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
      colorscheme = theme == "thorn-forest" and "thorn-forest"
        or "tokyonight",
    },
  },
}
