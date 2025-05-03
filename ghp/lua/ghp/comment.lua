local M = {}
local logger = require("ghp.logger")

-- Create a new PR comment
function M.create_comment()
  local review = require("ghp.review")
  
  -- Check if we have PR data
  if not review.cache.pr_number then
    vim.notify("No PR data available. Run GHPReview first.", vim.log.levels.WARN)
    logger.warn("Attempted to create comment but no PR data available")
    return
  end
  
  logger.info("Creating new PR comment for PR #" .. review.cache.pr_number)
  
  -- Create a new buffer for the comment
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_name(bufnr, "PR-Comment-" .. review.cache.pr_number)
  
  -- Set initial content with instructions
  local lines = {
    "# Write your PR comment below",
    "# Lines starting with # will be ignored",
    "# Press <leader>s to submit the comment",
    "# Press q to cancel",
    "",
    "<!-- Write your comment below -->",
    "",
  }
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  
  -- Create a window for the buffer
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.8)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.6)
  local row = math.floor((vim.api.nvim_get_option("lines") - height) / 2)
  local col = math.floor((vim.api.nvim_get_option("columns") - width) / 2)
  
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "PR Comment - #" .. review.cache.pr_number,
    title_pos = "center",
  }
  
  local winnr = vim.api.nvim_open_win(bufnr, true, opts)
  
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
    
    -- Close the window and buffer
    vim.api.nvim_win_close(winnr, true)
    
    -- Submit the comment using GitHub CLI
    vim.notify("Submitting comment to PR #" .. review.cache.pr_number .. "...", vim.log.levels.INFO)
    logger.info("Attempting to submit comment to PR #" .. review.cache.pr_number)
    
    -- Create a temporary file for the comment content
    local temp_file = os.tmpname()
    local file = io.open(temp_file, "w")
    if not file then
      local error_msg = "Failed to create temporary file"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      return
    end
    file:write(comment_body)
    file:close()
    
    logger.debug("Temp file created at: " .. temp_file)
    logger.debug("Comment body length: " .. #comment_body .. " characters")
    
    -- Use GitHub CLI to post the comment
    local cmd = string.format("gh pr comment %s --body-file %s", review.cache.pr_number, temp_file)
    logger.debug("Executing command: " .. cmd)
    
    local handle = io.popen(cmd .. " 2>&1")
    if not handle then
      local error_msg = "Failed to execute gh command"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      os.remove(temp_file)
      return
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    os.remove(temp_file)
    
    logger.debug("Command output: " .. output)
    logger.debug("Command exit status: " .. tostring(success))
    
    if success then
      vim.notify("Comment submitted successfully", vim.log.levels.INFO)
      logger.info("Comment submitted successfully to PR #" .. review.cache.pr_number)
      -- Refresh comments
      review.load_comments()
    else
      local error_msg = "Failed to submit comment: " .. output
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      logger.debug("Command output: " .. output)
      
      -- Try to parse JSON response if available
      local ok, json_data = pcall(vim.json.decode, output)
      if ok and json_data then
        if json_data.message then
          logger.error("GitHub API error: " .. json_data.message)
        end
        if json_data.errors then
          for _, err in ipairs(json_data.errors) do
            if err.message then
              logger.error("Error detail: " .. err.message)
            end
          end
        end
        logger.debug("Full JSON response: " .. vim.inspect(json_data))
      end
    end
  end
  
  -- Set keymaps for the buffer
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>s", "", {
    noremap = true,
    silent = true,
    callback = submit_comment
  })
  
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", {
    noremap = true,
    silent = true
  })
  
  -- Set cursor at the start of the empty line below the instruction
  vim.api.nvim_win_set_cursor(winnr, {7, 0})
  
  -- Enter insert mode
  vim.cmd("startinsert")
end

-- Function to get a path relative to the git repository root
function get_relative_to_git_root(absolute_path)
  -- Find the git root directory
  local git_root_cmd = "git -C " .. vim.fn.getcwd() .. " rev-parse --show-toplevel"
  local git_root = vim.fn.trim(vim.fn.system(git_root_cmd))
  
  -- Check if we're in a git repository
  if vim.v.shell_error ~= 0 then
    -- Not in a git repo or git not available
    return nil
  end
  
  -- Ensure paths are normalized
  git_root = git_root .. "/"
  
  -- Make the path relative to git root
  if absolute_path:sub(1, #git_root) == git_root then
    -- Path is inside the git repo, remove the git root prefix
    return absolute_path:sub(#git_root + 1)
  else
    -- Path is outside the git repo
    return nil
  end
end

-- Create a comment on a specific line or range of lines
function M.comment_line(start_line, end_line)
  local review = require("ghp.review")
  
  -- Check if we have PR data
  if not review.cache.pr_number then
    vim.notify("No PR data available. Run GHPReview first.", vim.log.levels.WARN)
    logger.warn("Attempted to create line comment but no PR data available")
    return
  end
  
  logger.info(string.format("Creating line comment for PR #%s, lines %d-%d", 
    review.cache.pr_number, start_line, end_line))
  
  -- Get current buffer and file path
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  logger.debug("Current file: " .. file_path)
  
  -- Get relative path to the repository root
  local handle = io.popen("git rev-parse --show-prefix 2>/dev/null")
  if not handle then
    local error_msg = "Failed to get repository root"
    vim.notify(error_msg, vim.log.levels.ERROR)
    logger.error(error_msg)
    return
  end
  local repo_prefix = handle:read("*a"):gsub("\n", "")
  handle:close()
  logger.debug("Repository prefix: " .. (repo_prefix ~= "" and repo_prefix or "(empty)"))
  
  -- Extract filename from full path and combine with repo prefix if needed
  local repo_path
  if file_path:match("^/") then
    repo_path = get_relative_to_git_root(file_path)
    logger.debug("Using relative path from git root: " .. repo_path)
  else
    -- Assume it's already a relative path
    repo_path = file_path
    logger.debug("Using relative path as is: " .. repo_path)
  end
  
  if not repo_path or repo_path == "" then
    local error_msg = "Could not determine file path relative to repository"
    vim.notify(error_msg, vim.log.levels.ERROR)
    logger.error(error_msg)
    return
  end
  
  -- Get the commit hash for this PR
  local commit_hash = review.cache.commit_hash
  logger.debug("Commit hash for PR: " .. commit_hash)
  
  -- Create a new buffer for the comment
  local comment_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(comment_bufnr, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(comment_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(comment_bufnr, "swapfile", false)
  
  local title = string.format("PR Line Comment - %s:%d-%d", repo_path, start_line, end_line)
  vim.api.nvim_buf_set_name(comment_bufnr, title)
  
  -- Get the lines being commented on for reference
  local commented_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  
  -- Set initial content with instructions and the lines being commented on
  local lines = {
    "# Write your line comment below",
    "# Lines starting with # will be ignored",
    "# Press <leader>s to submit the comment",
    "# Press q to cancel",
    "",
    "<!-- The lines you're commenting on: -->",
  }
  
  -- Add the code being commented on (prefixed with "> ")
  for _, line in ipairs(commented_lines) do
    table.insert(lines, "> " .. line)
  end
  
  -- Add a separator and placeholder
  table.insert(lines, "")
  table.insert(lines, "<!-- Write your comment below -->")
  table.insert(lines, "")
  
  vim.api.nvim_buf_set_lines(comment_bufnr, 0, -1, false, lines)
  
  -- Create a window for the buffer
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.8)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.6)
  local row = math.floor((vim.api.nvim_get_option("lines") - height) / 2)
  local col = math.floor((vim.api.nvim_get_option("columns") - width) / 2)
  
  local opts = {
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
  
  local winnr = vim.api.nvim_open_win(comment_bufnr, true, opts)
  
  -- Set filetype for better highlighting
  vim.api.nvim_buf_set_option(comment_bufnr, "filetype", "markdown")
  
  -- Function to submit the line comment
  local function submit_line_comment()
    -- Get buffer content
    local content = vim.api.nvim_buf_get_lines(comment_bufnr, 0, -1, false)
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
      logger.warn("Line comment submission canceled: empty comment")
      return
    end
    
    -- Join lines with newlines
    local comment_body = table.concat(comment_text, "\n")
    
    -- Close the window and buffer
    vim.api.nvim_win_close(winnr, true)
    
    -- Submit the comment using GitHub API through gh CLI
    vim.notify("Submitting line comment to PR #" .. review.cache.pr_number .. "...", vim.log.levels.INFO)
    logger.info(string.format("Attempting to submit line comment for PR #%s on %s:%d-%d", 
      review.cache.pr_number, repo_path, start_line, end_line))
    
    -- Get owner and repo from remote URL
    local get_remote_cmd = "git remote get-url origin"
    logger.debug("Executing command: " .. get_remote_cmd)
    local remote_handle = io.popen(get_remote_cmd .. " 2>/dev/null")
    if not remote_handle then
      local error_msg = "Failed to get remote URL"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      return
    end
    
    local remote_url = remote_handle:read("*a"):gsub("\n", "")
    remote_handle:close()
    logger.debug("Remote URL: " .. remote_url)
    
    -- Extract owner and repo from remote URL
    local owner, repo
    if remote_url:match("github.com") then
      -- HTTPS format: https://github.com/owner/repo.git
      -- SSH format: git@github.com:owner/repo.git
      if remote_url:match("^https://") then
        owner, repo = remote_url:match("github.com/([^/]+)/([^/%.]+)")
        logger.debug("Extracted from HTTPS: owner=" .. (owner or "nil") .. ", repo=" .. (repo or "nil"))
      else
        owner, repo = remote_url:match("github.com:([^/]+)/([^/%.]+)")
        logger.debug("Extracted from SSH: owner=" .. (owner or "nil") .. ", repo=" .. (repo or "nil"))
      end
      
      if repo then
        -- Remove .git suffix if present
        repo = repo:gsub("%.git$", "")
      end
    end
    
    if not owner or not repo then
      local error_msg = "Failed to parse owner and repo from git remote"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      logger.debug("Could not extract owner/repo from: " .. remote_url)
      return
    end
    
    logger.info(string.format("Submitting comment to %s/%s PR #%s", owner, repo, review.cache.pr_number))
    
    -- Let's use the GitHub API directly to create a PR review comment
    -- Following the API specifications
    local api_endpoint = string.format("/repos/%s/%s/pulls/%s/comments", owner, repo, review.cache.pr_number)
    logger.debug("API endpoint: " .. api_endpoint)
    
    -- Determine API parameters based on whether this is a single line or multi-line comment
    local escaped_body = vim.fn.shellescape(comment_body)
    -- Remove the surrounding quotes (first and last character)
    escaped_body = escaped_body:sub(2, -2)
    
    local cmd = string.format([[gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" %s -f "body=%s" -f "commit_id=%s" -f "path=%s" -F "start_line=%d" -F "line=%d" -f "start_side=RIGHT" -f "side=RIGHT"]], 
      api_endpoint, escaped_body, commit_hash, repo_path, start_line, end_line)
    
    logger.debug("Executing command: " .. cmd)
    
    local handle = io.popen(cmd .. " 2>&1")
    if not handle then
      local error_msg = "Failed to execute gh api command"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      return
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    
    logger.debug("Command output: " .. output)
    logger.debug("Command exit status: " .. tostring(success))
    
    if success then
      vim.notify("Line comment submitted successfully", vim.log.levels.INFO)
      logger.info("Line comment submitted successfully")
      -- Refresh comments
      review.load_comments()
    else
      local error_msg = "Failed to submit line comment"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
      
      -- Try to parse JSON response if available
      local ok, json_data = pcall(vim.json.decode, output)
      if ok and json_data then
        if json_data.message then
          logger.error("GitHub API error: " .. json_data.message)
          vim.notify("API error: " .. json_data.message, vim.log.levels.ERROR)
        end
        if json_data.errors then
          for _, err in ipairs(json_data.errors) do
            if err.message then
              logger.error("Error detail: " .. err.message)
            end
          end
        end
        logger.debug("Full JSON response: " .. vim.inspect(json_data))
      end
      
      -- If the direct API call failed, attempt to use a regular comment with file/line reference
      logger.warn("API comment failed, falling back to regular PR comment with line reference")
      
      -- Add the file/line reference to the comment
      local line_range
      if start_line == end_line then
        line_range = string.format("%s:%d", repo_path, start_line)
      else
        line_range = string.format("%s:%d-%d", repo_path, start_line, end_line)
      end
      
      local full_comment = string.format("**Comment on %s**\n\n%s", line_range, comment_body)
      
      -- Escape the comment but remove the quotes
      local escaped_comment = vim.fn.shellescape(full_comment)
      escaped_comment = escaped_comment:sub(2, -2)
      
      -- Use the simple comment command instead
      cmd = string.format("gh pr comment %s --body %s", 
        review.cache.pr_number, escaped_comment)
      
      logger.debug("Trying fallback command: " .. cmd)
      
      handle = io.popen(cmd .. " 2>&1")
      if not handle then
        local error_msg = "Failed to execute fallback gh pr comment command"
        vim.notify(error_msg, vim.log.levels.ERROR)
        logger.error(error_msg)
        return
      end
      
      output = handle:read("*a")
      success = handle:close()
      
      logger.debug("Fallback command output: " .. output)
      logger.debug("Fallback command exit status: " .. tostring(success))
      
      if success then
        vim.notify("Comment submitted as general PR comment with line reference", vim.log.levels.INFO)
        logger.info("Comment submitted as general PR comment with line reference")
        review.load_comments()
      else
        local error_msg = "Failed to submit fallback comment: " .. output
        vim.notify(error_msg, vim.log.levels.ERROR)
        logger.error(error_msg)
      end
    end
  end
  
  -- Set keymaps for the buffer
  vim.api.nvim_buf_set_keymap(comment_bufnr, "n", "<leader>s", "", {
    noremap = true,
    silent = true,
    callback = submit_line_comment
  })
  
  vim.api.nvim_buf_set_keymap(comment_bufnr, "n", "q", "<cmd>close<CR>", {
    noremap = true,
    silent = true
  })
  
  -- Set cursor at the start of the empty line below the instruction
  local placeholder_line = #lines
  vim.api.nvim_win_set_cursor(winnr, {placeholder_line, 0})
  
  -- Enter insert mode
  vim.cmd("startinsert")
end

-- Create a comment on the current line (normal mode) or selected lines (visual mode)
function M.comment_line_or_selection()
  -- Check if we're in visual mode or normal mode
  local mode = vim.api.nvim_get_mode().mode
  
  if mode:match("^[vV]") then
    -- Visual mode - get the selected lines
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]
    logger.debug(string.format("Visual mode selection detected: lines %d-%d", start_line, end_line))
    M.comment_line(start_line, end_line)
  else
    -- Normal mode - comment current line
    local line = vim.api.nvim_win_get_cursor(0)[1]
    logger.debug("Normal mode: commenting on line " .. line)
    M.comment_line(line - 1, line)
  end
end

return M 
