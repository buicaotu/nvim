local opts = { noremap = true, silent = true, nowait = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- leader key
vim.g.mapleader = ' '

-- Replace without yank
keymap("v", "p", '"_dP', opts)

-- clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)

-- FZF keymaps
vim.keymap.set("n", "<leader>s", vim.cmd.Files, opts)
vim.keymap.set("n", "<C-p>", vim.cmd.Buffers, opts)
vim.keymap.set("n", "<leader>p", vim.cmd.FzfLua, opts)

-- terminal
-- https://neovim.io/doc/user/nvim_terminal_emulator.html
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)

-- window
vim.keymap.set('n', '<Tab>', '<C-^>', opts)
vim.keymap.set('t', '<c-r>', function()
  local next_char_code = vim.fn.getchar()
  local next_char = vim.fn.nr2char(next_char_code)
  return '<C-\\><C-N>"' .. next_char .. 'pi'
end, { expr = true })

-- Close current window or buffer if it's the last window
vim.api.nvim_set_keymap('n', '<leader>q', ':lua if #vim.api.nvim_list_wins() == 1 then vim.cmd("bd") else vim.cmd("q") end<CR>', { noremap = true, silent = true })

-- buffer
vim.keymap.set('n', '<leader>x', ':bn|bd#<CR>', opts)
vim.keymap.set('n', '<leader>X', ':bn|bd#!<CR>', opts)

vim.keymap.set('n', '<leader>h', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, opts)

-- Copilot
-- Unmapping the default keybindings (Tab) for Copilot to avoid conflicts
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

vim.keymap.set({ "n", "v" }, "<leader>aa", function()
  require("avante.api").ask()
end, opts)
vim.keymap.set({ "v" }, "<leader>ar", function()
  require("avante.api").refresh()
end, opts)
vim.keymap.set({ "n", "v" }, "<leader>ae", function()
  require("avante.api").edit()
end, opts)

-- Window resize
vim.keymap.set('n', '<M-Left>', ':vertical resize -5<CR>', opts)
vim.keymap.set('n', '<M-Right>', ':vertical resize +5<CR>', opts)
vim.keymap.set('n', '<M-Down>', ':resize -5<CR>', opts)
vim.keymap.set('n', '<M-Up>', ':resize +5<CR>', opts)

-- cmd keymaps
vim.keymap.set('n', '<Char-0xAA>', '<cmd>write<cr>', opts)
-- vim.keymap.set('v', '<Char-0xAB>', 'y', opts)
vim.keymap.set('v', '<Char-0xAB>', 'y<cmd>let @+=@0<CR>', opts)

-- common commands mispelled
vim.api.nvim_create_user_command('Wa', function(opts)
  vim.cmd('wa' .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*' })
vim.api.nvim_create_user_command('Qa', function(opts)
  vim.cmd('qa' .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*' })