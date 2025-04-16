local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
 vim.fn.system({
   "git",
   "clone",
   "--filter=blob:none",
   "https://github.com/folke/lazy.nvim.git",
   "--branch=stable", -- latest stable release
   lazypath,
 })
end
vim.opt.rtp:prepend(lazypath)

-- Check if this is a work computer by checking hostname
local hostname = vim.loop.os_gethostname()
vim.g.work_env = hostname == "tuleworkmac.local"

require "personal.keymaps"
require "personal.options"

require("lazy").setup("plugins")

require "personal.treesitter"
require "personal.comment"
require "personal.lsp"
-- require "personal.neotest"
require "personal.git"
require "personal.dap"
require "personal.term"

require("personal.dprint").setup()
