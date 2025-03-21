return {
  -- LSP Support
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  -- Autocompletion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { "lukas-reineke/lsp-format.nvim" },
  { "github/copilot.vim" },

  -- Treesitter
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

  -- File explorer
  { "stevearc/oil.nvim" },

  -- Debug
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" },
  { "mxsdev/nvim-dap-vscode-js" },
  {
    "microsoft/vscode-js-debug",
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    pin = true
  },

  -- Formatting
  {
    url = "org-2562356@github.com:Canva/dprint-vim-plugin.git",
    event = "BufWritePre",
    lazy = true,
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
  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  { "tpope/vim-dispatch" },

  -- UI
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  { 'j-hui/fidget.nvim', opts = {} },
  { 'echasnovski/mini.move', version = false, opts = {} },

  -- Misc
  { 'cohama/lexima.vim' },
  { 'folke/neodev.nvim' },
  { 'nvim-lua/plenary.nvim' },
  { 'christoomey/vim-tmux-navigator' },
  { 'rhysd/conflict-marker.vim' },
  { 'JoosepAlviste/nvim-ts-context-commentstring' },
  { 'lukas-reineke/indent-blankline.nvim' },
} 
