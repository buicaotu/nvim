local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

require "personal.dap.ui"
-- Setup adapters
require "personal.dap.adapters.js"

-- keymaps
vim.keymap.set('n', '<F5>', dap.continue)
vim.keymap.set('n', '<F10>', dap.step_over)
vim.keymap.set('n', '<F12>', dap.step_into)
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader><leader>b', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end)
