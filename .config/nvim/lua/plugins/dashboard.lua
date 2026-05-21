return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.preset = opts.dashboard.preset or {}

    opts.dashboard.preset.header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠞⠛⠛⠶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣠⢤⠀⠀⠀⣴⠟⠁⠀⠀⠀⠀⠈⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢠⠞⢁⡞⢀⣰⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠻⣄⠀⠀⠀⠀⠀⠀⠀⠀
⡰⢷⠆⠸⠶⠋⠁⠀⢠⡴⠄⠀⠀⠀⠀⠀⠀⠀⠙⣆⠀⠀⠀⠀⠀⠀⠀
⠀⣼⠀⠀⠀⣠⠴⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠚⢧⡀⠀⠀⠀⠀⠀
⠀⠹⡤⠖⣻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣄⠀⠀⠀⠀
⠀⠀⠀⢰⠇⠀⠀⠀⠀⠀⠀⠀⣠⢶⡀⠀⠀⠀⠀⠀⠀⠀⢹⡄⠀⠀⠀
⠀⠀⢀⡏⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠙⢦⡀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀
⠀⢀⡞⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠙⠳⣄⠀⠀⠀⠀⠈⢧⠀⠀
⠀⡞⠀⠀⠀⢀⣤⢞⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣈⡷⣄⠀⠀⠀⠈⢧⠀
⣸⠁⠀⢀⣴⡟⢹⠀⠉⠓⢤⣀⠀⣄⠀⣀⠴⠊⠁⢀⡏⢷⣄⠀⠀⠘⡆
⡏⠀⢠⢿⡏⠀⠀⠹⢦⣀⠴⠛⠋⣉⠙⠓⠤⣠⠴⠋⠀⠈⢻⣳⡄⠀⣿
⣧⢀⡏⠈⠳⣄⡀⣀⣤⣄⠀⠀⡘⠈⢆⠀⠀⣠⣄⡀⢀⡴⠞⠀⢻⠀⡿
⠹⡌⡇⠀⠀⠀⠉⠉⣆⡏⡀⠰⠅⠤⠬⠀⠘⢩⣼⠉⠉⠀⠀⠀⣸⣰⠃
⠀⠙⢿⣄⠀⠀⠀⠀⡟⣏⡑⠳⠒⠲⠲⠚⢋⡟⣷⠀⠀⠀⠀⣰⡿⠃⠀
⠀⠀⠈⠛⢷⣤⡀⠀⣇⠑⠬⣑⠒⠄⠒⣈⠕⠂⣸⠀⣀⣴⡾⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠙⢿⡳⣌⡳⣄⠀⣉⣚⡉⠀⡠⢊⡤⣺⠟⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠉⢮⡱⣌⠉⠉⠉⠉⠉⡵⢋⠞⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⢌⢣⡀⠀⢀⢞⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠓⢬⣀⠵⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]]

    opts.dashboard.preset.keys = {
      { icon = " ", key = "f", desc = "Buscar archivo",    action = ":lua Snacks.picker.files()" },
      { icon = " ", key = "g", desc = "Buscar texto",      action = ":lua Snacks.picker.grep()" },
      { icon = " ", key = "r", desc = "Archivos recientes",action = ":lua Snacks.picker.recent()" },
      { icon = " ", key = "n", desc = "Nuevo archivo",     action = ":ene | startinsert" },
      { icon = "󰒲 ", key = "l", desc = "Lazy plugins",     action = ":Lazy" },
      { icon = "󰩈 ", key = "q", desc = "Salir",            action = ":qa" },
    }

    opts.dashboard.sections = {
      { section = "header" },
      { section = "keys",         gap = 1, padding = 1 },
      { section = "recent_files", gap = 1, padding = 1, limit = 5 },
      { section = "startup" },
    }
  end,
}
