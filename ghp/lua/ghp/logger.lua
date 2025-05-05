local M = {}

-- Default log path in the system's temporary directory
local log_file_path = vim.fn.stdpath("cache") .. "/ghp_log.txt"

-- Set log level
M.log_level = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4
}

-- Current minimum log level
M.current_level = M.log_level.INFO

-- Format the current timestamp
local function get_timestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

-- Format a log message with timestamp and level
local function format_log(level, message)
  return string.format("[%s] [%s] %s", get_timestamp(), level, message)
end

-- Write a message to the log file
local function write_to_log(message)
  local file = io.open(log_file_path, "a")
  if file then
    file:write(message .. "\n")
    file:close()
  end
end

-- Log a message at a specific level
function M.log(level_name, message)
  local level = M.log_level[level_name]
  if not level or level < M.current_level then
    return
  end
  
  local formatted = format_log(level_name, message)
  write_to_log(formatted)
end

-- Convenience functions for different log levels
function M.debug(message)
  M.log("DEBUG", message)
end

function M.info(message)
  M.log("INFO", message)
end

function M.warn(message)
  M.log("WARN", message)
end

function M.error(message)
  M.log("ERROR", message)
end

-- Set the minimum log level
function M.set_level(level_name)
  local level = M.log_level[level_name]
  if level then
    M.current_level = level
    M.info("Log level set to " .. level_name)
  else
    M.warn("Invalid log level: " .. tostring(level_name))
  end
end

-- Log a table's contents (useful for debugging)
function M.log_table(level_name, tbl, label)
  label = label or "Table contents"
  
  local function table_to_string(t, indent)
    indent = indent or 0
    local indent_str = string.rep("  ", indent)
    local result = "{\n"
    
    for k, v in pairs(t) do
      result = result .. indent_str .. "  [" .. tostring(k) .. "] = "
      
      if type(v) == "table" then
        result = result .. table_to_string(v, indent + 1)
      else
        result = result .. tostring(v)
      end
      
      result = result .. ",\n"
    end
    
    result = result .. indent_str .. "}"
    return result
  end
  
  M.log(level_name, label .. ": " .. table_to_string(tbl))
end

-- Open the log file in a buffer
function M.open_log()
  -- Check if log file exists
  local exists = vim.fn.filereadable(log_file_path) == 1
  if not exists then
    vim.notify("Log file does not exist yet", vim.log.levels.WARN)
    -- Create an empty file
    local file = io.open(log_file_path, "w")
    if file then
      file:write("--- GitHub PR Plugin Log ---\n")
      file:close()
    else
      vim.notify("Failed to create log file", vim.log.levels.ERROR)
      return
    end
  end
  
  -- Open the log file in a new buffer
  vim.cmd("split " .. log_file_path)
  
  -- Set buffer options
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "log")
  
  -- Set keymap to reload the log
  vim.api.nvim_buf_set_keymap(bufnr, "n", "R", "", {
    noremap = true,
    silent = true,
    callback = function()
      local content = vim.fn.readfile(log_file_path)
      vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
      vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
      vim.notify("Log file reloaded", vim.log.levels.INFO)
    end
  })
  
  -- Set keymap to close the buffer
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", {
    noremap = true,
    silent = true
  })
  
  -- Scroll to the bottom of the file
  vim.cmd("normal! G")
  
  vim.notify("GHP log opened. Press 'R' to reload, 'q' to close", vim.log.levels.INFO)
end

-- Clear the log file
function M.clear_log()
  local file = io.open(log_file_path, "w")
  if file then
    file:write("--- GitHub PR Plugin Log Cleared at " .. get_timestamp() .. " ---\n")
    file:close()
    vim.notify("Log file cleared", vim.log.levels.INFO)
  else
    vim.notify("Failed to clear log file", vim.log.levels.ERROR)
  end
end

return M 