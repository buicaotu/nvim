local M = {}

-- Import modules
local core = require("personal.command_palette.core")
local buffer_commands = require("personal.command_palette.commands.buffer")
local lsp_commands = require("personal.command_palette.commands.lsp")
local workflow_commands = require("personal.command_palette.commands.workflow")
local search_commands = require("personal.command_palette.commands.search")

-- Re-export core functions
M.open_palette = core.open_palette
M.register_command = core.register_command
M.grep = search_commands.grep
M.files = search_commands.files

-- Setup function
function M.setup()
  -- Setup all command modules
  buffer_commands.setup()
  lsp_commands.setup()
  workflow_commands.setup()
  search_commands.setup()
end

return M 