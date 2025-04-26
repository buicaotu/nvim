return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    "hide",
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
    },
    grep = {
      rg_glob = true,
      glob_flag = "--iglob", -- for case sensitive globs use '--glob'
      glob_separator = "%s%-%-" -- query separator pattern (lua): ' --'
    }
  },
  init = function()
    -- FZF settings
    vim.env.FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
    vim.g.fzf_history_dir = '~/.local/share/fzf-history'

    local opts = { noremap = true, silent = true, nowait = true }
    -- grep word under cursor
    vim.keymap.set("n", "<leader>r", function ()
      vim.cmd.Rg(vim.fn.expand("<cword>"))
    end, opts)

    -- grep word under cursor in current directory
    vim.keymap.set("n", "<leader>R", function ()
      vim.cmd.OilGrep(vim.fn.expand("<cword>"))
    end, opts)

    -- grep visual selected
    vim.keymap.set("v", "<leader>r", function ()
      local selected_text = require("fzf-lua.utils").get_visual_selection()
      vim.cmd.Rg(selected_text)
    end, opts)

    -- FZF keymaps
    vim.keymap.set("n", "<leader>s", function() 
      vim.cmd.FzfLua('files')
    end, opts)
    vim.keymap.set("n", "<C-p>", function() 
      vim.cmd.FzfLua('buffers')
    end, opts)
    vim.keymap.set("n", "<leader>p", vim.cmd.FzfLua, opts)

    -- todo: grep selected word/word under cursor within current folder
    
    -- Setup FZF Vim commands
    -- require("fzf-lua").setup_fzfvim_cmds()
    
    -- Create :Rg command for searching
    vim.api.nvim_create_user_command("Rg", function(opts)
      local search_text = table.concat(opts.fargs, " ")
      require("personal.command_palette").grep(vim.fn.getcwd(), search_text)
    end, { nargs = "*" })
  end
}
