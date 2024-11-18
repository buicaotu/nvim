local opts = { noremap = true, silent = true, nowait = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- leader key
vim.g.mapleader = ' '

-- Move text up and down
keymap("n", "<M-j>", "<Esc>:m .+1<CR>==", opts)
keymap("n", "<M-k>", "<Esc>:m .-2<CR>==", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<M-j>", ":m .+1<CR>==", opts)
keymap("v", "<M-k>", ":m .-2<CR>==", opts)

-- Replace without yank
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<M-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<M-k>", ":move '<-2<CR>gv-gv", opts)

-- Undo tree --
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, opts)


-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
-- vim.keymap.set("x", "if", "<Plug>(coc-funcobj-i)", opts)
-- vim.keymap.set("o", "if", "<Plug>(coc-funcobj-i)", opts)
-- vim.keymap.set("x", "af", "<Plug>(coc-funcobj-a)", opts)
-- vim.keymap.set("o", "af", "<Plug>(coc-funcobj-a)", opts)
-- vim.keymap.set("x", "ic", "<Plug>(coc-classobj-i)", opts)
-- vim.keymap.set("o", "ic", "<Plug>(coc-classobj-i)", opts)
-- vim.keymap.set("x", "ac", "<Plug>(coc-classobj-a)", opts)
-- vim.keymap.set("o", "ac", "<Plug>(coc-classobj-a)", opts)

-- clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', opts)
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', opts)

-- FZF keymaps
vim.keymap.set("n", "<leader>s", vim.cmd.Files, opts)
vim.keymap.set("n", "<C-p>", vim.cmd.Buffers, opts)
vim.keymap.set("n", "<leader>p", vim.cmd.FzfLua, opts)

-- git-fugitive keymaps
vim.keymap.set("n", "<leader>ds", vim.cmd.Gvdiffsplit, opts)
vim.keymap.set("n", "<leader>dt", ':G difftool --name-only<CR>', opts)
vim.keymap.set("n", "<leader>mt", ':G mergetool <CR>', opts)

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

-- Keymaps for both normal and visual modes
vim.keymap.set({"n", "v"}, "<leader>cco", function()
  vim.cmd("CopilotChatOpen")
end, { desc = "CopilotChat - Open chat", noremap = true, silent = true, nowait = true })

vim.keymap.set({"n", "v"}, "<leader>ccp", function()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.fzflua").pick(actions.prompt_actions())
end, { desc = "CopilotChat - Prompt actions", noremap = true, silent = true, nowait = true })

