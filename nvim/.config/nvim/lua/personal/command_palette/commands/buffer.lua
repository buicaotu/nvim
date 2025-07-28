local M = {}
local core = require("personal.command_palette.core")

-- Function to close a buffer with confirmation if modified
local function close_buffer_with_confirm(buf)
  -- Check if buffer is modified
  local is_modified = vim.api.nvim_buf_get_option(buf, "modified")
  if is_modified then
    -- Get buffer name for the prompt
    local bufname = vim.api.nvim_buf_get_name(buf)
    bufname = bufname ~= "" and bufname or "[No Name]"
    -- Prompt to save
    local choice = vim.fn.confirm("Save changes to " .. bufname .. "?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then -- Yes
      vim.api.nvim_buf_call(buf, function() vim.cmd("silent! w") end)
      vim.api.nvim_buf_delete(buf, {})
      return true
    elseif choice == 2 then -- No
      vim.api.nvim_buf_delete(buf, { force = true })
      return true
    elseif choice == 3 then -- Cancel
      return false -- Operation cancelled
    end
  else
    -- Not modified, just delete
    vim.api.nvim_buf_delete(buf, {})
    return true
  end
end

-- Function to get a list of non-terminal buffers
local function get_non_terminal_buffers()
  local result = {}
  
  -- Get all buffer numbers
  local buffers = vim.api.nvim_list_bufs()
  
  for _, buf in ipairs(buffers) do
    -- Skip terminal buffers
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    if buftype ~= "terminal" then
      table.insert(result, buf)
    end
  end
  
  return result
end

-- Function to close all other buffers
local function close_all_other_buffers()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = get_non_terminal_buffers()
  
  for _, buf in ipairs(buffers) do
    -- Skip current buffer
    if buf ~= current_buf then
      if not close_buffer_with_confirm(buf) then
        return -- Stop the process if user cancelled
      end
    end
  end
end

local function close_all_buffers()
  local buffers = get_non_terminal_buffers()
  
  for _, buf in ipairs(buffers) do
    if not close_buffer_with_confirm(buf) then
      return -- Stop the process if user cancelled
    end
  end
end

-- Function to force close all buffers
local function force_close_all_buffers()
  -- Prompt to confirm before proceeding
  local choice = vim.fn.confirm("Close all buffers without saving?", "&Yes\n&No", 2)
  
  if choice ~= 1 then
    return -- User cancelled the operation
  end
  
  -- Get all buffer numbers
  local buffers = vim.api.nvim_list_bufs()
  
  -- Force close all buffers
  for _, buf in ipairs(buffers) do
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
  
  -- Create a new empty buffer to keep Neovim open
  vim.cmd("enew")
end

-- Function to copy absolute path of current buffer to clipboard
local function copy_absolute_path()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path ~= "" then
    vim.fn.setreg('+', buffer_path)
    vim.notify("Copied absolute path to clipboard", vim.log.levels.INFO)
  else
    vim.notify("Current buffer has no path", vim.log.levels.WARN)
  end
end

-- Function to copy relative path of current buffer to clipboard
local function copy_relative_path()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path ~= "" then
    local working_dir = vim.fn.getcwd()
    
    -- Check if the file is in the working directory
    if vim.startswith(buffer_path, working_dir) then
      -- Get the relative path
      local relative_path = buffer_path:sub(working_dir:len() + 2) -- +2 to account for the trailing slash
      vim.fn.setreg('+', relative_path)
      vim.notify("Copied relative path to clipboard", vim.log.levels.INFO)
    else
      -- If file is outside working directory, use absolute path instead
      vim.fn.setreg('+', buffer_path)
      vim.notify("Copied absolute path to clipboard (file outside working directory)", vim.log.levels.INFO)
    end
  else
    vim.notify("Current buffer has no path", vim.log.levels.WARN)
  end
end

-- Register commands
function M.setup()
  core.register_command("buffer: close all buffers", close_all_buffers)
  core.register_command("buffer: close all other buffers", close_all_other_buffers)
  core.register_command("buffer: force close all buffers", force_close_all_buffers)
  core.register_command("buffer: copy absolute path", copy_absolute_path)
  core.register_command("buffer: copy relative path", copy_relative_path)
end

return M 