local M = {}
local core = require("personal.command_palette.core")

-- Register commands
function M.setup()
  core.register_command("workflow: diff green", ":DiffGreen")
  -- Add more workflow commands as needed
end

return M 