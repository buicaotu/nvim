-- Store the buffer number of the terminal
local terminal_bufs = {}

local function find_term_win_id(terminal_buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf == terminal_buf then
      return win
    end
  end
end

-- Create a function to open or switch to the terminal buffer
local function open_or_switch_term()
  local buf_counter = vim.v.count
  local terminal_buf = terminal_bufs[buf_counter]
  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    -- Check if the terminal buffer is displayed in any window
    local win_id = find_term_win_id(terminal_buf)

    if win_id then
      -- Focus the window containing the terminal buffer
      vim.api.nvim_set_current_win(win_id)

      -- -- If the terminal buffer is displayed, resize the window
      -- vim.api.nvim_win_set_height(win_id, math.floor(vim.o.lines * 0.2))

      -- Check current window height and resize if necessary
      local current_height = vim.api.nvim_win_get_height(win_id)
      local desired_height = math.floor(vim.o.lines * 0.2)
      if current_height ~= desired_height then
        vim.api.nvim_win_set_height(win_id, desired_height)
      end
    else
      -- If the terminal buffer is not displayed, open it in a new split
      vim.cmd('belowright 12split | buffer ' .. terminal_buf)
    end
  else
    -- Create a new terminal buffer with a split taking up 20% of the screen
    vim.cmd('belowright 12split | terminal')

    -- Save the buffer number
    terminal_buf = vim.api.nvim_get_current_buf()
    -- config terminal buf
    vim.api.nvim_buf_set_option(terminal_buf, 'buflisted', false)
    vim.api.nvim_buf_set_option(terminal_buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(terminal_buf, 'number', false)
    vim.api.nvim_buf_set_option(terminal_buf, 'relativenumber', false)
    -- save to list
    terminal_bufs[buf_counter] = terminal_buf
  end
end

local function close_term_win()
  for _, terminal_buf in pairs(terminal_bufs) do
    if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
      -- Check if the terminal buffer is displayed in any window
      local win_id = find_term_win_id(terminal_buf)
      if win_id then
        vim.api.nvim_win_close(win_id, true)
      end
    end
  end
end

vim.api.nvim_create_autocmd('termopen', {
  pattern = '*',
  callback = function()
    vim.cmd('startinsert')
  end,
})

-- Keymapping
vim.keymap.set("n", "<leader>/", open_or_switch_term, { noremap = true, silent = true, nowait = true })
vim.keymap.set("n", "<leader><leader>/", close_term_win, { noremap = true, silent = true, nowait = true })
