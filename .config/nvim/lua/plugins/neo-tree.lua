return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "left",
      width = 30,
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = {
        enabled = true,
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- No abrir si es el dashboard o stdin
        if vim.fn.argc(-1) == 0 then return end
        require("neo-tree.command").execute({ action = "show" })
      end,
    })
  end,
}
