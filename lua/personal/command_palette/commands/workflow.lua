local M = {}
local core = require("personal.command_palette.core")

-- Register commands
function M.setup()
  core.register_command("workflow: diff green", ":DiffGreen")
  
  -- Session management commands
  core.register_command("workflow: save session", function()
    vim.cmd("mksession! " .. vim.fn.stdpath("config") .. "/session.vim")
    vim.notify("Session saved", vim.log.levels.INFO)
  end)
  
  core.register_command("workflow: load session", function()
    local session_file = vim.fn.stdpath("config") .. "/session.vim"
    if vim.fn.filereadable(session_file) == 1 then
      vim.cmd("source " .. session_file)
      vim.notify("Session loaded", vim.log.levels.INFO)
    else
      vim.notify("No session file found", vim.log.levels.WARN)
    end
  end)
  
  -- Add more workflow commands as needed
end

return M 