local M = {}
local logger = require("ghp.logger")
local comment_utils = require("ghp.comment_utils")

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
  
  -- Function to submit the comment
  local function handle_submit(comment_body)
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
  
  -- Create comment window
  comment_utils.create_comment_window({
    title = "PR Comment - #" .. review.cache.pr_number,
    on_submit = handle_submit
  })
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
  
  -- Get the lines being commented on for reference
  local commented_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  
  local title = string.format("PR Line Comment - %s:%d-%d", repo_path, start_line, end_line)
  
  -- Function to submit the line comment
  local function handle_submit(comment_body)
    -- Submit the comment using GitHub API through gh CLI
    vim.notify("Submitting line comment to PR #" .. review.cache.pr_number .. "...", vim.log.levels.INFO)
    logger.info(string.format("Attempting to submit line comment for PR #%s on %s:%d-%d", 
      review.cache.pr_number, repo_path, start_line, end_line))
    
    -- Get owner and repo from cache
    local owner = review.cache.owner
    local repo = review.cache.repo
    
    -- If owner and repo are not in the cache, log an error
    if not owner or not repo then
      local error_msg = "Repository owner or name not found in cache"
      vim.notify(error_msg, vim.log.levels.ERROR)
      logger.error(error_msg)
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
    end
  end
  
  -- Create comment window
  comment_utils.create_comment_window({
    title = title,
    commented_lines = commented_lines,
    on_submit = handle_submit
  })
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
