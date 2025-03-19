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

require("lazy").setup({
  {
   "VonHeikemen/lsp-zero.nvim",
   branch = 'v3.x',
   dependencies = {
     --- Uncomment these if you want to manage LSP servers from neovim
     { 'williamboman/mason.nvim' },
     { 'williamboman/mason-lspconfig.nvim' },

     -- LSP Support
     { 'neovim/nvim-lspconfig' },
     -- Autocompletion
     { 'hrsh7th/nvim-cmp' },
     { 'hrsh7th/cmp-nvim-lsp' },
     { 'L3MON4D3/LuaSnip' },
   }
  },
  "lukas-reineke/lsp-format.nvim",

  -- copilot
  "github/copilot.vim",
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = require("personal.avante"),
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      "github/copilot.vim",
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  {
   "nvim-treesitter/nvim-treesitter",
   build = ':TSUpdate'
  },
  {
   "nvim-treesitter/nvim-treesitter-textobjects",
   dependencies = {
     "nvim-treesitter/nvim-treesitter",
   },
  },
  {
   'nvim-treesitter/nvim-treesitter-context',
   dependencies = {
     "nvim-treesitter/nvim-treesitter",
   },
  },
  -- file explorer
  "stevearc/oil.nvim",
  {
   "ibhagwan/fzf-lua",
   dependencies = { "nvim-tree/nvim-web-devicons" }
  },
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  "mxsdev/nvim-dap-vscode-js",
  {
   "microsoft/vscode-js-debug",
   build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
   pin = true
  },
  -- Testing
  {
   "nvim-neotest/neotest",
   dependencies = {
     "nvim-lua/plenary.nvim",
     "antoinemadec/FixCursorHold.nvim",
     "nvim-treesitter/nvim-treesitter",
     "nvim-neotest/neotest-jest",
   }
  },
  -- Git
  "tpope/vim-fugitive", -- !git with improvement
  "tpope/vim-rhubarb",  -- hub in github
  "tpope/vim-dispatch",
  {
    'nvim-lualine/lualine.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Misc
  'cohama/lexima.vim', -- Autopair
  -- 'mbbill/undotree',
  'folke/neodev.nvim', -- nvim lua dev env
  -- 'jbyuki/one-small-step-for-vimkind', -- nvim lua debug adapter
  'nvim-lua/plenary.nvim', -- lua utils
  { 
    'j-hui/fidget.nvim',
    opts = {},
  },
  'christoomey/vim-tmux-navigator',  -- use CTRL+hjkl to navigate between nvim windows/tmux pane
  'rhysd/conflict-marker.vim', -- "highlight conflicts
  'JoosepAlviste/nvim-ts-context-commentstring', -- change comment syntax based on context
  {
    'Mofiqul/vscode.nvim',
    opts = require("personal.colorscheme"),
    init = function()
      vim.o.background = 'dark'
      vim.cmd.colorscheme "vscode"
    end
  },
  'lukas-reineke/indent-blankline.nvim', -- " Show horizontal back line
  {
    url = "org-2562356@github.com:Canva/dprint-vim-plugin.git",
    event = "BufWritePre",
    lazy = true,
  }
})

-- import file
-- require "personal.packer"
local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)

require "personal.neodev"
require "personal.options"
require "personal.treesitter"
require "personal.keymaps"
require "personal.comment"
require "personal.lsp"
-- require "personal.neotest"
-- require "personal.gitsigns"
require "personal.fzf"
require "personal.workflow"
require "personal.dap"
require "personal.oil"
require "personal.term"

require("personal.dprint").setup()