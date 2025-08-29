return {
  {
    dir = vim.fn.stdpath("config") .. "/ghp",
    name = "ghp",
    dev = true,
    config = function()
      require("ghp").setup()
    end,
  }
} 