return {
  "nvim-lua/plenary.nvim",
  dependencies = {},
  config = function()
    local function get_current_branch_name()
      local branch = vim.fn.system("git branch --show-current"):gsub("%s+", "")
      return branch
    end

    local function get_pr_number()
      local cmd = "gh pr view --json number -q .number 2>/dev/null"
      local handle = io.popen(cmd)
      local result = handle:read("*a"):gsub("%s+", "")
      handle:close()
      
      return tonumber(result)
    end

    local function get_pr_info()
      local cmd = "gh pr view --json title,url,state,author,reviewDecision,number,headRepository 2>/dev/null"
      local handle = io.popen(cmd)
      local result = handle:read("*a")
      handle:close()
      
      if result == "" then
        return nil
      end
      
      local success, pr_info = pcall(vim.json.decode, result)
      if not success then
        return nil
      end
      
      return pr_info
    end

    local function review_current_pr()
      local branch = get_current_branch_name()
      if branch == "" then
        vim.notify("Not in a git repository or no branch detected", vim.log.levels.ERROR)
        return
      end

      -- Get PR info
      local pr_info = get_pr_info()
      if not pr_info then
        vim.notify("No PR found for the current branch", vim.log.levels.ERROR)
        return
      end

      -- Show PR info in a notification
      local pr_status = string.format(
        "PR #%d: %s\nState: %s\nAuthor: %s\nReview: %s",
        pr_info.number,
        pr_info.title,
        pr_info.state,
        pr_info.author.login,
        pr_info.reviewDecision or "NONE"
      )
      vim.notify(pr_status, vim.log.levels.INFO)

      -- Run gh command to get PR diff files
      local cmd = "gh pr diff --name-only"
      local handle = io.popen(cmd)
      local result = handle:read("*a")
      handle:close()

      if result == "" then
        vim.notify("No changed files found in the PR", vim.log.levels.WARN)
        return
      end

      -- Parse the files and load them into the quickfix list
      local files = {}
      for file in string.gmatch(result, "([^\n]+)") do
        if vim.fn.filereadable(file) == 1 then
          table.insert(files, { filename = file, lnum = 1 })
        end
      end

      if #files == 0 then
        vim.notify("No readable files found in PR diff", vim.log.levels.WARN)
        return
      end

      -- Set quickfix list
      vim.fn.setqflist(files)
      vim.cmd("copen")
      vim.notify(string.format("Loaded %d files into quickfix list", #files), vim.log.levels.INFO)
    end

    local function open_pr_in_browser()
      local pr_number = get_pr_number()
      if not pr_number then
        vim.notify("No PR found for the current branch", vim.log.levels.ERROR)
        return
      end

      vim.fn.system("gh pr view --web")
      vim.notify("Opening PR in browser", vim.log.levels.INFO)
    end

    local function view_pr_diff()
      local pr_number = get_pr_number()
      if not pr_number then
        vim.notify("No PR found for the current branch", vim.log.levels.ERROR)
        return
      end

      -- Create a new buffer for the diff
      vim.cmd("new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
      vim.bo.filetype = "diff"
      vim.api.nvim_buf_set_name(0, "PR Diff #" .. pr_number)

      -- Get the diff
      local cmd = "gh pr diff"
      local handle = io.popen(cmd)
      local diff = handle:read("*a")
      handle:close()

      -- Set the buffer content
      local lines = {}
      for line in diff:gmatch("[^\r\n]+") do
        table.insert(lines, line)
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

      -- Make the buffer read-only
      vim.bo.modifiable = false
      vim.notify("Loaded PR diff", vim.log.levels.INFO)
    end

    local function view_pr_comments()
      local pr_number = get_pr_number()
      if not pr_number then
        vim.notify("No PR found for the current branch", vim.log.levels.ERROR)
        return
      end

      -- Create a new buffer for the comments
      vim.cmd("new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
      vim.bo.filetype = "markdown"
      vim.api.nvim_buf_set_name(0, "PR Comments #" .. pr_number)

      -- Get the comments
      local cmd = "gh pr view --json comments -q '.comments[]|\"\\(.author.login) wrote on \\(.createdAt):\\n\\(.body)\\n\"'"
      local handle = io.popen(cmd)
      local comments = handle:read("*a")
      handle:close()

      -- Set the buffer content
      if comments:gsub("%s+", "") ~= "" then
        local lines = {}
        for line in comments:gmatch("[^\r\n]+") do
          table.insert(lines, line)
        end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      else
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {"No comments found on this PR"})
      end

      -- Make the buffer read-only
      vim.bo.modifiable = false
      vim.notify("Loaded PR comments", vim.log.levels.INFO)
    end

    local function add_pr_comment()
      local current_file = vim.fn.expand("%:p")
      local current_line = vim.fn.line(".")
      
      -- Open a new buffer for the comment
      vim.cmd("new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
      vim.bo.filetype = "markdown"
      vim.api.nvim_buf_set_name(0, "PR Comment")
      
      -- Add function to submit the comment
      vim.keymap.set("n", "<leader>s", function()
        local comment = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        if comment:gsub("%s+", "") == "" then
          vim.notify("Comment is empty", vim.log.levels.WARN)
          return
        end
        
        -- Save comment to a temporary file
        local temp_file = vim.fn.tempname()
        local file = io.open(temp_file, "w")
        file:write(comment)
        file:close()
        
        -- Submit the comment using gh cli
        local cmd = string.format("gh pr comment --body-file %s", vim.fn.shellescape(temp_file))
        vim.fn.system(cmd)
        os.remove(temp_file)
        
        vim.notify("Comment submitted", vim.log.levels.INFO)
        vim.cmd("q")
      end, { buffer = true, desc = "Submit PR comment" })
      
      -- Instructions in the buffer
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {
        "# Write your PR comment here",
        "# Press <leader>s to submit the comment",
        "",
        ""
      })
      vim.cmd("startinsert")
    end

    -- Add file-specific comment function
    local function add_file_comment()
      local current_file = vim.fn.expand("%:p")
      local current_line = vim.fn.line(".")
      local relative_path = vim.fn.fnamemodify(current_file, ":.")
      
      -- Open a new buffer for the comment
      vim.cmd("new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
      vim.bo.filetype = "markdown"
      vim.api.nvim_buf_set_name(0, "PR File Comment")
      
      -- Add function to submit the comment
      vim.keymap.set("n", "<leader>s", function()
        local comment = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        if comment:gsub("%s+", "") == "" then
          vim.notify("Comment is empty", vim.log.levels.WARN)
          return
        end
        
        -- Save comment to a temporary file
        local temp_file = vim.fn.tempname()
        local file = io.open(temp_file, "w")
        file:write(comment)
        file:close()
        
        -- Submit the comment using gh cli
        local cmd = string.format("gh pr comment --body-file %s -p %s:%d", 
          vim.fn.shellescape(temp_file), 
          vim.fn.shellescape(relative_path), 
          current_line)
        vim.fn.system(cmd)
        os.remove(temp_file)
        
        vim.notify("File comment submitted", vim.log.levels.INFO)
        vim.cmd("q")
      end, { buffer = true, desc = "Submit PR file comment" })
      
      -- Instructions in the buffer
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {
        "# Write your PR comment for " .. relative_path .. ":" .. current_line,
        "# Press <leader>s to submit the comment",
        "",
        ""
      })
      vim.cmd("startinsert")
    end

    -- Add PR review function with options
    local function review_pr()
      local pr_number = get_pr_number()
      if not pr_number then
        vim.notify("No PR found for the current branch", vim.log.levels.ERROR)
        return
      end

      local pr_info = get_pr_info()
      if not pr_info then
        vim.notify("Failed to get PR info", vim.log.levels.ERROR)
        return
      end

      -- Create a popup menu with review options
      local review_options = {
        { "Approve", "approve" },
        { "Request Changes", "request-changes" },
        { "Comment", "comment" },
      }

      -- Display the options
      vim.ui.select(review_options, {
        prompt = string.format("Review PR #%d: %s", pr_info.number, pr_info.title),
        format_item = function(item)
          return item[1]
        end,
      }, function(choice)
        if not choice then
          return
        end

        -- Open a new buffer for the review comment
        vim.cmd("new")
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
        vim.bo.filetype = "markdown"
        vim.api.nvim_buf_set_name(0, "PR Review: " .. choice[1])
        
        -- Add function to submit the review
        vim.keymap.set("n", "<leader>s", function()
          local comment = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          
          -- Save comment to a temporary file
          local temp_file = vim.fn.tempname()
          local file = io.open(temp_file, "w")
          file:write(comment)
          file:close()
          
          -- Submit the review using gh cli
          local cmd = string.format("gh pr review --body-file %s --%s", 
            vim.fn.shellescape(temp_file), 
            choice[2])
          vim.fn.system(cmd)
          os.remove(temp_file)
          
          vim.notify("PR review submitted: " .. choice[1], vim.log.levels.INFO)
          vim.cmd("q")
        end, { buffer = true, desc = "Submit PR review" })
        
        -- Instructions in the buffer
        vim.api.nvim_buf_set_lines(0, 0, 0, false, {
          "# " .. choice[1] .. " review for PR #" .. pr_info.number .. ": " .. pr_info.title,
          "# Press <leader>s to submit the review",
          "",
          ""
        })
        vim.cmd("startinsert")
      end)
    end

    -- Create commands
    vim.api.nvim_create_user_command("PRReview", review_current_pr, {
      desc = "Review the PR for current branch and load file changes into quickfix list",
    })
    
    vim.api.nvim_create_user_command("PROpen", open_pr_in_browser, {
      desc = "Open current PR in browser",
    })
    
    vim.api.nvim_create_user_command("PRComment", add_pr_comment, {
      desc = "Add a comment to the current PR",
    })

    vim.api.nvim_create_user_command("PRFileComment", add_file_comment, {
      desc = "Add a comment to a specific file and line in the PR",
    })

    vim.api.nvim_create_user_command("PRDiff", view_pr_diff, {
      desc = "View the full PR diff in a buffer",
    })

    vim.api.nvim_create_user_command("PRComments", view_pr_comments, {
      desc = "View all comments on the PR",
    })

    vim.api.nvim_create_user_command("PRSubmitReview", review_pr, {
      desc = "Submit a review for the PR (approve, request changes, or comment)",
    })

    -- Create keymaps in a GitHub PR review namespace
    local pr_keymaps = {
      r = { review_current_pr, "Review current PR" },
      o = { open_pr_in_browser, "Open PR in browser" },
      c = { add_pr_comment, "Add PR comment" },
      f = { add_file_comment, "Add file comment" },
      d = { view_pr_diff, "View PR diff" },
      m = { view_pr_comments, "View PR comments" },
      s = { review_pr, "Submit PR review" },
    }

    -- Create which-key integration if available
    local ok, which_key = pcall(require, "which-key")
    if ok then
      which_key.register({
        p = {
          name = "GitHub PR",
          r = pr_keymaps.r,
          o = pr_keymaps.o,
          c = pr_keymaps.c,
          f = pr_keymaps.f,
          d = pr_keymaps.d,
          m = pr_keymaps.m,
          s = pr_keymaps.s,
        },
      }, { prefix = "<leader>g" })
    else
      -- Fallback to regular keymaps
      vim.keymap.set("n", "<leader>gpr", pr_keymaps.r[1], { desc = pr_keymaps.r[2] })
      vim.keymap.set("n", "<leader>gpo", pr_keymaps.o[1], { desc = pr_keymaps.o[2] })
      vim.keymap.set("n", "<leader>gpc", pr_keymaps.c[1], { desc = pr_keymaps.c[2] })
      vim.keymap.set("n", "<leader>gpf", pr_keymaps.f[1], { desc = pr_keymaps.f[2] })
      vim.keymap.set("n", "<leader>gpd", pr_keymaps.d[1], { desc = pr_keymaps.d[2] })
      vim.keymap.set("n", "<leader>gpm", pr_keymaps.m[1], { desc = pr_keymaps.m[2] })
      vim.keymap.set("n", "<leader>gps", pr_keymaps.s[1], { desc = pr_keymaps.s[2] })
    end
  end,
} 