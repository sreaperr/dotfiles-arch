local theme = vim.fn.system("cat ~/.config/.current-theme 2>/dev/null"):gsub("\n", "")

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function(args)
    local name = args.match
    local slug = name:find("tokyonight") and "tokyonight"
      or name:find("kali") and "kali"
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
      on_highlights = function(hl, _)
        hl.SnacksDashboardHeader = { fg = "#7dcfff" }
      end,
    },
  },

  --==========================
  -- TEMA ACTIVO
  --==========================
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme == "kali" and "kali"
        or "tokyonight",
    },
  },
}
