local M = {}

-- Default configuration
local default_config = {
  -- Add default configuration options here
  enabled = true,
}

-- Plugin setup function
function M.setup(opts)
  -- Merge user config with defaults
  opts = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Initialize the plugin
  if not opts.enabled then
    return
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
end

M.setup()
return M 
