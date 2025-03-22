return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    "fzf-vim",
    winopts = {
      preview = { hidden = "nohidden" },
    },
    files = {
      -- disable previewer for file search only
      previewer = false,
      git_icons = false,
    },
    buffers = {
      previewer = false,
      git_icons = false,
    },
    oldfiles = {
      previewer = false,
    },
    previewers = {
      syntax_limit_b = 1024 * 100, -- 100KB
    }
  },
  init = function()
    -- FZF settings
    vim.env.FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
    vim.g.fzf_history_dir = '~/.local/share/fzf-history'

    local opts = { noremap = true, silent = true, nowait = true }
    -- grep word under cursor
    vim.keymap.set("n", "<leader>r", function ()
      require("fzf-lua").grep_cword()
    end, opts)

    -- grep WORD under cursor
    vim.keymap.set("n", "<leader>R", function ()
      local word = vim.fn.expand("<cword>")
      vim.cmd("OilGrep " .. word)
    end, opts)

    -- grep visual selected
    vim.keymap.set("v", "<leader>r", function ()
      require("fzf-lua").grep_visual()
    end, opts)

    -- todo: grep selected word/word under cursor within current folder
  end
}
