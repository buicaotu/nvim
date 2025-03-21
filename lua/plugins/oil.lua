
return {
  "stevearc/oil.nvim",
  opts = {
    keymaps = {
      ['<leader>y'] = 'actions.copy_entry_path',
      ['<leader>c'] = 'actions.cd',
      ['<leader>r'] = grep_current_dir,
      ['<leader>s'] = files_current_dir,
      ['<leader>v'] = 'actions.select_vsplit',
      ['<leader>i'] = 'actions.preview',
      ['<Tab>'] = 'actions.select',
      -- remove original keymapping
      ['<C-p>'] = false, -- preview
      ['<C-h>'] = false, -- split
    }
  }
}
