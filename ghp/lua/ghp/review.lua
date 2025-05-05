local M = {}

-- Simplified cache structure for a single PR review
M.cache = {
  -- Will be nil if not reviewing a PR
  pr_number = nil,
  pr_title = nil,
  commit_hash = nil,
  branch = nil,
  base_branch = nil,
  base_commit_hash = nil, -- Hash of the common ancestor commit
  url = nil,
  
  -- Repository info
  owner = nil,
  repo = nil,
  
  -- Quickfix data
  title = nil,
  entries = nil,
  
  -- Timestamp
  created_at = nil
}

-- Get the current branch name
local function get_current_branch()
  local handle = io.popen("git branch --show-current 2>/dev/null")
  if not handle then
    return nil
  end
  
  local branch = handle:read("*a"):gsub("\n", "")
  handle:close()
  
  return branch ~= "" and branch or nil
end

-- Get PR information for the current branch
local function get_pr_info()
  local branch = get_current_branch()
  if not branch then
    vim.notify("Not in a git branch", vim.log.levels.ERROR)
    return nil
  end
  
  local cmd = "gh pr view --json number,title,headRefOid,headRefName,baseRefName,url --jq ."
  local handle = io.popen(cmd .. " 2>/dev/null")
  if not handle then
    return nil
  end
  
  local output = handle:read("*a")
  handle:close()
  
  if output == "" then
    vim.notify("No PR found for branch " .. branch, vim.log.levels.WARN)
    return nil
  end
  
  local ok, pr_data = pcall(vim.json.decode, output)
  if not ok or not pr_data then
    vim.notify("Failed to parse PR data", vim.log.levels.ERROR)
    return nil
  end
  
  return pr_data
end

-- Get the base (merge-base) commit hash between the PR branch and target branch
local function get_base_commit_hash(pr_data)
  -- First, fetch the remote to ensure we have the latest refs
  local fetch_cmd = "git fetch"
  local fetch_handle = io.popen(fetch_cmd .. " 2>/dev/null")
  if fetch_handle then
    fetch_handle:read("*a")
    fetch_handle:close()
  else
    vim.notify("Warning: Failed to fetch from remote", vim.log.levels.WARN)
  end
  
  -- Get the remote name (usually 'origin')
  local remote_cmd = "git remote"
  local remote_handle = io.popen(remote_cmd .. " 2>/dev/null")
  if not remote_handle then
    vim.notify("Failed to get git remote", vim.log.levels.WARN)
    return nil
  end
  
  local remote = remote_handle:read("*l") or "origin"
  remote_handle:close()
  
  -- Get the common ancestor commit between the remote PR target branch and PR head
  -- This ensures we use the latest remote state even if local branches are behind
  local cmd = string.format("git merge-base %s/%s %s", 
    remote, pr_data.baseRefName, pr_data.headRefOid)
  
  vim.notify("Running: " .. cmd, vim.log.levels.DEBUG)
  
  local handle = io.popen(cmd .. " 2>&1")  -- Capture stderr too for error messages
  if not handle then
    vim.notify("Failed to execute merge-base command", vim.log.levels.ERROR)
    return nil
  end
  
  local output = handle:read("*a")
  local exit_code = handle:close()
  
  if not exit_code then
    vim.notify("Error getting base commit: " .. output, vim.log.levels.ERROR)
    return nil
  end
  
  local base_hash = output:gsub("\n", "")
  
  if base_hash == "" then
    -- Fallback to trying with local branches if remote approach fails
    vim.notify("Falling back to local branch merge-base", vim.log.levels.DEBUG)
    cmd = string.format("git merge-base %s %s", pr_data.baseRefName, pr_data.headRefOid)
    handle = io.popen(cmd .. " 2>/dev/null")
    if handle then
      base_hash = handle:read("*a"):gsub("\n", "")
      handle:close()
    end
    
    if base_hash == "" then
      vim.notify("Could not determine base commit hash", vim.log.levels.WARN)
      return nil
    end
  end
  
  vim.notify("Base commit hash: " .. base_hash:sub(1, 10) .. "...", vim.log.levels.DEBUG)
  return base_hash
end

-- Get changed files in PR
local function get_changed_files(pr_data)
  local cmd = string.format("gh pr view %s --json files --jq '.files[].path'", pr_data.number)
  local handle = io.popen(cmd .. " 2>/dev/null")
  if not handle then
    return {}
  end
  
  local files = {}
  for file in handle:lines() do
    table.insert(files, file)
  end
  handle:close()
  
  return files
end

-- Create quickfix entries for files
local function create_qf_entries(files)
  local entries = {}
  for _, file in ipairs(files) do
    table.insert(entries, {
      filename = file,
      lnum = 1,
      col = 1,
      text = file,
    })
  end
  return entries
end

-- Extract owner and repo from remote URL
local function extract_repo_info()
  local get_remote_cmd = "git remote get-url origin"
  local remote_handle = io.popen(get_remote_cmd .. " 2>/dev/null")
  if not remote_handle then
    vim.notify("Failed to get remote URL", vim.log.levels.ERROR)
    return nil, nil
  end
  
  local remote_url = remote_handle:read("*a"):gsub("\n", "")
  remote_handle:close()
  vim.notify("Remote URL: " .. remote_url, vim.log.levels.DEBUG)
  
  -- Extract owner and repo from remote URL
  local owner, repo
  if remote_url:match("github.com") then
    -- HTTPS format: https://github.com/owner/repo.git
    -- SSH format: git@github.com:owner/repo.git
    if remote_url:match("^https://") then
      owner, repo = remote_url:match("github.com/([^/]+)/([^/%.]+)")
      vim.notify("Extracted from HTTPS: owner=" .. (owner or "nil") .. ", repo=" .. (repo or "nil"), vim.log.levels.DEBUG)
    else
      owner, repo = remote_url:match("github.com:([^/]+)/([^/%.]+)")
      vim.notify("Extracted from SSH: owner=" .. (owner or "nil") .. ", repo=" .. (repo or "nil"), vim.log.levels.DEBUG)
    end
    
    if repo then
      -- Remove .git suffix if present
      repo = repo:gsub("%.git$", "")
    end
  end
  
  if not owner or not repo then
    vim.notify("Failed to parse owner and repo from git remote", vim.log.levels.ERROR)
    vim.notify("Could not extract owner/repo from: " .. remote_url, vim.log.levels.DEBUG)
    return nil, nil
  end
  
  return owner, repo
end

-- Set quickfix list with PR information
local function set_quickfix(pr_data, entries)
  local title = string.format("PR: %s", pr_data.title)
  local context = {
    plugin = "ghp",
    pr_number = pr_data.number,
    pr_title = pr_data.title,
    commit_hash = pr_data.headRefOid,
    branch = pr_data.headRefName,
    base_branch = pr_data.baseRefName,
    base_commit_hash = pr_data.baseCommitHash,
    url = pr_data.url,
    owner = pr_data.owner,
    repo = pr_data.repo
  }
  
  vim.fn.setqflist({}, ' ', {
    title = title,
    context = context,
    items = entries
  })
  
  -- Store in cache with flattened attributes
  M.cache.pr_number = pr_data.number
  M.cache.pr_title = pr_data.title
  M.cache.commit_hash = pr_data.headRefOid
  M.cache.branch = pr_data.headRefName
  M.cache.base_branch = pr_data.baseRefName
  M.cache.base_commit_hash = pr_data.baseCommitHash
  M.cache.url = pr_data.url
  M.cache.owner = pr_data.owner
  M.cache.repo = pr_data.repo
  M.cache.title = title
  M.cache.entries = entries
  M.cache.created_at = os.time()
  
  -- Open quickfix window
  vim.cmd("copen")
  vim.notify("Loaded PR files into quickfix list", vim.log.levels.INFO)
end

-- Main function to review PR
function M.review()
  local pr_data = get_pr_info()
  if not pr_data then
    return
  end
  
  -- Get the base commit hash (common ancestor)
  local base_commit_hash = get_base_commit_hash(pr_data)
  -- Attach it to the pr_data for convenience
  pr_data.baseCommitHash = base_commit_hash
  
  -- Extract and store repository owner and name
  local owner, repo = extract_repo_info()
  pr_data.owner = owner
  pr_data.repo = repo
  
  local files = get_changed_files(pr_data)
  if vim.tbl_isempty(files) then
    vim.notify("No files changed in PR", vim.log.levels.WARN)
    return
  end
  
  local entries = create_qf_entries(files)
  set_quickfix(pr_data, entries)
end

-- Create a floating window with PR info
function M.show_info()
  -- Check if we have PR data
  if not M.cache.pr_number then
    vim.notify("No PR data available. Run GHPReview first.", vim.log.levels.WARN)
    return
  end
  
  -- Create content for the floating window
  local lines = {
    "PR #" .. M.cache.pr_number .. ": " .. M.cache.pr_title,
    "",
    "Repository: " .. (M.cache.owner or "Unknown") .. "/" .. (M.cache.repo or "Unknown"),
    "Branch: " .. M.cache.branch,
    "Target: " .. M.cache.base_branch,
    "Head Commit: " .. M.cache.commit_hash:sub(1, 10),
    "Base Commit: " .. (M.cache.base_commit_hash and M.cache.base_commit_hash:sub(1, 10) or "Unknown"),
    "URL: " .. M.cache.url,
    "",
  }
  
  table.insert(lines, "----------------------------------------")
  table.insert(lines, "Files changed: " .. #M.cache.entries)
  table.insert(lines, "----------------------------------------")
  
  -- Add list of files
  for i, entry in ipairs(M.cache.entries) do
    if i <= 20 then -- Limit to first 20 files
      table.insert(lines, " - " .. entry.filename)
    else
      table.insert(lines, "... and " .. (#M.cache.entries - 20) .. " more files")
      break
    end
  end
  
  -- Calculate window dimensions
  local width = 80
  local height = math.min(#lines, 30) -- Increased max height to 30 lines to show more content
  
  -- Calculate window position (centered)
  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)
  
  -- Create buffer
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  
  -- Define window options
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "PR Review Info",
    title_pos = "center",
  }
  
  -- Create window
  local winnr = vim.api.nvim_open_win(bufnr, true, opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(winnr, "wrap", true) -- Enable wrapping for comments
  vim.api.nvim_win_set_option(winnr, "cursorline", true)
  
  -- Set keymaps for the window
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
  
  -- Return window number in case needed
  return winnr
end

-- Export the function as part of the module
M.extract_repo_info = extract_repo_info

return M 
