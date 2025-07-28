return {
  "personal.command_palette",
  lazy = false,
  dir = vim.fn.stdpath("config") .. "/lua/personal",
  keys = {
    { "<Char-0xAC>", function() require("personal.command_palette").open_palette() end, desc = "Command Palette" }
  },
  config = function()
    require("personal.command_palette").setup()
  end
}
