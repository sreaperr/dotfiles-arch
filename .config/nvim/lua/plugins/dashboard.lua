return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.preset = opts.dashboard.preset or {}

    opts.dashboard.preset.keys = {
      { icon = " ", key = "f", desc = "Buscar archivo",    action = ":lua Snacks.picker.files()" },
      { icon = " ", key = "g", desc = "Buscar texto",      action = ":lua Snacks.picker.grep()" },
      { icon = " ", key = "r", desc = "Archivos recientes",action = ":lua Snacks.picker.recent()" },
      { icon = " ", key = "n", desc = "Nuevo archivo",     action = ":ene | startinsert" },
      { icon = "󰒲 ", key = "l", desc = "Lazy plugins",     action = ":Lazy" },
      { icon = "󰩈 ", key = "q", desc = "Salir",            action = ":qa" },
    }

    local user = vim.env.USER or "user"
    local header = vim.fn.system("figlet -f slant " .. user .. " 2>/dev/null")
    if vim.v.shell_error ~= 0 or header == "" then
      header = user:upper()
    end
    opts.dashboard.preset.header = header

    opts.dashboard.sections = {
      { section = "header", padding = 2 },
      { section = "keys",         gap = 1, padding = 1 },
      { section = "recent_files", gap = 1, padding = 1, limit = 5 },
      { section = "startup" },
    }
  end,
}
