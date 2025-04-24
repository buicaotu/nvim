local M = {}
local core = require("personal.command_palette.core")

-- Function to perform grep and register it in command palette
function M.grep(dir, search)
  -- Create a descriptive name for the command
  local shortdir = dir:match("([^/]+)$") or dir
  local description
  if search == nil then
    description = string.format("grep: %s", shortdir)
  else
    description = string.format("grep: '%s' in %s", search, shortdir)
  end
  
  -- Check if this exact grep command already exists
  for i, cmd in ipairs(core.command_history) do
    if cmd.description == description then
      -- Execute the existing command and bump it to the top of history
      core.execute_command(cmd)
      return
    end
  end
  
  -- Create the action function
  local action = function()
    require("fzf-lua").grep({
      cwd = dir,
      input_prompt = 'Grep in ' .. dir .. ' ❯ ',
      search = search,
    })
  end
  
  -- Create the command object
  local command = {
    description = description,
    action = action
  }
  
  -- Add to history
  core.add_to_history(command)
  
  -- Execute the action
  action()
end

-- Function to browse files and register it in command palette
function M.files(dir)
  -- Create a descriptive name for the command
  local shortdir = dir:match("([^/]+)$") or dir
  local description = string.format("files: browse %s", shortdir)
  
  -- Check if this exact files command already exists
  for i, cmd in ipairs(core.command_history) do
    if cmd.description == description then
      -- Execute the existing command and bump it to the top of history
      core.execute_command(cmd)
      return
    end
  end
  
  -- Create the action function
  local action = function()
    require("fzf-lua").files({
      cwd = dir,
      prompt = 'Files in ' .. dir .. ' ❯ ',
    })
  end
  
  -- Create the command object
  local command = {
    description = description,
    action = action
  }
  
  -- Add to history
  core.add_to_history(command)
  
  -- Execute the action
  action()
end

-- Register commands
function M.setup()
  -- No commands to register by default
end

return M 