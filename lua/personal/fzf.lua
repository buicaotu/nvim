local status_ok, fzflua = pcall(require, "fzf-lua")
if not status_ok then
  return
end

fzflua.setup({
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
})

local opts = { noremap = true, silent = true, nowait = true }
-- grep word under cursor
vim.keymap.set("n", "<leader>r", function ()
  fzflua.grep_cword()
end, opts)

-- grep WORD under cursor
vim.keymap.set("n", "<leader>R", function ()
  fzflua.grep_cWORD()
end, opts)

-- grep visual selected
vim.keymap.set("v", "<leader>r", function ()
  fzflua.grep_visual()
end, opts)

-- todo: grep selected word/word under cursor within current folder
