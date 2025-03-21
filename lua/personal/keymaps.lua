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

-- Replace without yank
keymap("v", "p", '"_dP', opts)

-- Undo tree --
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, opts)

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

-- Keymaps for both normal and visual modes
vim.keymap.set({"n", "v"}, "<leader>co", function()
  vim.cmd("CopilotChatToggle")
end, { desc = "CopilotChat - Open chat", noremap = true, silent = true, nowait = true })

vim.keymap.set({"n", "v"}, "<leader>cp", function()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.fzflua").pick(actions.prompt_actions())
end, { desc = "CopilotChat - Prompt actions", noremap = true, silent = true, nowait = true })


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
