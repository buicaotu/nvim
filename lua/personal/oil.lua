local status_ok, oil = pcall(require, "oil")
if not status_ok then
  return
end

local function grep_current_dir()
  local fzflua = require("fzf-lua")
  -- local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()
  if not dir then
    return
  end

  oil.close()
  -- local full_path = dir .. entry.name
  fzflua.grep({
    cwd = dir,
    input_prompt = 'Grep in ' .. dir .. ' ❯ ',
  })
end

local function files_current_dir()
  local fzflua = require("fzf-lua")
  -- local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()
  if not dir then
    return
  end

  oil.close()
  -- local full_path = dir .. entry.name
  fzflua.files({
    cwd = dir,
    -- input_prompt = 'Grep in ' .. dir .. ' ❯ ',
  })
end


oil.setup({
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
})

local opts = { noremap = true, silent = true, nowait = true }
-- Open file explorer
vim.keymap.set("n", "<C-n>", function()
  oil.toggle_float()
end, opts)

-- Redefine 'Browse' as oil.nvim disable netrw
vim.api.nvim_create_user_command(
  'Browse',
  function (o)
    vim.fn.system { 'open', o.fargs[1] }
  end,
  { nargs = 1 }
)

-- replacing gx functionality of netrw
local openUrl = function()
    return function()
        local file = vim.fn.expand("<cWORD>")
        -- open(macos) || xdg-open(linux)
        if
            string.match(file, "https") == "https"
            or string.match(file, "http") == "http"
        then
            vim.fn.system { 'open', file }
        else
            return print('"' .. file .. '" is not a URL 🙅')
        end
    end
end
local open = openUrl()
vim.keymap.set("n", "gx", open, { desc = "Open url under current word" })
