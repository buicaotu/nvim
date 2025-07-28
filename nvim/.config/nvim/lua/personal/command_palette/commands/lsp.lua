local M = {}
local core = require("personal.command_palette.core")

-- Register commands
function M.setup()
  core.register_command("lsp: restart language server", ":LspRestart")
  -- Add more LSP commands as needed
end

return M 