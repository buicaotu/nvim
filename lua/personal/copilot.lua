
local opts = {
  mappings = {
    reset = {
      normal = '<leader>cr',
      insert = nil
    },
    show_diff = {
      normal = '<leader>cd'
    },
    complete = {
      insert ='<C-k>',
    },
  },
}

vim.o.completeopt = vim.o.completeopt .. ',noinsert,popup'

return opts
