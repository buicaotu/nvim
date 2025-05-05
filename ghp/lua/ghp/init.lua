local M = {}

-- Default configuration
local default_config = {
  -- Add default configuration options here
  enabled = true,
  log_level = "DEBUG", -- Default log level: DEBUG, INFO, WARN, ERROR
}

-- Plugin setup function
function M.setup(opts)
  -- Merge user config with defaults
  opts = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Initialize the plugin
  if not opts.enabled then
    return
  end
  
  -- Set up logger
  local logger = require("ghp.logger")
  if opts.log_level then
    logger.set_level(opts.log_level)
  end
  
  -- Plugin implementation goes here
  M.setup_commands()
end

-- Set up plugin commands
function M.setup_commands()
  -- Create a user command for GHPReview
  vim.api.nvim_create_user_command("GHPReview", function()
    require("ghp.review").review()
  end, {
    desc = "Review GitHub PR for current branch in quickfix list"
  })
  
  -- Create a user command to show PR info in a floating window
  vim.api.nvim_create_user_command("GHPReviewShow", function()
    require("ghp.review").show_info()
  end, {
    desc = "Show PR review information in a floating window"
  })
  
  -- Create a user command to add a comment to the PR
  vim.api.nvim_create_user_command("GHPComment", function()
    require("ghp.comment").create_comment()
  end, {
    desc = "Add a comment to the current PR"
  })
  
  -- Create a user command for line comments (works in both normal and visual modes)
  vim.api.nvim_create_user_command("GHPCommentLine", function()
    require("ghp.comment").comment_line_or_selection()
  end, {
    desc = "Add a comment on current line or selected lines to the PR",
    range = true
  })
  
  -- Create a user command to open the log file
  vim.api.nvim_create_user_command("GHPOpenLog", function()
    require("ghp.logger").open_log()
  end, {
    desc = "Open the GitHub PR plugin log file in a buffer"
  })
  
  -- Create a user command to clear the log file
  vim.api.nvim_create_user_command("GHPClearLog", function()
    require("ghp.logger").clear_log()
  end, {
    desc = "Clear the GitHub PR plugin log file"
  })
  
  -- Create a user command to set the log level
  vim.api.nvim_create_user_command("GHPSetLogLevel", function(args)
    if args.args and args.args ~= "" then
      require("ghp.logger").set_level(args.args:upper())
    else
      vim.notify("Please specify a log level: DEBUG, INFO, WARN, ERROR", vim.log.levels.WARN)
    end
  end, {
    desc = "Set the GitHub PR plugin log level",
    nargs = "?",
    complete = function(ArgLead, CmdLine, CursorPos)
      return vim.tbl_filter(
        function(level) 
          return level:find(ArgLead:upper()) == 1
        end,
        {"DEBUG", "INFO", "WARN", "ERROR"}
      )
    end
  })
end

M.setup()
return M 
