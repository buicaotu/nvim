local M = {}
local logger = require("ghp.logger")

-- Creates a comment window with the given options
-- @param opts: Table with the following fields:
--   - title: Title of the window (string)
--   - commented_lines: Lines being commented on, if any (table)
--   - on_submit: Callback when comment is submitted (function(temp_file_path))
--   - on_close: Callback when window is closed without submission (function())
function M.create_comment_window(opts)
  -- Set default options
  opts = opts or {}
  local title = opts.title or "Comment"
  local commented_lines = opts.commented_lines or {}
  local on_submit = opts.on_submit or function() end
  local on_close = opts.on_close or function() end
  
  logger.debug("Creating comment window with title: " .. title)
 
  
  -- Create a new buffer for the comment
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_name(bufnr, title)
  
  -- Set initial content with instructions
  local lines = {
    "# Write your comment below",
    "# Lines starting with # will be ignored",
    "# Press <leader>s to submit the comment",
    "# Press q to cancel",
    "",
  }
  
  -- If we have lines being commented on, add them
  if #commented_lines > 0 then
    table.insert(lines, "<!-- The lines you're commenting on: -->")
    for _, line in ipairs(commented_lines) do
      table.insert(lines, "> " .. line)
    end
    table.insert(lines, "")
  end
  
  table.insert(lines, "<!-- Write your comment below -->")
  table.insert(lines, "")
  
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  
  -- Create a window for the buffer
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.8)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.6)
  local row = math.floor((vim.api.nvim_get_option("lines") - height) / 2)
  local col = math.floor((vim.api.nvim_get_option("columns") - width) / 2)
  
  local window_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  }
  
  local winnr = vim.api.nvim_open_win(bufnr, true, window_opts)
  
  -- Set filetype for better highlighting
  vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
  
  -- Function to submit the comment
  local function submit_comment()
    -- Get buffer content
    local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local comment_text = {}
    local found_placeholder = false
    
    -- Go through the lines from top down and look for the placeholder
    for _, line in ipairs(content) do
      if found_placeholder then
        -- Add all lines below the placeholder
        table.insert(comment_text, line)
      elseif line == "<!-- Write your comment below -->" then
        found_placeholder = true
      end
    end
    
    -- Remove empty lines from the end
    while #comment_text > 0 and comment_text[#comment_text]:match("^%s*$") do
      table.remove(comment_text, #comment_text)
    end
    
    -- Check if comment is empty
    if #comment_text == 0 then
      vim.notify("Comment is empty. Not submitting.", vim.log.levels.WARN)
      logger.warn("Comment submission canceled: empty comment")
      return
    end
    
    -- Join lines with newlines
    local comment_body = table.concat(comment_text, "\n")
    
    -- Create a temporary file for the comment
    local temp_file = os.tmpname()
    logger.debug("Created temporary file for comment: " .. temp_file)
    -- Write comment to temporary file
    local file = io.open(temp_file, "w")
    if not file then
      vim.notify("Failed to write comment to temporary file", vim.log.levels.ERROR)
      logger.error("Failed to write comment to temporary file: " .. temp_file)
      return
    end
    
    file:write(comment_body)
    file:close()
    
    -- Close the window and buffer
    vim.api.nvim_win_close(winnr, true)
    
    -- Call the submit callback with the temp file path
    on_submit(temp_file)

    -- Delete the temporary file on close
    os.remove(temp_file)
    logger.debug("Removed temporary file: " .. temp_file)
    close_window()
  end
  
  -- Function to handle closing the window
  local function close_window()
    vim.api.nvim_win_close(winnr, true)
    on_close()
  end
  
  -- Set keymaps for the buffer
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>s", "", {
    noremap = true,
    silent = true,
    callback = submit_comment
  })
  
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "", {
    noremap = true,
    silent = true,
    callback = close_window
  })
  
  -- Set cursor at the start of the empty line below the instruction
  local placeholder_line = #lines
  vim.api.nvim_win_set_cursor(winnr, {placeholder_line, 0})
  
  -- Enter insert mode
  vim.cmd("startinsert")
  
  -- Return buffer and window numbers for possible external use
  return {
    bufnr = bufnr,
    winnr = winnr
  }
end

return M 