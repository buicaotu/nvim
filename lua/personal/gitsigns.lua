

require('gitsigns').setup {
  signs = {
    add          = { text = '+' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  yadm = {
    enable = false
  },
}

  -- " ----------------------------------------------------
  -- " gitsigns config
  -- " ----------------------------------------------------
  -- " set statusline+=%{get(b:,'gitsigns_status','')}
  -- map <leader>gc :Gitsigns preview_hunk_inline<CR>
  -- map <leader>gn :Gitsigns next_hunk<CR>
  -- map <leader>gp :Gitsigns prev_hunk<CR>
  -- map <leader>gs :Gitsigns stage_hunk<CR>
  -- map <leader>gr :Gitsigns reset_hunk<CR>
  -- " ----------------------------------------------------
local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap
keymap("", "]c", ":Gitsigns next_hunk<CR>", opts)
keymap("", "[c", ":Gitsigns prev_hunk<CR>", opts)
keymap("", "<leader>gp", ":Gitsigns preview_hunk_inline<CR>", opts)
