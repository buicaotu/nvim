local M = {}
local core = require("personal.command_palette.core")

-- Function to close all other buffers
local function close_all_other_buffers()
  local current_buf = vim.api.nvim_get_current_buf()
  -- Get all buffer numbers
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    -- Skip current buffer
    if buf ~= current_buf then
      -- Skip terminal buffers
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype ~= "terminal" then
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
          elseif choice == 2 then -- No
            vim.api.nvim_buf_delete(buf, { force = true })
          elseif choice == 3 then -- Cancel
            return -- Stop the process
          end
        else
          -- Not modified, just delete
          vim.api.nvim_buf_delete(buf, {})
        end
      end
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

-- Register commands
function M.setup()
  core.register_command("buffer: close all other buffers", close_all_other_buffers)
  core.register_command("buffer: force close all buffers", force_close_all_buffers)
end

return M 